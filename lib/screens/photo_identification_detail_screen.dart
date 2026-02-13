import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_identification.dart';
import '../services/defect_identifier_service.dart';
import '../services/analytics_service.dart';

class PhotoIdentificationDetailScreen extends StatefulWidget {
  final String photoId;

  const PhotoIdentificationDetailScreen({
    Key? key,
    required this.photoId,
  }) : super(key: key);

  @override
  State<PhotoIdentificationDetailScreen> createState() =>
      _PhotoIdentificationDetailScreenState();
}

class _PhotoIdentificationDetailScreenState
    extends State<PhotoIdentificationDetailScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();
  final DefectIdentifierService _service = DefectIdentifierService();

  @override
  void initState() {
    super.initState();
    _analyticsService.logEvent(
      name: 'photo_identification_viewed',
      parameters: {
        'photo_id': widget.photoId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'Photo Details',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('photo_identifications')
            .doc(widget.photoId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: const Color(0xFFFE637E).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Photo not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFFEDF9FF),
                    ),
                  ),
                ],
              ),
            );
          }

          final photo = PhotoIdentification.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo Display
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    photo.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: const Color(0xFF242A33),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Color(0xFF7F8A96),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Status Section
                if (photo.isAnalyzing)
                  _buildAnalyzingStatus()
                else if (photo.hasAnalysis)
                  _buildAnalysisResults(photo)
                else if (photo.hasAnalysisError)
                  _buildAnalysisError(photo)
                else
                  _buildPendingStatus(),

                const SizedBox(height: 24),

                // Metadata
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
                              color: const Color(0xFF6C5BFF).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              size: 20,
                              color: Color(0xFF6C5BFF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Photo Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFEDF9FF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Uploaded',
                        DateFormat('MMM dd, yyyy • hh:mm a')
                            .format(photo.localCreatedAt),
                      ),
                      if (photo.localAnalysisCompletedAt != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildInfoRow(
                          Icons.access_time,
                          'Analyzed',
                          DateFormat('MMM dd, yyyy • hh:mm a')
                              .format(photo.localAnalysisCompletedAt!),
                        ),
                      ],
                      if (photo.processingTime != null) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.05),
                                  Colors.white.withOpacity(0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildInfoRow(
                          Icons.timer_outlined,
                          'Processing Time',
                          '${photo.processingTime!.toStringAsFixed(1)} seconds',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFFAEBBC8),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8A96),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFFEDF9FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingStatus() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5BFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5BFF).withOpacity(0.2),
        ),
      ),
      child: const Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Analyzing Photo...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEDF9FF),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'AI is identifying the defect type. This may take 5-10 seconds.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFAEBBC8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatus() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.pending_outlined,
            size: 48,
            color: const Color(0xFF7F8A96).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Analysis Pending',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEDF9FF),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Photo analysis will begin shortly.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFAEBBC8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisError(PhotoIdentification photo) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFFE637E).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFE637E).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFE637E).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(0xFFFE637E),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEDF9FF),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            photo.errorMessage ?? 'An error occurred during photo analysis.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFAEBBC8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults(PhotoIdentification photo) {
    if (photo.matches == null || photo.matches!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'AI Identification Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEDF9FF),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Top ${photo.matches!.length} matches identified:',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFFAEBBC8),
          ),
        ),
        const SizedBox(height: 16),

        // Display all matches
        ...photo.matches!.asMap().entries.map((entry) {
          final index = entry.key;
          final match = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < photo.matches!.length - 1 ? 12 : 0),
            child: _buildMatchCard(match, index + 1),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMatchCard(match, int rank) {
    Color bgColor;
    Color borderColor;

    switch (match.confidence.toLowerCase()) {
      case 'high':
        bgColor = const Color(0xFF00E5A8);
        borderColor = const Color(0xFF00E5A8);
        break;
      case 'medium':
        bgColor = const Color(0xFFF8B800);
        borderColor = const Color(0xFFF8B800);
        break;
      case 'low':
        bgColor = const Color(0xFFFE637E);
        borderColor = const Color(0xFFFE637E);
        break;
      default:
        bgColor = const Color(0xFF7F8A96);
        borderColor = const Color(0xFF7F8A96);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank and Type
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5BFF),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  match.defectType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEDF9FF),
                  ),
                ),
              ),
              Text(
                match.confidenceEmoji,
                style: const TextStyle(fontSize: 26),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Confidence Score
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: bgColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 16,
                  color: bgColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${match.confidenceScore.toStringAsFixed(0)}% • ${match.confidence.toUpperCase()}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: bgColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.0),
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Visual Indicators
          if (match.visualIndicators.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00E5A8).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: Color(0xFF00E5A8),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Visual Indicators:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEDF9FF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...match.visualIndicators.map<Widget>((indicator) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Color(0xFF00E5A8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        indicator,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFAEBBC8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
          ],

          // Reasoning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF242A33),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5BFF).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        size: 16,
                        color: Color(0xFF6C5BFF),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'AI Reasoning:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEDF9FF),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  match.reasoning,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAEBBC8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A313B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Photo?',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this photo identification? This action cannot be undone.',
          style: TextStyle(
            color: Color(0xFFAEBBC8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFFAEBBC8)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFE637E),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await _service.deletePhotoIdentification(widget.photoId);
        
        _analyticsService.logEvent(
          name: 'photo_identification_deleted',
          parameters: {
            'photo_id': widget.photoId,
          },
        );
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo deleted successfully'),
              backgroundColor: const Color(0xFF00E5A8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting photo: $e'),
              backgroundColor: const Color(0xFFFE637E),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    }
  }
}
