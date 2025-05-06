import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// A generic API response class to handle any type of data
class ApiResponse<T> {
  final T? data;
  final bool isLoading;
  final String? error;

  ApiResponse({
    this.data,
    this.isLoading = false,
    this.error,
  });

  factory ApiResponse.loading() => ApiResponse<T>(isLoading: true);
  factory ApiResponse.success(T data) => ApiResponse<T>(data: data);
  factory ApiResponse.error(String message) => ApiResponse<T>(error: message);

  bool get hasData => data != null;
  bool get hasError => error != null;
}

/// A base API service class for making HTTP requests
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    this.baseUrl = 'https://api.zynoflixott.com',
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Performs a GET request and returns an ApiResponse
  Future<ApiResponse<Map<String, dynamic>>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        return ApiResponse.success(jsonDecode(response.body));
      } else {
        // Error response
        return ApiResponse.error('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  /// Performs a POST request and returns an ApiResponse
  Future<ApiResponse<Map<String, dynamic>>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        return ApiResponse.success(jsonDecode(response.body));
      } else {
        // Error response
        return ApiResponse.error('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  // Close client when done
  void dispose() {
    _client.close();
  }
}

/// A generic hook-like class that manages fetching data from an API
/// similar to React Query's useQuery
class ApiQuery<T> extends ChangeNotifier {
  ApiResponse<T> _response = ApiResponse<T>(isLoading: true);
  final ApiService _apiService;
  final String _endpoint;
  final T Function(Map<String, dynamic>)? _parser;
  bool _isMounted = true;
  Timer? _refreshTimer;

  ApiQuery({
    required ApiService apiService,
    required String endpoint,
    T Function(Map<String, dynamic>)? parser,
    bool autoFetch = true,
    Duration? refreshInterval,
  }) : _apiService = apiService,
      _endpoint = endpoint,
      _parser = parser {
    if (autoFetch) {
      fetchData();
    }

    // Setup refresh interval if provided
    if (refreshInterval != null) {
      _refreshTimer = Timer.periodic(refreshInterval, (_) {
        if (_isMounted) fetchData();
      });
    }
  }

  ApiResponse<T> get response => _response;
  bool get isLoading => _response.isLoading;
  T? get data => _response.data;
  String? get error => _response.error;
  bool get hasError => _response.hasError;
  bool get hasData => _response.hasData;

  Future<void> fetchData() async {
    if (!_isMounted) return;
    
    _response = ApiResponse<T>(isLoading: true);
    notifyListeners();

    try {
      final apiResponse = await _apiService.get(_endpoint);
      
      if (apiResponse.hasError) {
        if (!_isMounted) return;
        _response = ApiResponse.error(apiResponse.error!);
      } else if (apiResponse.hasData) {
        if (!_isMounted) return;
        final parsedData = _parser != null 
          ? _parser!(apiResponse.data!) 
          : apiResponse.data as T;
        _response = ApiResponse.success(parsedData);
      }
    } catch (e) {
      if (!_isMounted) return;
      _response = ApiResponse.error('Error parsing data: $e');
    }
    
    notifyListeners();
  }

  Future<void> refetch() async {
    await fetchData();
  }

  @override
  void dispose() {
    _isMounted = false;
    _refreshTimer?.cancel();
    super.dispose();
  }
} 