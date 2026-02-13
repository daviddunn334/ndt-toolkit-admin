import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/defect_entry.dart';
import '../services/defect_service.dart';
import 'defect_detail_screen.dart';

class DefectHistoryScreen extends StatefulWidget {
  const DefectHistoryScreen({Key? key}) : super(key: key);

  @override
  State<DefectHistoryScreen> createState() => _DefectHistoryScreenState();
}

class _DefectHistoryScreenState extends State<DefectHistoryScreen> {
  final DefectService _defectService = DefectService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'Defect History',
          style: TextStyle(
            color: Color(0xFFEDF9FF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF242A33),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFEDF9FF)),
      ),
      body: StreamBuilder<List<DefectEntry>>(
        stream: _defectService.getUserDefectEntries(),
        builder: (context, snapshot) {
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
                    'Error loading defects',
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
              ),
            );
          }

          final defects = snapshot.data ?? [];

          if (defects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: const Color(0xFF7F8A96).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No Defects Logged',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEDF9FF),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start logging defects to see them here',
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
            itemCount: defects.length,
            itemBuilder: (context, index) {
              final defect = defects[index];
              return _buildDefectCard(context, defect);
            },
          );
        },
      ),
    );
  }

  Widget _buildDefectCard(BuildContext context, DefectEntry defect) {
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
                builder: (context) => DefectDetailScreen(defect: defect),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Defect Type Badge
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5BFF).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          defect.defectType,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6C5BFF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    _buildStatusBadge(defect),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFFAEBBC8),
                      size: 20,
                    ),
                  ],
                ),

                // Severity Badge (if analysis complete)
                if (defect.hasAnalysis && defect.severity != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getSeverityColor(defect.severity).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getSeverityColor(defect.severity).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getSeverityIcon(defect.severity),
                          size: 14,
                          color: _getSeverityColor(defect.severity),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          defect.severity!.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getSeverityColor(defect.severity),
                          ),
                        ),
                        if (defect.repairRequired == true) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.build_circle,
                            size: 14,
                            color: _getSeverityColor(defect.severity),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Measurements Row
                Row(
                  children: [
                    _buildMeasurement('L', defect.length, 'in'),
                    const SizedBox(width: 12),
                    _buildMeasurement('W', defect.width, 'in'),
                    const SizedBox(width: 12),
                    _buildMeasurement(
                      defect.isHardspot ? 'HB' : 'D',
                      defect.depth,
                      defect.isHardspot ? 'HB' : 'in',
                    ),
                  ],
                ),

                // Notes Preview (if exists)
                if (defect.notes?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242A33),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: Color(0xFFAEBBC8),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            defect.notes ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFAEBBC8),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
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
                const SizedBox(height: 10),

                // Timestamp
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF7F8A96),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      dateFormat.format(defect.localCreatedAt),
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
        ),
      ),
    );
  }

  Widget _buildStatusBadge(DefectEntry defect) {
    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (defect.isAnalyzing) {
      badgeColor = const Color(0xFF6C5BFF);
      badgeIcon = Icons.hourglass_empty;
      badgeText = 'Analyzing';
    } else if (defect.hasAnalysisError) {
      badgeColor = const Color(0xFFFE637E);
      badgeIcon = Icons.error_outline;
      badgeText = 'Error';
    } else if (defect.hasAnalysis) {
      badgeColor = const Color(0xFF00E5A8);
      badgeIcon = Icons.check_circle;
      badgeText = 'Complete';
    } else {
      badgeColor = const Color(0xFF7F8A96);
      badgeIcon = Icons.pending;
      badgeText = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'critical':
        return const Color(0xFFFE637E);
      case 'high':
        return const Color(0xFFF8B800);
      case 'medium':
        return const Color(0xFF6C5BFF);
      case 'low':
        return const Color(0xFF00E5A8);
      default:
        return const Color(0xFF7F8A96);
    }
  }

  IconData _getSeverityIcon(String? severity) {
    switch (severity?.toLowerCase()) {
      case 'critical':
        return Icons.crisis_alert_rounded;
      case 'high':
        return Icons.warning_rounded;
      case 'medium':
        return Icons.info_rounded;
      case 'low':
        return Icons.check_circle_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Widget _buildMeasurement(String label, double value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF242A33),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7F8A96),
              ),
            ),
            const SizedBox(height: 3),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEDF9FF),
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7F8A96),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
