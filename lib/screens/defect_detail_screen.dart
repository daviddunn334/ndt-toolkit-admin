import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../models/defect_entry.dart';
import '../services/defect_service.dart';
import '../services/analytics_service.dart';

class DefectDetailScreen extends StatefulWidget {
  final DefectEntry defect;

  const DefectDetailScreen({Key? key, required this.defect}) : super(key: key);

  @override
  State<DefectDetailScreen> createState() => _DefectDetailScreenState();
}

class _DefectDetailScreenState extends State<DefectDetailScreen> {
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  void initState() {
    super.initState();
    _analyticsService.logDefectViewed(
      widget.defect.id,
      widget.defect.hasAnalysis,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • hh:mm a');
    
    final defect = widget.defect;
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      appBar: AppBar(
        title: const Text(
          'Defect Details',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Defect Type Header
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF2A313B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C5BFF).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: Color(0xFF6C5BFF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    defect.defectType,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEDF9FF),
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5A8).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00E5A8).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Color(0xFF00E5A8),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Logged',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00E5A8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Measurements Section
            const Text(
              'Measurements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEDF9FF),
              ),
            ),
            const SizedBox(height: 12),
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
                children: [
                  _buildMeasurementRow('Length', defect.length, 'inches'),
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
                  _buildMeasurementRow('Width', defect.width, 'inches'),
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
                  _buildMeasurementRow(
                    defect.isHardspot ? 'Max HB' : 'Depth',
                    defect.depth,
                    defect.isHardspot ? 'HB' : 'inches',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Notes Section
            if (defect.notes?.isNotEmpty ?? false) ...[
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEDF9FF),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A313B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  defect.notes ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFAEBBC8),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Metadata Section
            const Text(
              'Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEDF9FF),
              ),
            ),
            const SizedBox(height: 12),
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
                children: [
                  _buildInfoRow(
                    Icons.straighten,
                    'Pipe OD',
                    '${defect.pipeOD.toStringAsFixed(3)} in',
                  ),
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
                    Icons.width_normal,
                    'Pipe NWT',
                    '${defect.pipeNWT.toStringAsFixed(3)} in',
                  ),
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
                    Icons.business,
                    'Client',
                    defect.clientName.toUpperCase(),
                  ),
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
                    Icons.calendar_today,
                    'Logged On',
                    dateFormat.format(defect.localCreatedAt),
                  ),
                  if (defect.localUpdatedAt != defect.localCreatedAt) ...[
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
                      Icons.update,
                      'Last Updated',
                      dateFormat.format(defect.localUpdatedAt),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            // AI Analysis Section
            if (defect.isAnalyzing)
              _buildAnalyzingStatus(defect)
            else if (defect.hasAnalysis)
              _buildAnalysisResults(defect)
            else if (defect.hasAnalysisError)
              _buildAnalysisError(context, defect)
            else
              _buildNoAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(String label, double value, String unit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFAEBBC8),
          ),
        ),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C5BFF),
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7F8A96),
                ),
              ),
            ],
          ),
        ),
      ],
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

  Widget _buildAnalyzingStatus(DefectEntry defect) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5BFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C5BFF).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5BFF)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Analyzing Defect...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEDF9FF),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'AI is evaluating this defect against procedure standards. This may take 10-30 seconds.',
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

  Widget _buildAnalysisResults(DefectEntry defect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        const Text(
          'AI Analysis Results',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFEDF9FF),
          ),
        ),
        const SizedBox(height: 12),

        // Severity Badge
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getSeverityColor(defect.severity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getSeverityColor(defect.severity).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSeverityColor(defect.severity).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getSeverityIcon(defect.severity),
                  size: 32,
                  color: _getSeverityColor(defect.severity),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Severity: ${defect.severity?.toUpperCase() ?? 'UNKNOWN'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getSeverityColor(defect.severity),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          defect.repairRequired == true
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          size: 18,
                          color: defect.repairRequired == true
                              ? const Color(0xFFF8B800)
                              : const Color(0xFF00E5A8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          defect.repairRequired == true
                              ? 'Repair Required'
                              : 'No Repair Needed',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: defect.repairRequired == true
                                ? const Color(0xFFF8B800)
                                : const Color(0xFF00E5A8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Repair Method (if required)
        if (defect.repairRequired == true && defect.repairType != null) ...[
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
                        Icons.build_circle_outlined,
                        size: 20,
                        color: Color(0xFFF8B800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Recommended Repair Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFAEBBC8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  defect.repairType!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFEDF9FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // AI Recommendations
        if (defect.aiRecommendations != null) ...[
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
                        Icons.psychology_outlined,
                        size: 20,
                        color: Color(0xFF6C5BFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Analysis & Recommendations',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFAEBBC8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  defect.aiRecommendations!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFFAEBBC8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Procedure Reference
        if (defect.procedureReference != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5BFF).withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF6C5BFF).withOpacity(0.2),
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
                        Icons.description_outlined,
                        size: 20,
                        color: Color(0xFF6C5BFF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Procedure Reference',
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
                  defect.procedureReference!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFAEBBC8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Confidence Level
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 24,
                color: _getConfidenceColor(defect.aiConfidence),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Confidence',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7F8A96),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      defect.aiConfidence?.toUpperCase() ?? 'UNKNOWN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getConfidenceColor(defect.aiConfidence),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (defect.analysisCompletedAt != null) ...[
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: Color(0xFF7F8A96),
              ),
              const SizedBox(width: 6),
              Text(
                'Analyzed ${DateFormat('MMM dd, yyyy • hh:mm a').format(defect.analysisCompletedAt!.toLocal())}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF7F8A96),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAnalysisError(BuildContext context, DefectEntry defect) {
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
            defect.errorMessage ?? 'An error occurred during AI analysis.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFFAEBBC8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _retryAnalysis(context),
            icon: const Icon(Icons.refresh, size: 20),
            label: const Text('Retry Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE637E),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoAnalysis() {
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
            'AI analysis will begin shortly after defect creation.',
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

  Color _getConfidenceColor(String? confidence) {
    switch (confidence?.toLowerCase()) {
      case 'high':
        return const Color(0xFF00E5A8);
      case 'medium':
        return const Color(0xFFF8B800);
      case 'low':
        return const Color(0xFFFE637E);
      default:
        return const Color(0xFF7F8A96);
    }
  }

  Future<void> _retryAnalysis(BuildContext context) async {
    await _analyticsService.logDefectAnalysisRetried(widget.defect.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Retry functionality coming soon'),
        backgroundColor: const Color(0xFF6C5BFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
          'Delete Defect?',
          style: TextStyle(color: Color(0xFFEDF9FF)),
        ),
        content: const Text(
          'Are you sure you want to delete this defect entry? This action cannot be undone.',
          style: TextStyle(color: Color(0xFFAEBBC8)),
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
        await DefectService().deleteDefectEntry(widget.defect.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Defect deleted successfully'),
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
              content: Text('Error deleting defect: $e'),
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
