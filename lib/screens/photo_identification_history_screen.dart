import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/photo_identification.dart';
import '../services/defect_identifier_service.dart';
import 'photo_identification_detail_screen.dart';

class PhotoIdentificationHistoryScreen extends StatelessWidget {
  const PhotoIdentificationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = DefectIdentifierService();

    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'Photo History',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
      ),
      body: StreamBuilder<List<PhotoIdentification>>(
        stream: service.getPhotoIdentifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
              ),
            );
          }

          if (snapshot.hasError) {
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
                    'Error loading photos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDF9FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
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

          final photos = snapshot.data ?? [];

          if (photos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_camera_outlined,
                    size: 64,
                    color: const Color(0xFF7F8A96).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Photos Yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDF9FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Identified photos will appear here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFAEBBC8),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _buildPhotoCard(context, photo);
            },
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, PhotoIdentification photo) {
    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PhotoIdentificationDetailScreen(
                  photoId: photo.id,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photo.photoUrl,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF242A33),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.broken_image,
                          color: Color(0xFF7F8A96),
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      _buildStatusBadge(photo),
                      const SizedBox(height: 10),

                      // Top Match or Status Text
                      if (photo.hasAnalysis && photo.topMatch != null) ...[
                        Row(
                          children: [
                            Text(
                              photo.topMatch!.confidenceEmoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                photo.topMatch!.defectType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFEDF9FF),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${photo.topMatch!.confidenceScore.toStringAsFixed(0)}% confidence',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFAEBBC8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (photo.isAnalyzing) ...[
                        const Text(
                          'Analyzing photo...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6C5BFF),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else if (photo.hasAnalysisError) ...[
                        const Text(
                          'Analysis failed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFE637E),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Waiting to analyze...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF7F8A96),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Timestamp
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 13,
                            color: Color(0xFF7F8A96),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            dateFormat.format(photo.localCreatedAt),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF7F8A96),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFAEBBC8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PhotoIdentification photo) {
    Color bgColor;
    Color borderColor;
    String label;
    IconData icon;

    if (photo.isAnalyzing) {
      bgColor = const Color(0xFF6C5BFF);
      borderColor = const Color(0xFF6C5BFF);
      label = 'Analyzing';
      icon = Icons.sync;
    } else if (photo.hasAnalysis) {
      bgColor = const Color(0xFF00E5A8);
      borderColor = const Color(0xFF00E5A8);
      label = 'Complete';
      icon = Icons.check_circle;
    } else if (photo.hasAnalysisError) {
      bgColor = const Color(0xFFFE637E);
      borderColor = const Color(0xFFFE637E);
      label = 'Error';
      icon = Icons.error;
    } else {
      bgColor = const Color(0xFF7F8A96);
      borderColor = const Color(0xFF7F8A96);
      label = 'Pending';
      icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: bgColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: bgColor,
            ),
          ),
        ],
      ),
    );
  }
}
