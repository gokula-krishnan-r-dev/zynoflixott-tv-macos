import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class VideoDetailCard extends StatelessWidget {
  final Map<String, dynamic> video;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onAddToListPressed;
  
  const VideoDetailCard({
    super.key,
    required this.video,
    this.onPlayPressed,
    this.onAddToListPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail with play button overlay
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Thumbnail image
                Image.network(
                  video['thumbnail'] ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.backgroundColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: AppTheme.errorColor,
                          size: 48,
                        ),
                      ),
                    );
                  },
                ),
                
                // Play button overlay
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onPlayPressed,
                      child: Center(
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Video duration
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _formatDuration(video['duration']),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Video details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  video['title'] ?? 'Untitled Video',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.primaryColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Metadata row
                Row(
                  children: [
                    // Views
                    Icon(
                      Icons.visibility,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(video['views'] ?? 0),
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Likes
                    Icon(
                      Icons.thumb_up_outlined,
                      size: 16,
                      color: AppTheme.secondaryTextColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatNumber(video['likes'] ?? 0),
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 14,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Language tag
                    if ((video['language'] as List?)?.isNotEmpty ?? false)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (video['language'] as List).first.toString().toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  video['description'] ?? 'No description available',
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                
                // Action buttons
                Row(
                  children: [
                    // Watch button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onPlayPressed,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Watch Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Add to list button
                    IconButton(
                      onPressed: onAddToListPressed,
                      icon: const Icon(
                        Icons.add,
                        color: AppTheme.accentColor,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surfaceColor,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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
  
  String _formatDuration(dynamic duration) {
    if (duration == null) return '0:00';
    
    try {
      final seconds = double.parse(duration.toString()).toInt();
      final minutes = (seconds / 60).floor();
      final remainingSeconds = seconds % 60;
      
      if (minutes >= 60) {
        final hours = (minutes / 60).floor();
        final remainingMinutes = minutes % 60;
        return '$hours:${remainingMinutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
      }
      
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    } catch (e) {
      return '0:00';
    }
  }
} 