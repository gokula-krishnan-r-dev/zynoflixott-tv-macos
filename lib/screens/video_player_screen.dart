import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> videoData;

  const VideoPlayerScreen({
    Key? key,
    required this.videoData,
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  ApiQuery<Map<String, dynamic>>? _videoDetailsQuery;
  bool _isFullScreen = false;
  bool _showControls = true;
  Timer? _controlsTimer;
  double _volumeLevel = 1.0;
  bool _isMuted = false;
  AnimationController? _playPauseController;
  double _playbackSpeed = 1.0;
  bool _showRewindAnimation = false;
  bool _showForwardAnimation = false;
  bool _isShowingThumbnail = false;
  Duration _thumbnailPosition = Duration.zero;
  
  // Track video progress
  Duration _currentPosition = Duration.zero;
  Duration _videoDuration = Duration.zero;
  
  // For TV/Remote navigation 
  final FocusNode _playPauseFocusNode = FocusNode();
  final FocusNode _fullscreenFocusNode = FocusNode();
  final FocusNode _backButtonFocusNode = FocusNode();
  final FocusNode _seekBarFocusNode = FocusNode();
  final FocusNode _volumeFocusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer(widget.videoData['original_video']);
    
    // Initialize animation controller for play/pause button
    _playPauseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Set initial focus for TV navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_playPauseFocusNode);
    });
    
    // Auto-hide controls after a few seconds
    _resetControlsTimer();
    
    // Enter landscape mode for better viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _initializeVideoPlayer(String videoUrl) {
    _controller = VideoPlayerController.network(videoUrl);
    
    _controller!.initialize().then((_) {
      setState(() {
        _isLoading = false;
        _videoDuration = _controller!.value.duration;
        // Start playing automatically
        _controller!.play();
        _playPauseController!.forward();
      });
      
      // Update position indicator regularly
      _controller!.addListener(_videoListener);
    }).catchError((error) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _errorMessage = 'Failed to initialize video: $error';
      });
    });
  }
  
  void _videoListener() {
    if (!mounted) return;
    
    // Update current position for progress bar
    final newPosition = _controller!.value.position;
    if (newPosition != _currentPosition) {
      setState(() {
        _currentPosition = newPosition;
      });
    }
    
    // Handle video completion
    if (_controller!.value.position >= _controller!.value.duration) {
      setState(() {
        // Show controls when video completes
        _showControls = true;
        _cancelControlsTimer();
      });
    }
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _playPauseController!.reverse();
        _showControls = true;
        _cancelControlsTimer();
      } else {
        _controller!.play();
        _playPauseController!.forward();
        _resetControlsTimer();
      }
    });
  }
  
  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      
      if (_isFullScreen) {
        // Hide system UI for immersive experience
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        // Show system UI when exiting full screen
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }
  
  void _toggleMute() {
    setState(() {
      if (_isMuted) {
        _controller!.setVolume(_volumeLevel);
        _isMuted = false;
      } else {
        _volumeLevel = _controller!.value.volume;
        _controller!.setVolume(0);
        _isMuted = true;
      }
    });
  }
  
  void _changeVolume(double value) {
    setState(() {
      _controller!.setVolume(value);
      _volumeLevel = value;
      _isMuted = value == 0;
    });
  }
  
  void _seek(Duration position) {
    _controller!.seekTo(position);
  }
  
  void _seekForward() {
    final newPosition = _currentPosition + const Duration(seconds: 10);
    if (newPosition < _videoDuration) {
      _seek(newPosition);
    } else {
      _seek(_videoDuration);
    }
    
    setState(() {
      _showForwardAnimation = true;
    });
  }
  
  void _seekBackward() {
    final newPosition = _currentPosition - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _seek(newPosition);
    } else {
      _seek(Duration.zero);
    }
    
    setState(() {
      _showRewindAnimation = true;
    });
  }
  
  void _replayVideo() {
    _seek(Duration.zero);
    _controller!.play();
    if (_playPauseController?.status != AnimationStatus.completed) {
      _playPauseController!.forward();
    }
  }
  
  double _getBufferedPercentage() {
    if (_controller == null || _controller!.value.buffered.isEmpty) {
      return 0.0;
    }
    
    final bufferedEndPosition = _controller!.value.buffered.last.end;
    final totalDuration = _controller!.value.duration.inMilliseconds;
    
    if (totalDuration <= 0) return 0.0;
    
    return bufferedEndPosition.inMilliseconds / totalDuration;
  }
  
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _resetControlsTimer();
      } else {
        _cancelControlsTimer();
      }
    });
  }
  
  void _resetControlsTimer() {
    _cancelControlsTimer();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _controller?.value.isPlaying == true) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }
  
  void _cancelControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = null;
  }
  
  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.select || 
          event.logicalKey == LogicalKeyboardKey.space) {
        _togglePlayPause();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _seekForward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _seekBackward();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _changeVolume((_volumeLevel + 0.1).clamp(0.0, 1.0));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _changeVolume((_volumeLevel - 0.1).clamp(0.0, 1.0));
      } else if (event.logicalKey == LogicalKeyboardKey.escape || 
                event.logicalKey == LogicalKeyboardKey.goBack) {
        _handleBackButton();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        _toggleFullScreen();
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        _toggleMute();
      }
      
      // Show controls whenever any key is pressed
      if (!_showControls) {
        setState(() {
          _showControls = true;
          _resetControlsTimer();
        });
      } else {
        _resetControlsTimer();
      }
    }
  }

  void _handleBackButton() {
    // First exit full screen if active
    if (_isFullScreen) {
      _toggleFullScreen();
      return;
    }
    
    // Then navigate back
    Navigator.of(context).pop();
  }

  void _showQualityOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Video Quality',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildQualityOption('Auto', isSelected: true),
                _buildQualityOption('1080p HD'),
                _buildQualityOption('720p HD'),
                _buildQualityOption('480p'),
                _buildQualityOption('360p'),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildQualityOption(String quality, {bool isSelected = false}) {
    return ListTile(
      dense: true,
      title: Text(
        quality,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        // Implementation would depend on actual available qualities
        Navigator.pop(context);
      },
    );
  }
  
  void _showSpeedOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Playback Speed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                _buildSpeedOption(0.5),
                _buildSpeedOption(0.75),
                _buildSpeedOption(1.0),
                _buildSpeedOption(1.25),
                _buildSpeedOption(1.5),
                _buildSpeedOption(2.0),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSpeedOption(double speed) {
    final isSelected = _playbackSpeed == speed;
    final label = speed == 1.0 ? 'Normal' : '${speed}x';
    
    return ListTile(
      dense: true,
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: AppTheme.primaryColor) : null,
      onTap: () {
        setState(() {
          _playbackSpeed = speed;
          _controller!.setPlaybackSpeed(speed);
        });
        Navigator.pop(context);
      },
    );
  }
  
  String _formatViewCount(dynamic count) {
    if (count == null) return '0';
    
    int viewCount;
    if (count is String) {
      viewCount = int.tryParse(count) ?? 0;
    } else if (count is int) {
      viewCount = count;
    } else {
      return '0';
    }
    
    if (viewCount >= 1000000) {
      return '${(viewCount / 1000000).toStringAsFixed(1)}M';
    } else if (viewCount >= 1000) {
      return '${(viewCount / 1000).toStringAsFixed(1)}K';
    } else {
      return viewCount.toString();
    }
  }

  @override
  void dispose() {
    _controlsTimer?.cancel();
    _videoDetailsQuery?.dispose();
    _controller?.dispose();
    _playPauseController?.dispose();
    _playPauseFocusNode.dispose();
    _fullscreenFocusNode.dispose();
    _backButtonFocusNode.dispose();
    _seekBarFocusNode.dispose();
    _volumeFocusNode.dispose();
    
    // Restore system UI and orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button/gesture for Android
        if (_isFullScreen) {
          _toggleFullScreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: _handleKeyEvent,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_hasError) {
      return _buildErrorState();
    } else {
      return _buildVideoPlayer();
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading video...',
            style: TextStyle(color: Colors.white),
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
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    // Determine video dimensions for proper layout
    final screenSize = MediaQuery.of(context).size;
    final isTV = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;
    
    // Scale UI accordingly
    final controlsHeight = isTV ? 80.0 : (isTablet ? 60.0 : 48.0);
    final iconSize = isTV ? 40.0 : (isTablet ? 32.0 : 24.0);
    final textSize = isTV ? 18.0 : (isTablet ? 16.0 : 14.0);
    final seekBarHeight = isTV ? 10.0 : (isTablet ? 6.0 : 4.0);
    
    return MouseRegion(
      onHover: (_) {
        if (!_showControls) {
          setState(() {
            _showControls = true;
            _resetControlsTimer();
          });
        } else {
          _resetControlsTimer();
        }
      },
      child: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            // Video content
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
            
            // Double tap overlay for quick seeking
            Row(
              children: [
                // Left side - rewind
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: _seekBackward,
                    behavior: HitTestBehavior.translucent,
                    child: _showRewindAnimation ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      onEnd: () {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() {
                              _showRewindAnimation = false;
                            });
                          }
                        });
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.replay_10, color: Colors.white, size: iconSize),
                              SizedBox(width: 4),
                              Text('10', style: TextStyle(color: Colors.white, fontSize: textSize)),
                            ],
                          ),
                        ),
                      ),
                    ) : Container(),
                  ),
                ),
                
                // Right side - forward
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: _seekForward,
                    behavior: HitTestBehavior.translucent,
                    child: _showForwardAnimation ? TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      onEnd: () {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (mounted) {
                            setState(() {
                              _showForwardAnimation = false;
                            });
                          }
                        });
                      },
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.forward_10, color: Colors.white, size: iconSize),
                              SizedBox(width: 4),
                              Text('10', style: TextStyle(color: Colors.white, fontSize: textSize)),
                            ],
                          ),
                        ),
                      ),
                    ) : Container(),
                  ),
                ),
              ],
            ),
            
            // Gradient overlays for better readability
            if (_showControls) ...[
              // Top gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),
              ),
              
              // Bottom gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 150,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
            
            // Controls overlay - only visible when _showControls is true
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: Colors.transparent,
                child: Visibility(
                  visible: _showControls,
                  child: Stack(
                    children: [
                      // Video info panel at top
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          children: [
                            // Back button with ripple effect
                            Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(24),
                                onTap: _handleBackButton,
                                child: Focus(
                                  focusNode: _backButtonFocusNode,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      Icons.arrow_back, 
                                      color: Colors.white, 
                                      size: iconSize,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 20),
                            
                            // Title and metadata
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.videoData['title'] ?? 'Video',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: textSize * 1.3,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(1, 1),
                                          blurRadius: 3,
                                        ),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      if (widget.videoData['views'] != null) ...[
                                        Icon(Icons.visibility, color: Colors.white70, size: textSize * 0.8),
                                        SizedBox(width: 4),
                                        Text(
                                          _formatViewCount(widget.videoData['views']),
                                          style: TextStyle(color: Colors.white70, fontSize: textSize * 0.8),
                                        ),
                                        SizedBox(width: 12),
                                      ],
                                      if (widget.videoData['likes'] != null) ...[
                                        Icon(Icons.thumb_up_outlined, color: Colors.white70, size: textSize * 0.8),
                                        SizedBox(width: 4),
                                        Text(
                                          _formatViewCount(widget.videoData['likes']),
                                          style: TextStyle(color: Colors.white70, fontSize: textSize * 0.8),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            
                            // Top-right controls
                            Row(
                              children: [
                                // Quality selector
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: _showQualityOptions,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.settings, color: Colors.white, size: iconSize * 0.8),
                                          SizedBox(width: 4),
                                          Text(
                                            'HD',
                                            style: TextStyle(color: Colors.white, fontSize: textSize * 0.9),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                
                                // Playlist button
                                Material(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(24),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(24),
                                    onTap: () {}, // Placeholder for playlist function
                                    child: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black38,
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: Icon(Icons.playlist_play, color: Colors.white, size: iconSize),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Center play/pause button with ripple effect
                      Positioned.fill(
                        child: Center(
                          child: Focus(
                            focusNode: _playPauseFocusNode,
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _togglePlayPause,
                                child: Container(
                                  width: isTV ? 100 : (isTablet ? 80 : 60),
                                  height: isTV ? 100 : (isTablet ? 80 : 60),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress: _playPauseController!,
                                      color: Colors.white,
                                      size: isTV ? 60 : (isTablet ? 40 : 30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Bottom controls
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Preview thumbnail above seek bar (placeholder)
                            if (_isShowingThumbnail)
                              Container(
                                margin: EdgeInsets.only(bottom: 10),
                                height: 80,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white30, width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    _formatDuration(_thumbnailPosition),
                                    style: TextStyle(color: Colors.white, fontSize: textSize),
                                  ),
                                ),
                              ),
                            
                            // Buffering indicator
                            LinearProgressIndicator(
                              value: _getBufferedPercentage(),
                              backgroundColor: Colors.white12,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
                              minHeight: seekBarHeight / 2,
                            ),
                            
                            // Seek bar
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Focus(
                                focusNode: _seekBarFocusNode,
                                child: Row(
                                  children: [
                                    // Current position
                                    Text(
                                      _formatDuration(_currentPosition),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: textSize,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    // Progress bar
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: seekBarHeight,
                                          thumbShape: RoundSliderThumbShape(
                                            enabledThumbRadius: seekBarHeight * 1.5,
                                            disabledThumbRadius: 0,
                                          ),
                                          overlayShape: RoundSliderOverlayShape(
                                            overlayRadius: seekBarHeight * 3,
                                          ),
                                          activeTrackColor: AppTheme.primaryColor,
                                          inactiveTrackColor: Colors.white30,
                                          thumbColor: AppTheme.primaryColor,
                                          overlayColor: AppTheme.primaryColor.withOpacity(0.3),
                                        ),
                                        child: Slider(
                                          value: _currentPosition.inMilliseconds.toDouble(),
                                          min: 0,
                                          max: _videoDuration.inMilliseconds.toDouble(),
                                          onChanged: (value) {
                                            setState(() {
                                              _currentPosition = Duration(milliseconds: value.toInt());
                                              _thumbnailPosition = Duration(milliseconds: value.toInt());
                                              _isShowingThumbnail = true;
                                            });
                                          },
                                          onChangeEnd: (value) {
                                            _seek(Duration(milliseconds: value.toInt()));
                                            setState(() {
                                              _isShowingThumbnail = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    
                                    // Total duration
                                    Text(
                                      _formatDuration(_videoDuration),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: textSize,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            offset: const Offset(1, 1),
                                            blurRadius: 3,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            
                            // Playback controls with Material design
                            Padding(
                              padding: EdgeInsets.only(
                                left: 16, right: 16, 
                                bottom: isTV ? 32 : (isTablet ? 24 : 16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Left controls
                                  Row(
                                    children: [
                                      // Rewind 10 seconds with ripple effect
                                      Material(
                                        color: Colors.transparent,
                                        shape: const CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: IconButton(
                                          icon: Icon(Icons.replay_10, color: Colors.white, size: iconSize),
                                          onPressed: () {
                                            _seekBackward();
                                            setState(() {
                                              _showRewindAnimation = true;
                                            });
                                          },
                                          tooltip: 'Rewind 10 seconds',
                                          padding: EdgeInsets.all(isTV ? 12 : 8),
                                          splashColor: AppTheme.primaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      
                                      // Play/Pause with ripple effect
                                      Material(
                                        color: Colors.transparent,
                                        shape: const CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: IconButton(
                                          icon: Icon(
                                            _controller!.value.isPlaying ? Icons.pause : 
                                                (_controller!.value.position >= _controller!.value.duration ? Icons.replay : Icons.play_arrow), 
                                            color: Colors.white, 
                                            size: iconSize
                                          ),
                                          onPressed: _controller!.value.position >= _controller!.value.duration ? _replayVideo : _togglePlayPause,
                                          tooltip: _controller!.value.isPlaying ? 'Pause' : 
                                                  (_controller!.value.position >= _controller!.value.duration ? 'Replay' : 'Play'),
                                          padding: EdgeInsets.all(isTV ? 12 : 8),
                                          splashColor: AppTheme.primaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      
                                      // Forward 10 seconds with ripple effect
                                      Material(
                                        color: Colors.transparent,
                                        shape: const CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: IconButton(
                                          icon: Icon(Icons.forward_10, color: Colors.white, size: iconSize),
                                          onPressed: () {
                                            _seekForward();
                                            setState(() {
                                              _showForwardAnimation = true;
                                            });
                                          },
                                          tooltip: 'Forward 10 seconds',
                                          padding: EdgeInsets.all(isTV ? 12 : 8),
                                          splashColor: AppTheme.primaryColor.withOpacity(0.3),
                                        ),
                                      ),
                                      
                                      // Speed control
                                      Material(
                                        color: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: InkWell(
                                          onTap: _showSpeedOptions,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            child: Text(
                                              '${_playbackSpeed}x',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: textSize * 0.9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Right controls
                                  Row(
                                    children: [
                                      // Volume control with improved slider
                                      Focus(
                                        focusNode: _volumeFocusNode,
                                        child: Row(
                                          children: [
                                            Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              clipBehavior: Clip.antiAlias,
                                              child: IconButton(
                                                icon: Icon(
                                                  _isMuted ? Icons.volume_off : 
                                                      (_volumeLevel < 0.1 ? Icons.volume_mute :
                                                       _volumeLevel < 0.5 ? Icons.volume_down : Icons.volume_up),
                                                  color: Colors.white,
                                                  size: iconSize,
                                                ),
                                                onPressed: _toggleMute,
                                                tooltip: _isMuted ? 'Unmute' : 'Mute',
                                                padding: EdgeInsets.all(isTV ? 12 : 8),
                                                splashColor: AppTheme.primaryColor.withOpacity(0.3),
                                              ),
                                            ),
                                            SizedBox(
                                              width: isTV ? 120 : (isTablet ? 100 : 80),
                                              child: SliderTheme(
                                                data: SliderThemeData(
                                                  trackHeight: seekBarHeight * 0.6,
                                                  thumbShape: RoundSliderThumbShape(
                                                    enabledThumbRadius: seekBarHeight,
                                                  ),
                                                  overlayShape: RoundSliderOverlayShape(
                                                    overlayRadius: seekBarHeight * 2,
                                                  ),
                                                  activeTrackColor: Colors.white,
                                                  inactiveTrackColor: Colors.white30,
                                                  thumbColor: Colors.white,
                                                  overlayColor: Colors.white.withOpacity(0.2),
                                                ),
                                                child: Slider(
                                                  value: _isMuted ? 0 : _volumeLevel,
                                                  min: 0,
                                                  max: 1.0,
                                                  onChanged: _changeVolume,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Fullscreen toggle with ripple effect
                                      Material(
                                        color: Colors.transparent,
                                        shape: const CircleBorder(),
                                        clipBehavior: Clip.antiAlias,
                                        child: Focus(
                                          focusNode: _fullscreenFocusNode,
                                          child: IconButton(
                                            icon: Icon(
                                              _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                              color: Colors.white,
                                              size: iconSize,
                                            ),
                                            onPressed: _toggleFullScreen,
                                            tooltip: _isFullScreen ? 'Exit Fullscreen' : 'Enter Fullscreen',
                                            padding: EdgeInsets.all(isTV ? 12 : 8),
                                            splashColor: AppTheme.primaryColor.withOpacity(0.3),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    
    // Add hours if needed
    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
} 