import 'api_service.dart';

/// A service specifically for fetching banner data
class BannerService {
  final ApiService _apiService;
  
  BannerService({ApiService? apiService}) 
    : _apiService = apiService ?? ApiService();
  
  /// Fetch banner videos from the API
  Future<ApiResponse<List<dynamic>>> getBannerVideos() async {
    try {
      final response = await _apiService.get('/api/banner');
      
      if (response.hasError) {
        return ApiResponse.error(response.error!);
      }
      
      if (response.hasData && response.data!.containsKey('video')) {
        final List<dynamic> videos = response.data!['video'];
        return ApiResponse.success(videos);
      }
      
      return ApiResponse.error('Invalid data format');
    } catch (e) {
      return ApiResponse.error('Error processing banner data: $e');
    }
  }
  
  /// Parse a video item to get the information needed for display
  Map<String, dynamic> parseVideoItem(Map<String, dynamic> video) {
    return {
      'id': video['_id'] ?? '',
      'title': video['title'] ?? '',
      'description': video['description'] ?? '',
      'thumbnail': video['thumbnail'] ?? '',
      'preview_video': video['preview_video'] ?? '',
      'original_video': video['original_video'] ?? '',
      'views': video['views'] ?? 0,
      'likes': video['likes'] ?? 0,
      'duration': video['duration'] ?? '0',
      'language': video['language'] ?? [],
      'category': video['category'] ?? [],
    };
  }
  
  void dispose() {
    _apiService.dispose();
  }
} 