import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/news_update.dart';
import '../services/news_service.dart';

class NewsUpdatesSection extends StatelessWidget {
  const NewsUpdatesSection({super.key});

  NewsService get _newsService => NewsService();

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A313B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Icons.newspaper,
                        color: const Color(0xFFF8B800),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'News & Updates',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color(0xFFEDF9FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/news_updates');
                  },
                  icon: Icon(
                    Icons.arrow_forward,
                    color: const Color(0xFF6C5BFF),
                    size: 18,
                  ),
                  label: Text(
                    'View All',
                    style: TextStyle(
                      color: const Color(0xFF6C5BFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<NewsUpdate>>(
              future: _newsService.getRecentUpdates(limit: 4),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: const Color(0xFF6C5BFF),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: const Color(0xFFFE637E).withOpacity(0.6),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Error loading updates',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFFAEBBC8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final updates = snapshot.data ?? [];

                if (updates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            color: const Color(0xFF7F8A96).withOpacity(0.5),
                            size: 40,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No updates available',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(0xFFAEBBC8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: updates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final update = entry.value;
                    return Column(
                      children: [
                        _buildUpdateItem(update),
                        if (index < updates.length - 1)
                          Container(
                            height: 1,
                            margin: const EdgeInsets.symmetric(vertical: 16),
                            color: Colors.white.withOpacity(0.05),
                          ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateItem(NewsUpdate update) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: update.category.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: update.category.color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      update.category.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: update.category.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getTimeAgo(update.publishDate ?? update.createdDate),
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color(0xFF7F8A96),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                update.title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEDF9FF),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                update.description,
                style: TextStyle(
                  fontSize: 13,
                  color: const Color(0xFFAEBBC8),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
