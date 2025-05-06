import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/banner_service.dart';
import '../theme/app_theme.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  late ApiQuery<List<dynamic>> _bannerQuery;
  final BannerService _bannerService = BannerService();
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _initBannerQuery();
    
    // Auto-scroll timer for carousel
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
  
  void _startAutoScroll() {
    if (!mounted) return;
    
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
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bannerQuery.dispose();
    _bannerService.dispose();
    super.dispose();
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
    return Container(
      color: AppTheme.backgroundColor,
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return Container(
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
              'Error loading banner videos',
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
    );
  }
  
  Widget _buildEmptyState() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Center(
        child: Text(
          'No banner videos available',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildContentState(List<dynamic> bannerVideos) {
    return Column(
      children: [
        Expanded(
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
                onTap: () {
                  // Handle video selection
                },
                child: _buildBannerItem(context, video),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        _buildPageIndicators(bannerVideos.length),
      ],
    );
  }
  
  Widget _buildPageIndicators(int count) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          count,
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
    );
  }
  
  Widget _buildBannerItem(BuildContext context, Map<String, dynamic> video) {
    return Stack(
      children: [
        // Background Image
        SizedBox(
          width: double.infinity,
          height: double.infinity,
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
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Metadata
              Row(
                children: [
                  // Language
                  if ((video['language'] as List?)?.isNotEmpty ?? false)
                    Text(
                      (video['language'] as List).first.toString().toUpperCase(),
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
              Text(
                video['description'] ?? 'No description available',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle watch action
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Watch Now'),
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