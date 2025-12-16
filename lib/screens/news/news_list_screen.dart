import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/news_provider.dart';
import '../../utils/constants.dart';
import 'news_edit_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<NewsProvider>(context, listen: false).fetchNews()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Management', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NewsEditScreen()));
              },
            ),
          ),
        ],
      ),
      body: Consumer<NewsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
           if (provider.newsList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.article_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No news articles yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                ],
              ),
            );
          }
          
          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: provider.newsList.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final news = provider.newsList[index];
              return _buildNewsCard(context, news);
            },
          );
        },
      ),
    );
  }

  Widget _buildNewsCard(BuildContext context, Map<String, dynamic> news) {
    Color statusColor;
    switch (news['status']) {
      case 'Published': statusColor = Colors.green; break;
      case 'Draft': statusColor = Colors.grey; break;
      default: statusColor = Colors.orange;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 100,
                height: 70,
                color: Colors.grey[100],
                child: news['coverImage'] != null && 
                       (news['coverImage'].toString().startsWith('http') || news['coverImage'].toString().startsWith('/'))
                    ? Image.network(
                        news['coverImage'].toString().startsWith('/') 
                           ? '${Constants.baseUrl.replaceAll('/api', '')}${news['coverImage']}' // Construct full URL
                           : news['coverImage'],
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, color: Colors.grey),
                      ) 
                    : const Icon(Icons.image, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news['title'] ?? 'No Title', 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                       Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          news['status'] ?? 'Draft', 
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'by ${news['author']['username'] ?? 'Unknown'}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                       const SizedBox(width: 8),
                      Text(
                        '• ${news['views']} views',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.blue[600]), 
                  tooltip: 'Edit',
                  onPressed: () {
                    // Navigate to edit (not fully implemented with ID passing yet, simplistic for now)
                  }
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[400]), 
                  tooltip: 'Delete',
                  onPressed: () {
                     // Delete logic
                  }
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
