import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/account_deletion_service.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Multi-step dialog for account deletion with safety measures
/// 
/// Flow:
/// 1. Warning dialog with data checklist
/// 2. Re-authentication (password confirmation)
/// 3. Processing with progress indicator
/// 4. Success message with auto-logout
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final AccountDeletionService _deletionService = AccountDeletionService();
  final AuthService _authService = AuthService();
  final TextEditingController _passwordController = TextEditingController();

  int _currentStep = 0; // 0 = warning, 1 = re-auth, 2 = processing, 3 = success
  bool _understandChecked = false;
  bool _isProcessing = false;
  String? _errorMessage;
  String _progressMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // Step 0: Warning Dialog
  Widget _buildWarningStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warning header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accessoryAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.accessoryAccent.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.accessoryAccent, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Permanent Account Deletion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Warning message
        const Text(
          'This action cannot be undone. All of your data will be permanently deleted:',
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),

        // Data checklist
        _buildDataItem(Icons.account_circle, 'User profile and preferences'),
        _buildDataItem(Icons.description, 'Inspection reports and photos'),
        _buildDataItem(Icons.access_time, 'Method hours entries'),
        _buildDataItem(Icons.science, 'Defect analysis data'),
        _buildDataItem(Icons.photo_camera, 'Photo identifications'),
        _buildDataItem(Icons.location_on, 'Personal locations and folders'),
        _buildDataItem(Icons.feedback, 'Feedback submissions'),
        _buildDataItem(Icons.cloud_upload, 'All uploaded files'),

        const SizedBox(height: 20),

        // Understanding checkbox
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: CheckboxListTile(
            value: _understandChecked,
            onChanged: (value) {
              setState(() {
                _understandChecked = value ?? false;
              });
            },
            title: const Text(
              'I understand this is permanent and cannot be undone',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            activeColor: AppTheme.accessoryAccent,
            checkColor: Colors.white,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),

        const SizedBox(height: 24),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _understandChecked
                  ? () {
                      setState(() {
                        _currentStep = 1;
                        _errorMessage = null;
                      });
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accessoryAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDataItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Icon(Icons.delete_forever, size: 20, color: AppTheme.accessoryAccent.withOpacity(0.7)),
        ],
      ),
    );
  }

  // Step 1: Re-authentication
  Widget _buildReauthStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.lock, color: AppTheme.primaryAccent, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Confirm Your Identity',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        const Text(
          'For security, please enter your password to continue:',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: AppTheme.textSecondary),
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textSecondary),
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accessoryAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.accessoryAccent, width: 1.5),
            ),
            errorText: _errorMessage,
            errorStyle: const TextStyle(color: AppTheme.accessoryAccent),
          ),
          onSubmitted: (_) => _handleReauthenticate(),
        ),
        const SizedBox(height: 24),

        // Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _currentStep = 0;
                  _errorMessage = null;
                  _passwordController.clear();
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text('Back'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isProcessing ? null : _handleReauthenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accessoryAccent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Delete Account'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 2: Processing
  Widget _buildProcessingStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const CircularProgressIndicator(
            color: AppTheme.primaryAccent,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _progressMessage,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          'This may take a few moments...',
          style: TextStyle(fontSize: 14, color: AppTheme.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Step 3: Success
  Widget _buildSuccessStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryAccent.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            size: 64,
            color: AppTheme.secondaryAccent,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Account Deleted',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Your account and all associated data have been permanently deleted.',
          style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'You will be logged out in a moment...',
          style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleReauthenticate() async {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Re-authenticate
      await _deletionService.reauthenticateUser(_passwordController.text);

      // Step 2: Move to processing screen
      setState(() {
        _currentStep = 2;
        _progressMessage = 'Deleting your account...';
      });

      // Step 3: Delete account
      await _deletionService.deleteCurrentUserAccount();

      // Step 4: Show success
      setState(() {
        _currentStep = 3;
      });

      // Step 5: Auto-logout after 3 seconds
      await Future.delayed(const Duration(seconds: 3));

      // Logout (this will automatically redirect to login screen)
      await _authService.signOut();

      // Close dialog
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        if (_currentStep == 1) {
          // Re-auth error
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        } else {
          // Deletion error - show error dialog
          _currentStep = 1;
          _errorMessage = 'Deletion failed: ${e.toString().replaceAll('Exception: ', '')}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                if (_currentStep < 3) ...[
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.accessoryAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete_forever,
                          color: AppTheme.accessoryAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Delete Account',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Content based on current step
                if (_currentStep == 0)
                  _buildWarningStep()
                else if (_currentStep == 1)
                  _buildReauthStep()
                else if (_currentStep == 2)
                  _buildProcessingStep()
                else
                  _buildSuccessStep(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
