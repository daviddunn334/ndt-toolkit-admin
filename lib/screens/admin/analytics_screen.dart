import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedTimeRange = 'Last 30 Days';
  final List<String> _timeRanges = [
    'Last 7 Days',
    'Last 30 Days',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Modern Header
          _buildModernHeader(),

          // Analytics Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Time Range Selector
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 24),

                  // Key Metrics Overview
                  _buildKeyMetrics(),
                  const SizedBox(height: 24),

                  // Test Activity & Report Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildTestActivity()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildReportStatus()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Equipment Usage & Popular Tests
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildEquipmentUsage()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildPopularTests()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Activity & Document Access
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildUserActivity()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildDocumentAccess()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.textPrimary.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics,
                color: AppTheme.primaryAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics Dashboard',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track NDT operations and system performance',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (MediaQuery.of(context).size.width < 1200)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.date_range, color: AppTheme.primaryAccent, size: 20),
          const SizedBox(width: 12),
          Text(
            'Time Period',
            style: AppTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryAccent.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: DropdownButton<String>(
              value: _selectedTimeRange,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: AppTheme.primaryAccent),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
              dropdownColor: AppTheme.surface,
              items: _timeRanges.map((range) {
                return DropdownMenuItem(
                  value: range,
                  child: Text(range),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeRange = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up,
                  color: AppTheme.secondaryAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Key Performance Indicators',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildMetricCard(
                'Tests Completed',
                '487',
                '+18.2%',
                Icons.check_circle,
                AppTheme.secondaryAccent,
                true,
              ),
              _buildMetricCard(
                'Active Users',
                '34',
                '+5.8%',
                Icons.people,
                Color(0xFF6C5BFF),
                true,
              ),
              _buildMetricCard(
                'Reports Generated',
                '312',
                '+12.4%',
                Icons.description,
                Color(0xFF2A9D8F),
                true,
              ),
              _buildMetricCard(
                'Failed Tests',
                '23',
                '-8.3%',
                Icons.warning,
                AppTheme.accessoryAccent,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String change,
      IconData icon, Color color, bool isPositive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (isPositive ? AppTheme.secondaryAccent : AppTheme.accessoryAccent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 12,
                      color: isPositive
                          ? AppTheme.secondaryAccent
                          : AppTheme.accessoryAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      change,
                      style: AppTheme.bodySmall.copyWith(
                        color: isPositive
                            ? AppTheme.secondaryAccent
                            : AppTheme.accessoryAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTheme.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.science, color: AppTheme.secondaryAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Test Activity',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSimpleBarChart([
            {'label': 'Mon', 'value': 0.6, 'count': '45'},
            {'label': 'Tue', 'value': 0.8, 'count': '62'},
            {'label': 'Wed', 'value': 0.5, 'count': '38'},
            {'label': 'Thu', 'value': 0.9, 'count': '71'},
            {'label': 'Fri', 'value': 0.7, 'count': '53'},
            {'label': 'Sat', 'value': 0.3, 'count': '22'},
            {'label': 'Sun', 'value': 0.2, 'count': '15'},
          ], AppTheme.secondaryAccent),
        ],
      ),
    );
  }

  Widget _buildReportStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assessment, color: Color(0xFF2A9D8F), size: 20),
              const SizedBox(width: 12),
              Text(
                'Report Status',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatusItem('Completed', '278', 89, AppTheme.secondaryAccent),
          const SizedBox(height: 12),
          _buildStatusItem('Pending Review', '24', 8, AppTheme.yellowAccent),
          const SizedBox(height: 12),
          _buildStatusItem('In Progress', '10', 3, Color(0xFF6C5BFF)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(
      String label, String count, int percentage, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              count,
              style: AppTheme.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEquipmentUsage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.precision_manufacturing,
                  color: AppTheme.yellowAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Equipment Usage',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEquipmentItem(
              'Ultrasonic Tester', '156 tests', 45, Color(0xFF6C5BFF)),
          const SizedBox(height: 12),
          _buildEquipmentItem('Hardness Tester', '142 tests', 41,
              AppTheme.secondaryAccent),
          const SizedBox(height: 12),
          _buildEquipmentItem(
              'Radiography Unit', '98 tests', 28, AppTheme.yellowAccent),
          const SizedBox(height: 12),
          _buildEquipmentItem('Magnetic Particle', '87 tests', 25,
              AppTheme.accessoryAccent),
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(
      String name, String tests, int percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tests,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularTests() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star, color: AppTheme.yellowAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                'Most Performed Tests',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTestItem('Hardness Testing', '142', Icons.science,
              AppTheme.secondaryAccent),
          const SizedBox(height: 12),
          _buildTestItem('Ultrasonic Testing', '98', Icons.graphic_eq,
              Color(0xFF6C5BFF)),
          const SizedBox(height: 12),
          _buildTestItem(
              'Visual Inspection', '76', Icons.visibility, Color(0xFF2A9D8F)),
          const SizedBox(height: 12),
          _buildTestItem('Magnetic Particle', '53', Icons.attractions,
              AppTheme.accessoryAccent),
        ],
      ),
    );
  }

  Widget _buildTestItem(String name, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people, color: Color(0xFF6C5BFF), size: 20),
              const SizedBox(width: 12),
              Text(
                'User Activity',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildActivityStat(
            'Active Today',
            '18',
            Icons.online_prediction,
            AppTheme.secondaryAccent,
          ),
          const SizedBox(height: 12),
          _buildActivityStat(
            'New This Month',
            '7',
            Icons.person_add,
            Color(0xFF6C5BFF),
          ),
          const SizedBox(height: 12),
          _buildActivityStat(
            'Avg. Session',
            '24 min',
            Icons.timer,
            AppTheme.yellowAccent,
          ),
          const SizedBox(height: 12),
          _buildActivityStat(
            'Total Logins',
            '892',
            Icons.login,
            Color(0xFF2A9D8F),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentAccess() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_open, color: Color(0xFF2A9D8F), size: 20),
              const SizedBox(width: 12),
              Text(
                'Document Access',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDocumentItem(
            'Safety Procedures',
            '89 views',
            Icons.security,
            AppTheme.accessoryAccent,
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            'Test Standards',
            '67 views',
            Icons.assignment,
            Color(0xFF6C5BFF),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            'Equipment Manuals',
            '54 views',
            Icons.book,
            AppTheme.yellowAccent,
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            'Training Materials',
            '43 views',
            Icons.school,
            AppTheme.secondaryAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(
      String name, String views, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.textPrimary.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  views,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBarChart(
      List<Map<String, dynamic>> data, Color color) {
    return SizedBox(
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item['count'],
                    style: AppTheme.bodySmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 140.0 * (item['value'] as double),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['label'],
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
