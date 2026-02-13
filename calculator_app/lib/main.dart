import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://cefujtovqdicsfqywfxw.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNlZnVqdG92cWRpY3NmcXl3Znh3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5MDE5NTQsImV4cCI6MjA2MjQ3Nzk1NH0.B-gvG-6hchT6sOV6rhJBl8KbDlumorIzx4L8YauypDE',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NDT Calculator',
      theme: AppTheme.theme,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false, // 👈 This removes the debug banner
    );
  }
}
