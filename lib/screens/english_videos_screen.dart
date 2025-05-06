import 'package:zynoflixott_tv/screens/video_player_screen.dart' as player;

import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
enum SortOption {
  newest('Newest'),
  mostViewed('Most Viewed'),
  mostLiked('Most Liked');
  
  final String label;
  const SortOption(this.label);
}

class EnglishVideosScreen extends StatefulWidget {
  const EnglishVideosScreen({super.key, required this.language});
  final String language;
  
  @override
  State<EnglishVideosScreen> createState() => _EnglishVideosScreenState();
}

class _EnglishVideosScreenState extends State<EnglishVideosScreen> {
  late ApiQuery<List<dynamic>> _videosQuery;
  final ScrollController _scrollController = ScrollController();
  final FocusNode _rootFocusNode = FocusNode();
  int _focusedIndex = 0;
  SortOption _currentSortOption = SortOption.newest;
  String _searchQuery = '';
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initVideosQuery();
    
    // Set initial focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_rootFocusNode);
    });
  }
  
  void _initVideosQuery() {
    _videosQuery = ApiQuery<List<dynamic>>(
      apiService: ApiService(),
      endpoint: '/api/videos?language=${widget.language}',
      parser: (data) => (data['videos'] as List<dynamic>?) ?? [],
      refreshInterval: const Duration(minutes: 10),
    );
  }
  
  @override
  void dispose() {
    _videosQuery.dispose();
    _scrollController.dispose();
    _rootFocusNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleVideoSelected(Map<String, dynamic> video) {
    // Navigate to video player screen with the selected video data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => player.VideoPlayerScreen(
          videoData: video,
        ),
      ),
    );
  }
  
  void _sortVideos(List<dynamic> videos) {
    if (videos.isEmpty) return;
    
    switch (_currentSortOption) {
      case SortOption.newest:
        videos.sort((a, b) {
          final DateTime dateA = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
          final DateTime dateB = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
          return dateB.compareTo(dateA); // Newest first
        });
        break;
      case SortOption.mostViewed:
        videos.sort((a, b) {
          final int viewsA = a['views'] ?? 0;
          final int viewsB = b['views'] ?? 0;
          return viewsB.compareTo(viewsA); // Most views first
        });
        break;
      case SortOption.mostLiked:
        videos.sort((a, b) {
          final int likesA = a['likes'] ?? 0;
          final int likesB = b['likes'] ?? 0;
          return likesB.compareTo(likesA); // Most likes first
        });
        break;
    }
  }
  
  List<dynamic> _filterVideos(List<dynamic> videos) {
    if (_searchQuery.isEmpty) {
      return videos;
    }
    
    final query = _searchQuery.toLowerCase();
    return videos.where((video) {
      final title = (video['title'] ?? '').toString().toLowerCase();
      final description = (video['description'] ?? '').toString().toLowerCase();
      return title.contains(query) || description.contains(query);
    }).toList();
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowLeft || 
          event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // Handle carousel navigation with keyboard
        _navigateGrid(event.logicalKey);
        return;
      }
      
      // Enter/Return to select the focused video
      if (event.logicalKey == LogicalKeyboardKey.enter || 
          event.logicalKey == LogicalKeyboardKey.numpadEnter) {
        if (_videosQuery.data != null && _focusedIndex < _videosQuery.data!.length) {
          final filteredVideos = _filterVideos(_videosQuery.data!);
          if (_focusedIndex < filteredVideos.length) {
            _handleVideoSelected(filteredVideos[_focusedIndex] as Map<String, dynamic>);
          }
        }
        return;
      }
    }
  }
  
  void _navigateGrid(LogicalKeyboardKey key) {
    if (_videosQuery.data == null || _videosQuery.data!.isEmpty) return;
    
    final filteredVideos = _filterVideos(_videosQuery.data!);
    if (filteredVideos.isEmpty) return;
    
    final int itemCount = filteredVideos.length;
    
    // Horizontal navigation only now
    if (key == LogicalKeyboardKey.arrowLeft) {
      setState(() {
        _focusedIndex = (_focusedIndex - 1) < 0 ? itemCount - 1 : _focusedIndex - 1;
      });
    } else if (key == LogicalKeyboardKey.arrowRight) {
      setState(() {
        _focusedIndex = (_focusedIndex + 1) % itemCount;
      });
    }
    
    // Scroll to ensure the focused item is visible
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _focusedIndex * 210.0, // Card width with margins
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 1200;
    
    // if (_videosQuery.data!.isEmpty) {
    //   return const SizedBox.shrink();
    // }
    
    return RawKeyboardListener(
      focusNode: _rootFocusNode,
      onKey: _handleKeyEvent,
      child: Container(
        color: AppTheme.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Screen header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    '${widget.language} Shorts Films',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            // Main content
            ChangeNotifierProvider.value(
              value: _videosQuery,
              child: Consumer<ApiQuery<List<dynamic>>>(
                builder: (context, videosQuery, _) {
                  if (videosQuery.isLoading) {
                    return _buildLoadingState();
                  } else if (videosQuery.hasError) {
                    return _buildErrorState(videosQuery.error!);
                  } else if (videosQuery.hasData) {
                    // Sort and filter videos
                    List<dynamic> displayVideos = List.from(videosQuery.data ?? []);
                    
                    if (displayVideos.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    
                    _sortVideos(displayVideos);
                    displayVideos = _filterVideos(displayVideos);
                    
                    return displayVideos.isEmpty
                        ? const SizedBox.shrink()
                        : _buildContentState(displayVideos, isLargeScreen);
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadingState() {
    return SizedBox(
      height: 180,
      child: Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );
  }
  
  Widget _buildErrorState(String error) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 24,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 8),
              Text(
                'Failed to load ${widget.language} videos',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildContentState(List<dynamic> videos, bool isLargeScreen) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index] as Map<String, dynamic>;
          final bool isFocused = index == _focusedIndex;
          
          return _buildVideoCard(context, video, isFocused, index);
        },
      ),
    );
  }
  
  Widget _buildVideoCard(BuildContext context, Map<String, dynamic> video, bool isFocused, int index) {
    // Simplified video card with just the thumbnail
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _focusedIndex = index;
          });
          _handleVideoSelected(video);
        },
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thumbnail
              Stack(
                children: [
                  // Actual thumbnail image with rounded corners
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
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
                            child: const Center(
                              child: Icon(
                                Icons.error,
                                color: AppTheme.errorColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Focused border
                  if (isFocused)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(),
                      ),
                    ),
                  
                  // Play button overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  
                  // Duration overlay
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(video['duration'] ?? '0'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(String durationString) {
    try {
      double seconds = double.parse(durationString);
      int minutes = (seconds / 60).floor();
      int remainingSeconds = (seconds % 60).floor();
      
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }
} 