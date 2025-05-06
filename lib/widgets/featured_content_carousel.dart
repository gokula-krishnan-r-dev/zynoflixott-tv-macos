import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/banner_service.dart';

class FeaturedContentCarousel extends StatefulWidget {
  final Function(Map<String, dynamic>) onContentSelected;

  const FeaturedContentCarousel({
    super.key,
    required this.onContentSelected,
  });

  @override
  State<FeaturedContentCarousel> createState() => _FeaturedContentCarouselState();
}

class _FeaturedContentCarouselState extends State<FeaturedContentCarousel> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  late ApiQuery<List<dynamic>> _bannerQuery;
  final BannerService _bannerService = BannerService();
  
  @override
  void initState() {
    super.initState();
    _initBannerQuery();

    // Auto-scroll timer
    Future.delayed(const Duration(seconds: 1), () {
      _startAutoScroll();
    });
  }
  
  void _initBannerQuery() {
    _bannerQuery = ApiQuery<List<dynamic>>(
      apiService: ApiService(),
      endpoint: '/api/banner',
      parser: (data) => data['video'] as List<dynamic>,
      refreshInterval: const Duration(minutes: 10), // Refresh every 10 minutes
    );
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _bannerQuery.dispose();
    super.dispose();
  }
  
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _bannerQuery.hasData && (_bannerQuery.data?.isNotEmpty ?? false)) {
        int nextPage = _currentIndex + 1;
        if (nextPage >= (_bannerQuery.data?.length ?? 0)) {
          nextPage = 0;
        }
        
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        
        _startAutoScroll();
      } else if (mounted) {
        // Try again if we don't have data yet
        _startAutoScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _bannerQuery,
      child: Consumer<ApiQuery<List<dynamic>>>(
        builder: (context, bannerQuery, _) {
          if (bannerQuery.isLoading) {
            return _buildLoadingState();
          } else if (bannerQuery.hasError) {
            return _buildErrorState(bannerQuery.error!);
          } else if (bannerQuery.hasData && (bannerQuery.data?.isNotEmpty ?? false)) {
            return _buildContentState(bannerQuery.data!);
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return SizedBox(
      height: 500,
      child: Container(
        color: AppTheme.backgroundColor,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 500,
      child: Container(
        color: AppTheme.backgroundColor,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading featured content',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _bannerQuery.refetch(),
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
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return SizedBox(
      height: 500,
      child: Container(
        color: AppTheme.backgroundColor,
        child: Center(
          child: Text(
            'No featured content available',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildContentState(List<dynamic> bannerVideos) {
    return Column(
      children: [
        SizedBox(
          height: 500,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerVideos.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final video = bannerVideos[index] as Map<String, dynamic>;
              return GestureDetector(
                onTap: () => widget.onContentSelected(video),
                child: _buildFeaturedItem(context, video, index == _currentIndex),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerVideos.length,
            (index) => GestureDetector(
              onTap: () => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index
                      ? AppTheme.primaryColor
                      : AppTheme.secondaryTextColor.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedItem(BuildContext context, Map<String, dynamic> video, bool isActive) {
    return Stack(
      children: [
        // Background Image
        SizedBox(
          width: double.infinity,
          child: Image.network(
            video['thumbnail'] ?? '',
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
                        video['title'] ?? 'Video',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
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
                video['title'] ?? 'Untitled',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              
              // Metadata
              Row(
                children: [
                  // Language
                  if ((video['language'] as List?)?.isNotEmpty ?? false)
                    Text(
                      (video['language'] as List).first.toString(),
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
                  
                  // Views
                  Text(
                    '${_formatNumber(video['views'] ?? 0)} views',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Description
              Container(
                width: 500,
                child: Text(
                  video['description'] ?? 'No description available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  // Watch Now button
                  ElevatedButton(
                    onPressed: () => widget.onContentSelected(video),
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
                      'Watch Now',
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

  String _formatNumber(dynamic number) {
    if (number is int && number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number is int && number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
} 