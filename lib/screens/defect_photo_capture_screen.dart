import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../services/defect_identifier_service.dart';
import '../services/analytics_service.dart';

/// Screen for capturing or selecting a defect photo
class DefectPhotoCaptureScreen extends StatefulWidget {
  const DefectPhotoCaptureScreen({Key? key}) : super(key: key);

  @override
  State<DefectPhotoCaptureScreen> createState() => _DefectPhotoCaptureScreenState();
}

class _DefectPhotoCaptureScreenState extends State<DefectPhotoCaptureScreen> {
  final ImagePicker _picker = ImagePicker();
  final DefectIdentifierService _identifierService = DefectIdentifierService();
  final AnalyticsService _analyticsService = AnalyticsService();
  
  File? _selectedImage;
  XFile? _selectedXFile;
  bool _isProcessing = false;

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (photo != null) {
        setState(() {
          _selectedXFile = photo;
          if (!kIsWeb) {
            _selectedImage = File(photo.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: const Color(0xFFFE637E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        setState(() {
          _selectedXFile = image;
          if (!kIsWeb) {
            _selectedImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: const Color(0xFFFE637E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  Future<void> _identifyDefect() async {
    if (_selectedImage == null && _selectedXFile == null) return;

    setState(() => _isProcessing = true);

    try {
      await _analyticsService.logDefectPhotoIdentificationStarted();

      final docId = await _identifierService.processDefectPhoto(
        kIsWeb ? _selectedXFile! : _selectedImage!,
      );

      print('Photo identification created: $docId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Photo uploaded! Check Photo History for results in 5-10 seconds.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00E5A8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      await _analyticsService.logDefectPhotoIdentificationFailed(e.toString());

      if (mounted) {
        setState(() => _isProcessing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: const Color(0xFFFE637E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'Capture Defect Photo',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
      ),
      body: _isProcessing
          ? _buildProcessingView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Photo preview or placeholder
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A313B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: (_selectedImage != null || _selectedXFile != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: kIsWeb
                                ? Image.network(
                                    _selectedXFile!.path,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5BFF).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo,
                                    size: 64,
                                    color: Color(0xFF6C5BFF),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No photo selected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFAEBBC8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Camera button
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt, size: 22),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Gallery button
                  OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library, size: 22),
                    label: const Text('Upload from Gallery'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6C5BFF),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(
                        color: Color(0xFF6C5BFF),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),

                  if (_selectedImage != null || _selectedXFile != null) ...[
                    const SizedBox(height: 24),
                    Container(
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.1),
                            Colors.white.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Identify button
                    ElevatedButton.icon(
                      onPressed: _identifyDefect,
                      icon: const Icon(Icons.psychology, size: 22),
                      label: const Text('Identify Defect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E5A8),
                        foregroundColor: const Color(0xFF1E232A),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Retake button
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _selectedXFile = null;
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retake Photo'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFAEBBC8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Tips section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A313B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8B800).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.lightbulb_outline,
                                color: Color(0xFFF8B800),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Tips for Best Results',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEDF9FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildTip('Good lighting (natural light is best)'),
                        _buildTip('Close-up view of the defect'),
                        _buildTip('Clear focus on the defect area'),
                        _buildTip('Include some context around the defect'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProcessingView() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5BFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Uploading Photo...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEDF9FF),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your photo is being uploaded for AI analysis',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFAEBBC8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This will only take a few seconds...',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF7F8A96),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF00E5A8),
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAEBBC8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
