import 'package:flutter/material.dart';
import '../models/media_content.dart';
import '../theme/app_theme.dart';
import '../utils/responsive_layout.dart';

class ContentGrid extends StatelessWidget {
  final String title;
  final List<MediaContent> contentList;
  final Function(MediaContent) onContentSelected;

  const ContentGrid({
    super.key,
    required this.title,
    required this.contentList,
    required this.onContentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24.0, top: 24.0, bottom: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(
          height: _getGridHeight(context),
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            scrollDirection: Axis.horizontal,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(context),
              childAspectRatio: 0.7,
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
            ),
            itemCount: contentList.length,
            itemBuilder: (context, index) {
              return _buildContentItem(context, contentList[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContentItem(BuildContext context, MediaContent content) {
    return InkWell(
      onTap: () => onContentSelected(content),
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        children: [
          // Poster image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              content.imageUrl,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: AppTheme.cardColor,
                  child: const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                    ),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: AppTheme.cardColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryColor,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Info overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8.0),
                  bottomRight: Radius.circular(8.0),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    children: [
                      if (content.rating != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16.0,
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              content.rating!.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white,
                                  ),
                            ),
                            const SizedBox(width: 8.0),
                          ],
                        ),
                      if (content.year != null)
                        Text(
                          content.year!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
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
    );
  }

  // Helper methods for responsive layout
  double _getGridHeight(BuildContext context) {
    if (ResponsiveLayout.isTV(context)) {
      return 400.0;
    } else if (ResponsiveLayout.isDesktop(context)) {
      return 350.0;
    } else if (ResponsiveLayout.isTablet(context)) {
      return 300.0;
    } else {
      return 250.0;
    }
  }

  int _getCrossAxisCount(BuildContext context) {
    if (ResponsiveLayout.isTV(context)) {
      return 2;
    } else if (ResponsiveLayout.isDesktop(context)) {
      return 2;
    } else if (ResponsiveLayout.isTablet(context)) {
      return 1;
    } else {
      return 1;
    }
  }
} 