import 'package:flutter/material.dart';
import '../models/media_content.dart';
import '../theme/app_theme.dart';

class FeaturedContentCarousel extends StatefulWidget {
  final List<MediaContent> featuredContent;
  final Function(MediaContent) onContentSelected;

  const FeaturedContentCarousel({
    super.key,
    required this.featuredContent,
    required this.onContentSelected,
  });

  @override
  State<FeaturedContentCarousel> createState() => _FeaturedContentCarouselState();
}

class _FeaturedContentCarouselState extends State<FeaturedContentCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    
    // Auto-scroll timer
    Future.delayed(const Duration(seconds: 1), () {
      _startAutoScroll();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && widget.featuredContent.isNotEmpty) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= widget.featuredContent.length) {
          nextPage = 0;
        }
        
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 500, // Adjust height based on screen size
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.featuredContent.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final content = widget.featuredContent[index];
              return GestureDetector(
                onTap: () => widget.onContentSelected(content),
                child: _buildFeaturedItem(context, content, index == _currentIndex),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.featuredContent.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _pageController.animateToPage(
                entry.key,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key 
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryTextColor.withOpacity(0.5),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFeaturedItem(BuildContext context, MediaContent content, bool isActive) {
    return Stack(
      children: [
        // Background Image (replaced CachedNetworkImage with plain Image.network with error handling)
        SizedBox(
          width: double.infinity,
          child: Image.network(
            content.imageUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: AppTheme.cardColor,
                child: const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppTheme.cardColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: AppTheme.errorColor, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        content.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Gradient overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.9),
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
          ),
        ),
        
        // Content information
        Positioned(
          bottom: 40,
          left: 40,
          right: 40,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                content.title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              
              // Metadata
              Row(
                children: [
                  // Content type
                  Text(
                    content.contentType == 'tvShow' ? 'TV Show' : 'Movie',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Dot separator
                  Text(
                    '•',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  
                  // Genres
                  Text(
                    content.genres.join(', '),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                content.description,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // Watch Now button
                  ElevatedButton(
                    onPressed: () => widget.onContentSelected(content),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Accept Free Trial',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Add to Watchlist button
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.surfaceColor.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Add to watchlist logic
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
} 