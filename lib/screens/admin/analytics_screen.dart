import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../services/admin_metrics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final UserService _userService = UserService();
  final AdminMetricsService _metricsService = AdminMetricsService();

  late Future<_AdminAnalyticsSnapshot> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _loadAnalytics();
  }

  Future<_AdminAnalyticsSnapshot> _loadAnalytics() async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final users = await _userService.getAllUsers();
    final metrics = await _metricsService.getMetrics();

    final newUsers7d = users.where((user) => user.createdAt.isAfter(sevenDaysAgo)).length;
    final newUsers30d = users.where((user) => user.createdAt.isAfter(thirtyDaysAgo)).length;
    final adminUsers = users.where((user) => user.isAdmin).length;

    return _AdminAnalyticsSnapshot(
      totalUsers: users.length,
      adminUsers: adminUsers,
      newUsers7d: newUsers7d,
      newUsers30d: newUsers30d,
      metrics: metrics,
      lastUpdated: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<_AdminAnalyticsSnapshot>(
              future: _analyticsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error);
                }

                final data = snapshot.data;
                if (data == null) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      _analyticsFuture = _loadAnalytics();
                    });
                    await _analyticsFuture;
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildKpiRow(data),
                      const SizedBox(height: 24),
                      _buildOverviewRow(data),
                      const SizedBox(height: 24),
                      _buildCostReliability(data),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
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
                    'Analytics',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fresh metrics from live operational data',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
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

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primaryAccent),
    );
  }

  Widget _buildErrorState(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.accessoryAccent),
            const SizedBox(height: 12),
            Text(
              'Unable to load analytics right now.',
              style: AppTheme.titleMedium.copyWith(color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              error?.toString() ?? 'Unknown error',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _analyticsFuture = _loadAnalytics();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No analytics available yet.',
        style: AppTheme.titleMedium.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildKpiRow(_AdminAnalyticsSnapshot data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 4 : 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildKpiCard(
          title: 'Total Users',
          value: data.totalUsers.toString(),
          subtitle: '${data.adminUsers} admins',
          icon: Icons.people,
          color: AppTheme.primaryAccent,
        ),
        _buildKpiCard(
          title: 'New Users (7d)',
          value: data.newUsers7d.toString(),
          subtitle: '${data.newUsers30d} in 30d',
          icon: Icons.person_add_alt,
          color: AppTheme.secondaryAccent,
        ),
        _buildKpiCard(
          title: 'Storage Uploads',
          value: _metricInt(data.metrics, 'storage_uploads_total').toString(),
          subtitle: 'All sources',
          icon: Icons.cloud_upload,
          color: const Color(0xFF2A9D8F),
        ),
        _buildKpiCard(
          title: 'Function Calls',
          value: _metricInt(data.metrics, 'function_calls_total').toString(),
          subtitle: '${_metricInt(data.metrics, 'function_calls_failed')} failed',
          icon: Icons.functions,
          color: AppTheme.yellowAccent,
        ),
      ],
    );
  }

  Widget _buildOverviewRow(_AdminAnalyticsSnapshot data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'User Snapshot',
            icon: Icons.group,
            items: [
              _SummaryItem('Total users', data.totalUsers.toString()),
              _SummaryItem('Admins', data.adminUsers.toString()),
              _SummaryItem('New users (7d)', data.newUsers7d.toString()),
              _SummaryItem('New users (30d)', data.newUsers30d.toString()),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildSummaryCard(
            title: 'Reliability Snapshot',
            icon: Icons.health_and_safety,
            items: [
              _SummaryItem('Error events', _metricInt(data.metrics, 'error_events_total').toString()),
              _SummaryItem('Function failures', _metricInt(data.metrics, 'function_calls_failed').toString()),
              _SummaryItem('Crash-free users', 'See Crashlytics'),
              _SummaryItem('Last updated', _formatTimestamp(data.lastUpdated)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostReliability(_AdminAnalyticsSnapshot data) {
    return _buildSummaryCard(
      title: 'Cost & Reliability Signals',
      icon: Icons.monitor_heart,
      child: Column(
        children: [
          _buildStatusPill(
            'Storage uploads',
            _metricInt(data.metrics, 'storage_uploads_total'),
            AppTheme.primaryAccent,
          ),
          const SizedBox(height: 8),
          _buildStatusPill(
            'Function calls',
            _metricInt(data.metrics, 'function_calls_total'),
            AppTheme.yellowAccent,
          ),
          const SizedBox(height: 8),
          _buildStatusPill(
            'Error events',
            _metricInt(data.metrics, 'error_events_total'),
            AppTheme.accessoryAccent,
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 22),
              const Spacer(),
              Icon(Icons.trending_up, color: color.withOpacity(0.6), size: 18),
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
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    List<_SummaryItem>? items,
    Widget? child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.textPrimary.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryAccent, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTheme.titleMedium.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (items != null)
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildSummaryRow(item.label, item.value),
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ),
          Text(
            count.toString(),
            style: AppTheme.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  int _metricInt(Map<String, dynamic> metrics, String key) {
    final value = metrics[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    return 0;
  }

  String _formatTimestamp(DateTime value) {
    final minutes = value.minute.toString().padLeft(2, '0');
    return '${value.hour}:$minutes';
  }
}

class _AdminAnalyticsSnapshot {
  final int totalUsers;
  final int adminUsers;
  final int newUsers7d;
  final int newUsers30d;
  final Map<String, dynamic> metrics;
  final DateTime lastUpdated;

  _AdminAnalyticsSnapshot({
    required this.totalUsers,
    required this.adminUsers,
    required this.newUsers7d,
    required this.newUsers30d,
    required this.metrics,
    required this.lastUpdated,
  });
}

class _SummaryItem {
  final String label;
  final String value;

  _SummaryItem(this.label, this.value);
}