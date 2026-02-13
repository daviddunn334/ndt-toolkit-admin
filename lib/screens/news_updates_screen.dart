import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/news_update.dart';
import '../services/news_service.dart';
import '../services/user_service.dart';
import '../widgets/app_header.dart';
import '../widgets/offline_indicator.dart';

class NewsUpdatesScreen extends StatefulWidget {
  const NewsUpdatesScreen({super.key});

  @override
  State<NewsUpdatesScreen> createState() => _NewsUpdatesScreenState();
}

class _NewsUpdatesScreenState extends State<NewsUpdatesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  final NewsService _newsService = NewsService();
  final UserService _userService = UserService();

  NewsCategory? _selectedCategory;
  String _searchQuery = '';
  NewsPriority? _selectedPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline indicator
            const OfflineIndicator(
              message: 'News updates require internet connection.',
            ),
            if (MediaQuery.of(context).size.width >= 1200)
              const AppHeader(
                title: 'News & Updates',
                subtitle: 'Stay informed with latest company news and industry updates',
                icon: Icons.newspaper,
              ),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title section for mobile
                        if (MediaQuery.of(context).size.width < 1200)
                          Container(
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A313B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C5BFF),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.newspaper_rounded,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'News & Updates',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFFEDF9FF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Stay informed with the latest updates',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: const Color(0xFFAEBBC8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Category tabs section
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.only(bottom: 20),
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
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFEDF9FF),
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 38,
                                child: TabBar(
                                  controller: _tabController,
                                  indicatorColor: const Color(0xFF6C5BFF),
                                  labelColor: const Color(0xFFEDF9FF),
                                  unselectedLabelColor: const Color(0xFF7F8A96),
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    color: const Color(0xFF6C5BFF).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF6C5BFF).withOpacity(0.3),
                                    ),
                                  ),
                                  dividerColor: Colors.transparent,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  unselectedLabelStyle: TextStyle(
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                  tabs: [
                                    const Tab(text: 'All'),
                                    Tab(text: NewsCategory.company.displayName),
                                    Tab(text: NewsCategory.industry.displayName),
                                    Tab(text: NewsCategory.protocol.displayName),
                                    Tab(text: NewsCategory.training.displayName),
                                  ],
                                  onTap: (index) {
                                    setState(() {
                                      _selectedCategory =
                                          index == 0 ? null : NewsCategory.values[index - 1];
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Content area  
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Search/filters section
                                _buildSearchAndFilters(),
                                const SizedBox(height: 16),
                                
                                // News content
                                _buildContentArea(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search & Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFEDF9FF),
            ),
          ),
          const SizedBox(height: 16),

          // Search Bar and Priority Filter
          if (MediaQuery.of(context).size.width > 800)
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildSearchField(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPriorityFilter(),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 12),
                _buildPriorityFilter(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF242A33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _searchQuery.isNotEmpty 
              ? const Color(0xFF6C5BFF).withOpacity(0.3)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: TextField(
        style: TextStyle(color: const Color(0xFFEDF9FF)),
        decoration: InputDecoration(
          hintText: 'Search news and updates...',
          hintStyle: TextStyle(color: const Color(0xFF7F8A96)),
          prefixIcon: Icon(Icons.search, color: const Color(0xFF7F8A96)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.clear, color: const Color(0xFF7F8A96)),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildPriorityFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF242A33),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: DropdownButton<NewsPriority>(
        value: _selectedPriority,
        hint: Text(
          'Filter by priority',
          style: TextStyle(color: const Color(0xFF7F8A96)),
        ),
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF2A313B),
        style: TextStyle(color: const Color(0xFFEDF9FF)),
        icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF7F8A96)),
        items: [
          DropdownMenuItem(
            value: null,
            child: Text(
              'All Priorities',
              style: TextStyle(color: const Color(0xFFEDF9FF)),
            ),
          ),
          ...NewsPriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: priority.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    priority.displayName,
                    style: TextStyle(color: const Color(0xFFEDF9FF)),
                  ),
                ],
              ),
            );
          }),
        ],
        onChanged: (value) {
          setState(() {
            _selectedPriority = value;
          });
        },
      ),
    );
  }

  Widget _buildContentArea() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8B800).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: const Color(0xFFF8B800),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Latest Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEDF9FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            constraints: const BoxConstraints(
              minHeight: 300,
              maxHeight: 600,
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewsTab(null),
                _buildNewsTab(NewsCategory.company),
                _buildNewsTab(NewsCategory.industry),
                _buildNewsTab(NewsCategory.protocol),
                _buildNewsTab(NewsCategory.training),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsTab(NewsCategory? category) {
    return StreamBuilder<List<NewsUpdate>>(
      stream: _newsService.getPublishedUpdates(category: category),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF6C5BFF),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState();
        }

        final allUpdates = snapshot.data ?? [];
        final filteredUpdates = _filterUpdates(allUpdates);

        if (filteredUpdates.isEmpty) {
          return _buildEmptyState(category);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: filteredUpdates.length,
          itemBuilder: (context, index) {
            return _buildUpdateCard(filteredUpdates[index]);
          },
        );
      },
    );
  }

  Widget _buildUpdateCard(NewsUpdate update) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF242A33),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: InkWell(
        onTap: () => _showUpdateDetails(update),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category and priority
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: update.category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: update.category.color.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      update.icon,
                      color: update.category.color,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildCategoryChip(update.category),
                            const SizedBox(width: 8),
                            if (update.priority != NewsPriority.normal)
                              _buildPriorityChip(update.priority),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(update.publishDate ?? update.createdDate),
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF7F8A96),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (update.type != NewsType.update)
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        update.type.icon,
                        color: const Color(0xFFAEBBC8),
                        size: 14,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                update.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEDF9FF),
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                update.description,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFFAEBBC8),
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 14),

              // Footer with metadata
              Row(
                children: [
                  if (update.authorName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: const Color(0xFF7F8A96),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      update.authorName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF7F8A96),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  if (update.viewCount > 0) ...[
                    Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: const Color(0xFF00E5A8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${update.viewCount} views',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF00E5A8),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (update.links.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8B800).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            size: 12,
                            color: const Color(0xFFF8B800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${update.links.length}',
                            style: TextStyle(
                              fontSize: 11,
                              color: const Color(0xFFF8B800),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(NewsCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: category.color.withOpacity(0.3),
        ),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(
          fontSize: 11,
          color: category.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPriorityChip(NewsPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: priority.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: priority.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: priority.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            priority.displayName,
            style: TextStyle(
              fontSize: 11,
              color: priority.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 56,
            color: const Color(0xFFFE637E).withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading updates',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEDF9FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF7F8A96),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5BFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(NewsCategory? category) {
    String title = 'No updates found';
    String subtitle = 'Check back later for new updates';

    if (_searchQuery.isNotEmpty) {
      title = 'No results found';
      subtitle = 'Try adjusting your search terms';
    } else if (category != null) {
      title = 'No ${category.displayName.toLowerCase()} updates';
      subtitle = 'No updates available in this category yet';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 56,
            color: const Color(0xFF7F8A96).withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFEDF9FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: const Color(0xFF7F8A96),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<NewsUpdate> _filterUpdates(List<NewsUpdate> updates) {
    List<NewsUpdate> filtered = updates;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((update) {
        return update.title.toLowerCase().contains(query) ||
            update.description.toLowerCase().contains(query);
      }).toList();
    }

    // Filter by priority
    if (_selectedPriority != null) {
      filtered = filtered
          .where((update) => update.priority == _selectedPriority)
          .toList();
    }

    return filtered;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showUpdateDetails(NewsUpdate update) {
    // Increment view count
    if (update.id != null) {
      _newsService.incrementViewCount(update.id!);
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          decoration: BoxDecoration(
            color: const Color(0xFF2A313B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.05),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: update.category.color.withOpacity(0.15),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: update.category.color.withOpacity(0.3),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: update.category.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        update.icon,
                        color: update.category.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            update.category.displayName,
                            style: TextStyle(
                              color: update.category.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            update.title,
                            style: TextStyle(
                              color: const Color(0xFFEDF9FF),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: const Color(0xFFEDF9FF)),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata
                      Row(
                        children: [
                          if (update.priority != NewsPriority.normal) ...[
                            _buildPriorityChip(update.priority),
                            const SizedBox(width: 8),
                          ],
                          if (update.type != NewsType.update) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    update.type.icon,
                                    size: 12,
                                    color: const Color(0xFFAEBBC8),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    update.type.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(0xFFAEBBC8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            _formatDate(
                                update.publishDate ?? update.createdDate),
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF7F8A96),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Description
                      Text(
                        update.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFAEBBC8),
                          height: 1.6,
                        ),
                      ),

                      // Links
                      if (update.links.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Related Links',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFEDF9FF),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...update.links.map((link) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C5BFF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFF6C5BFF).withOpacity(0.3),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Opening: $link'),
                                      backgroundColor: const Color(0xFF2A313B),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.link,
                                      size: 16,
                                      color: const Color(0xFF6C5BFF),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        link,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: const Color(0xFF6C5BFF),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.open_in_new,
                                      size: 14,
                                      color: const Color(0xFF6C5BFF),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],

                      // Footer
                      const SizedBox(height: 24),
                      Container(
                        height: 1,
                        color: Colors.white.withOpacity(0.05),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (update.authorName != null) ...[
                            Icon(
                              Icons.person_outline,
                              size: 16,
                              color: const Color(0xFF7F8A96),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'By ${update.authorName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFF7F8A96),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                          Icon(
                            Icons.visibility_outlined,
                            size: 16,
                            color: const Color(0xFF00E5A8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${update.viewCount + 1} views',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF00E5A8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
