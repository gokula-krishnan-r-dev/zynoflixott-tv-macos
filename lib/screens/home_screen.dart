import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zynoflixott_tv/screens/english_videos_screen.dart';
import '../models/media_content.dart';
import '../widgets/featured_content_carousel.dart';
import '../utils/responsive_layout.dart';
import 'package:zynoflixott_tv/screens/video_player_screen.dart' as player;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Sample data
  final List<MediaContent> _featuredContent = MediaContent.getSampleFeaturedContent();
  final List<MediaContent> _movies = MediaContent.getSampleMovies();
  final List<MediaContent> _tvShows = MediaContent.getSampleTVShows();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  //_handleContentSelected
  void _handleContentSelected(Map<String, dynamic> content) {
    // Show details page or play content
   Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => player.VideoPlayerScreen(videoData: content),
    ),
   );
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusScope(
        child: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeyEvent,
          child: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Featured Content Carousel
                  FeaturedContentCarousel(
                    onContentSelected: _handleContentSelected,
                  ),
                  
                  EnglishVideosScreen(language: 'Tamil'),
                  const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Telugu'),
                  const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Hindi'),
                  const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Malayalam'),
                  // const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Kannada'),
                  // const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'English'),
                  // const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Korean'),
                  // const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Japanese'),
                  // const SizedBox(height: 16),

                  EnglishVideosScreen(language: 'Chinese'),
                  // const SizedBox(height: 16),

                  // // Content rows
                  // SizedBox(
                  //   height: 220,
                  //   child: ListView.builder(
                  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //     scrollDirection: Axis.horizontal,
                  //     itemCount: _featuredContent.length,
                  //     itemBuilder: (context, index) {
                  //       final content = _featuredContent[index];
                  //       return _buildContinueWatchingItem(context, content);
                  //     },
                  //   ),
                  // ),
                  
                  // // Movies Grid
                  // ContentGrid(
                  //   title: 'Movies',
                  //   contentList: _movies,
                  //   onContentSelected: _handleContentSelected,
                  // ),
                  
                  // // TV Shows Grid
                  // ContentGrid(
                  //   title: 'TV Shows',
                  //   contentList: _tvShows,
                  //   onContentSelected: _handleContentSelected,
                  // ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueWatchingItem(BuildContext context, MediaContent content) {
    final double width = ResponsiveLayout.isTV(context) ? 300.0 : 220.0;
    
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail with progress indicator
            Stack(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      content.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[800],
                          child: const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                // Progress bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: 0.3 + (0.1 * (content.id.hashCode % 7)), // Random progress for demo
                    minHeight: 4,
                    backgroundColor: Colors.grey.withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                
                // Play button overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleContentSelected(content as Map<String, dynamic>),
                      borderRadius: BorderRadius.circular(8.0),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                content.title,
                style: Theme.of(context).textTheme.titleMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Episode info
            Text(
              content.contentType == 'tvShow' 
                  ? 'S1:E${content.id.hashCode % 10 + 1} • Continue' 
                  : '${content.year} • Continue',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }


  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select) {
        // Handle select button press
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        // Handle left arrow key
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        // Handle right arrow key
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        // Handle up arrow key
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        // Handle down arrow key
      }
    }
  }
} 