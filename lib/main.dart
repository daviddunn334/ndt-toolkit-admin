import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    show FirebaseCrashlytics;
import 'firebase_options.dart';
import 'services/offline_service.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/admin/admin_main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/email_verification_screen.dart';
import 'screens/terms_of_service_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/feedback_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline service
  final offlineService = OfflineService();
  await offlineService.initialize();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Crashlytics (only on supported platforms)
    if (!kIsWeb) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      
      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    } else {
      // On web, just log errors to console
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        if (kDebugMode) {
          print('[Error] ${details.exception}');
          print('[Stack] ${details.stack}');
        }
      };
      
      PlatformDispatcher.instance.onError = (error, stack) {
        if (kDebugMode) {
          print('[Async Error] $error');
          print('[Stack] $stack');
        }
        return true;
      };
    }
    
    // Initialize AuthService with persistence
    final authService = AuthService();
    await authService.initialize();
    
    if (kDebugMode) {
      print('[Admin Panel] Firebase initialized successfully');
    }
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  
  runApp(const AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  const AdminPanelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDT-ToolKit Admin Panel',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/reset_password': (context) => const ResetPasswordScreen(),
        '/email_verification': (context) => const EmailVerificationScreen(),
        '/terms_of_service': (context) => const TermsOfServiceScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
        '/admin': (context) => const AdminMainScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/feedback': (context) => const FeedbackScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to offline status
    return StreamBuilder<bool>(
      stream: OfflineService().onConnectivityChanged,
      initialData: OfflineService().isOnline,
      builder: (context, offlineSnapshot) {
        final bool isOnline = offlineSnapshot.data ?? true;
        
        // Admin panel requires online connection
        if (!isOnline) {
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off,
                    size: 64,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Panel Offline',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please check your internet connection',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // If online, proceed with normal authentication flow
        return StreamBuilder<fb_auth.User?>(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot) {
            // Show loading indicator while checking auth state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xFF0F172A),
                body: Center(
                  child: LoadingLogo(),
                ),
              );
            }

            // Show error if there's an issue with auth state
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text('Error: ${snapshot.error}'),
                ),
              );
            }

            // Show login screen if not authenticated
            if (!snapshot.hasData) {
              return const LoginScreen();
            }

            // Check email verification and admin status
            return const AdminVerificationChecker();
          },
        );
      },
    );
  }
}

/// Widget that checks if user is verified and has admin privileges
class AdminVerificationChecker extends StatelessWidget {
  const AdminVerificationChecker({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    
    if (user == null) {
      return const LoginScreen();
    }

    // Check email verification
    if (!user.emailVerified) {
      // Grandfathering logic
      final cutoffDate = DateTime(2026, 2, 12);
      final accountCreated = user.metadata.creationTime;
      
      if (accountCreated != null && accountCreated.isBefore(cutoffDate)) {
        // Grandfathered user - proceed to admin check
        return const AdminAccessChecker();
      }
      
      // New user needs verification
      return const EmailVerificationScreen();
    }

    // Email verified - check admin status
    return const AdminAccessChecker();
  }
}

/// Check if user has admin privileges
class AdminAccessChecker extends StatelessWidget {
  const AdminAccessChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UserService().isCurrentUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F172A),
            body: Center(
              child: LoadingLogo(),
            ),
          );
        }

        final isAdmin = snapshot.data ?? false;
        
        if (!isAdmin) {
          // Not an admin - show access denied
          return Scaffold(
            backgroundColor: const Color(0xFF0F172A),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock,
                      size: 64,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Access Denied',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This is the Admin Panel.\nYou need administrator privileges to access this area.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Sign Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // User is admin - grant access
        if (kDebugMode) {
          print('[AdminPanel] Admin access granted');
        }
        return const AdminMainScreen();
      },
    );
  }
}

/// Loading screen with pulsing company logo
class LoadingLogo extends StatefulWidget {
  const LoadingLogo({super.key});

  @override
  State<LoadingLogo> createState() => _LoadingLogoState();
}

class _LoadingLogoState extends State<LoadingLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: Image.asset(
              'assets/logos/logo_main.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Admin Panel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
