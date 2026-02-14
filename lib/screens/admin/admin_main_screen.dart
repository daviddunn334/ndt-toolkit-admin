import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/admin_drawer.dart';
import 'user_management_screen.dart';
// import 'news_editor_screen.dart'; // REMOVED - Will be rebuilt
import 'feedback_management_screen.dart';
import 'pdf_management_screen.dart';
import 'employee_management_screen.dart';
import 'analytics_screen.dart';
import '../../models/news_update.dart';
import '../../services/news_service.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;
  final NewsService _newsService = NewsService();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop layout (width >= 1200px)
        if (constraints.maxWidth >= 1200) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 280,
                  child: AdminDrawer(
                    selectedIndex: _selectedIndex,
                    onItemSelected: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          );
        }

        // Mobile layout
        return Scaffold(
          body: _buildBody(),
          drawer: AdminDrawer(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildAnalytics();
      case 1:
        return _buildNewsManagement();
      case 2:
        return _buildUserManagement();
      case 3:
        return _buildEmployeeManagement();
      case 4:
        return _buildFeedbackManagement();
      case 5:
        return _buildPdfManagement();
      case 6:
        return _buildCreatePost();
      case 7:
        return _buildDrafts();
      case 8:
        return _buildPublished();
      default:
        return _buildAnalytics();
    }
  }

  Widget _buildNewsManagement() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // Modern Header
          _buildNewsManagementHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Overview
                  _buildNewsStatisticsSection(),
                  const SizedBox(height: 32),

                  // Search and Filters
                  _buildNewsSearchAndFilters(),
                  const SizedBox(height: 32),

                  // News List
                  _buildNewsListSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserManagement() {
    return const UserManagementScreen();
  }

  Widget _buildFeedbackManagement() {
    return const FeedbackManagementScreen();
  }

  Widget _buildPdfManagement() {
    return const PdfManagementScreen();
  }

  Widget _buildEmployeeManagement() {
    return const EmployeeManagementScreen();
  }

  Widget _buildAnalytics() {
    return const AnalyticsScreen();
  }

  Widget _buildCreatePost() {
    // REMOVED - Will be rebuilt
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text('Create Post - Coming Soon', style: AppTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildDrafts() {
    return _buildFilteredPosts('Drafts', isDraft: true);
  }

  Widget _buildPublished() {
    return _buildFilteredPosts('Published', isPublished: true);
  }

  Widget _buildFilteredPosts(String title, {bool? isDraft, bool? isPublished}) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 1200,
      ),
      body: const Center(
        child: Text('Filtered Posts - Coming Soon'),
      ),
    );
  }

  Widget _buildEmptyState({
    String title = 'No posts found',
    String subtitle = 'Create your first post to get started',
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.titleMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedIndex = 6; // Navigate to Create Post
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Post'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(NewsUpdate update) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: ListTile(
        title: Text(update.title),
        subtitle: Text(update.description),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }

  Widget _buildNewsManagementHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.05),
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
                color: AppTheme.primaryAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryAccent.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.article,
                color: AppTheme.primaryAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'News Management',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create, edit, and manage news posts and updates',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => _selectedIndex = 6),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Create Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            if (MediaQuery.of(context).size.width < 1200)
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryAccent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryAccent,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Content Overview', Icons.analytics),
          const SizedBox(height: 20),
          FutureBuilder<Map<String, int>>(
            future: _getQuickStats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ?? {};
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildStatCard(
                    'Total Posts',
                    '${stats['totalPosts'] ?? 0}',
                    Icons.article,
                    AppTheme.primaryAccent,
                  ),
                  _buildStatCard(
                    'Published',
                    '${stats['publishedPosts'] ?? 0}',
                    Icons.public,
                    AppTheme.secondaryAccent,
                  ),
                  _buildStatCard(
                    'Drafts',
                    '${stats['draftPosts'] ?? 0}',
                    Icons.drafts,
                    AppTheme.yellowAccent,
                  ),
                  _buildStatCard(
                    'Total Views',
                    '${stats['totalViews'] ?? 0}',
                    Icons.visibility,
                    AppTheme.accessoryAccent,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Search & Filters', Icons.search),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search posts...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsListSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recent Posts', Icons.list),
          const SizedBox(height: 20),
          StreamBuilder<List<NewsUpdate>>(
            stream: _newsService.getAllUpdates(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading posts',
                          style: AppTheme.titleMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please try again later',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final updates = snapshot.data ?? [];

              if (updates.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: updates.length,
                itemBuilder: (context, index) {
                  return _buildNewsCard(updates[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard(NewsUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
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
                  color: update.category.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: update.category.color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  update.icon,
                  color: update.category.color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update.title,
                      style: AppTheme.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStatusChip(update),
                        const SizedBox(width: 8),
                        Text(
                          update.category.displayName,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleNewsAction(value, update),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 16),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            update.description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${update.viewCount} views',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.schedule,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(update.createdDate),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(NewsUpdate update) {
    Color color;
    String label;

    if (update.isDraft) {
      color = Colors.orange;
      label = 'Draft';
    } else if (update.isPublished) {
      color = Colors.green;
      label = 'Published';
    } else {
      color = Colors.grey;
      label = 'Scheduled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTheme.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleNewsAction(String action, NewsUpdate update) {
    switch (action) {
      case 'edit':
        // REMOVED - Will be rebuilt
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('News editor will be rebuilt')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(update);
        break;
    }
  }

  void _showDeleteConfirmation(NewsUpdate update) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: Text('Are you sure you want to delete "${update.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _newsService.deleteUpdate(update.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting post: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<Map<String, int>> _getQuickStats() async {
    try {
      final allUpdates = await _newsService.getAllUpdates().first;
      final publishedCount = allUpdates.where((u) => u.isPublished).length;
      final draftCount = allUpdates.where((u) => u.isDraft).length;
      final totalViews = await _newsService.getTotalViewCount();

      return {
        'totalPosts': allUpdates.length,
        'publishedPosts': publishedCount,
        'draftPosts': draftCount,
        'totalViews': totalViews,
        'totalReports': 147,
        'activeUsers': 89,
      };
    } catch (e) {
      return {
        'totalPosts': 0,
        'publishedPosts': 0,
        'draftPosts': 0,
        'totalViews': 0,
        'totalReports': 147,
        'activeUsers': 89,
      };
    }
  }
}
