import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// A generic API response class to handle any type of data
class ApiResponse<T> {
  final T? data;
  final bool isLoading;
  final String? error;
  final int? statusCode;

  ApiResponse({
    this.data,
    this.isLoading = false,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.loading() => ApiResponse<T>(isLoading: true);
  factory ApiResponse.success(T data, {int? statusCode}) => 
      ApiResponse<T>(data: data, statusCode: statusCode);
  factory ApiResponse.error(String message, {int? statusCode}) => 
      ApiResponse<T>(error: message, statusCode: statusCode);

  bool get hasData => data != null;
  bool get hasError => error != null;
}

/// Logger for API requests and responses
class ApiLogger {
  static void logRequest(String method, String url, dynamic data) {
    if (kDebugMode) {
      print('┌────────────────────────────────────────────────');
      print('│ 🌐 REQUEST: $method $url');
      if (data != null) {
        print('│ 📦 BODY: $data');
      }
      print('└────────────────────────────────────────────────');
    }
  }

  static void logResponse(String method, String url, int? statusCode, dynamic data, Duration duration) {
    if (kDebugMode) {
      final emoji = statusCode != null && statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      print('┌────────────────────────────────────────────────');
      print('│ $emoji RESPONSE: $method $url');
      print('│ ⏱️ TIME: ${duration.inMilliseconds}ms');
      print('│ 🔢 STATUS: $statusCode');
      if (data != null) {
        final truncatedData = _truncateResponseBody(data);
        print('│ 📦 BODY: $truncatedData');
      }
      print('└────────────────────────────────────────────────');
    }
  }

  static void logError(String method, String url, dynamic error) {
    if (kDebugMode) {
      print('┌────────────────────────────────────────────────');
      print('│ ❌ ERROR: $method $url');
      print('│ 🔴 ERROR: $error');
      print('└────────────────────────────────────────────────');
    }
  }

  static String _formatResponseBody(dynamic data) {
    if (data is Map || data is List) {
      try {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } catch (e) {
        return data.toString();
      }
    }
    return data.toString();
  }
  
  static String _truncateResponseBody(dynamic data) {
    String formatted = _formatResponseBody(data);
    const maxLength = 1000;
    
    if (formatted.length > maxLength) {
      return '${formatted.substring(0, maxLength)}... [truncated ${formatted.length - maxLength} characters]';
    }
    
    return formatted;
  }
}

/// A base API service class for making HTTP requests using Dio
class ApiService {
  final String baseUrl;
  final Dio _dio;
  final bool enableLogging;
  CookieJar? _cookieJar;
  bool _isInitialized = false;
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _connectionChecker = InternetConnectionChecker.createInstance();

  ApiService({
    this.baseUrl = 'https://api.zynoflixott.com',
    Dio? dio,
    this.enableLogging = true,
  }) : _dio = dio ?? Dio() {
    _initDio();
  }

  /// Check if device has internet connection
  Future<bool> hasInternetConnection() async {
    try {
      // Try multiple approaches to check connectivity
      
      // 1. First check connectivity status (WiFi, mobile data)
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        if (kDebugMode) {
          print('Connectivity result: None - No network interface detected');
        }
        return false;
      }
      
      // 2. Then check actual internet connectivity by pinging servers
      final hasInternet = await _connectionChecker.hasConnection;
      if (!hasInternet) {
        if (kDebugMode) {
          print('Internet connection check failed - No response from lookup addresses');
        }
      }
      
      // 3. If previous check failed, try a backup method (direct network test)
      if (!hasInternet) {
        try {
          final result = await InternetAddress.lookup('google.com');
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            if (kDebugMode) {
              print('Backup internet check successful');
            }
            return true;
          }
        } catch (e) {
          if (kDebugMode) {
            print('Backup internet check failed: $e');
          }
        }
      }
      
      return hasInternet;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking internet connection: $e');
      }
      // As a fallback, try a direct socket connection to a reliable server
      try {
        final socket = await Socket.connect('8.8.8.8', 53, timeout: const Duration(seconds: 2));
        socket.destroy();
        return true;
      } catch (socketError) {
        if (kDebugMode) {
          print('Socket connection failed: $socketError');
        }
        return false;
      }
    }
  }

  /// Validate API endpoint is reachable
  Future<bool> isApiReachable() async {
    try {
      // Use a more reliable test endpoint
      final testEndpoint = '$baseUrl/api/banner';
      
      if (kDebugMode) {
        print('Testing API reachability: $testEndpoint');
      }
      
      final response = await Dio().get(
        testEndpoint,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
          validateStatus: (_) => true, // Accept any status code
          // Disable redirects to get faster response
          followRedirects: false,
          // Keep request small
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'ZynoflixOTT/Connectivity-Check',
          }
        ),
      );
      
      // Any response (even error) means server is reachable
      final isReachable = response.statusCode != null;
      
      if (kDebugMode) {
        print('API reachability check: ${isReachable ? "SUCCESS" : "FAILED"} (Status ${response.statusCode})');
      }
      
      return isReachable;
    } catch (e) {
      if (kDebugMode) {
        print('API endpoint unreachable: $e');
        
        // Provide more diagnostic information
        if (e is DioException) {
          print('  Type: ${e.type}');
          print('  Message: ${e.message}');
          if (e.error != null) {
            print('  Error: ${e.error}');
          }
        }
      }
      return false;
    }
  }

  Future<void> _initDio() async {
    if (_isInitialized) return;
    
    // Configure Dio
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Setup Cookie Manager
    try {
      final appDocDir = await path_provider.getApplicationDocumentsDirectory();
      final appDocPath = appDocDir.path;
      _cookieJar = PersistCookieJar(
        storage: FileStorage('$appDocPath/.cookies/'),
      );
      _dio.interceptors.add(CookieManager(_cookieJar!));
    } catch (e) {
      if (kDebugMode) {
        print('Failed to setup persistent cookie jar: $e');
        print('Using non-persistent cookie jar instead');
      }
      
      // Fallback to non-persistent cookie jar
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }

    // Add default interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add any request modifications here
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Process response here
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          // Handle errors globally here
          return handler.next(error);
        },
      ),
    );
    
    // Add retry interceptor 
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException error, handler) async {
          if (_shouldRetry(error)) {
            try {
              // Retry the request
              final options = error.requestOptions;
              final response = await _dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
              );
              return handler.resolve(response);
            } catch (e) {
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add cache interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add cache key to options if needed
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Save response to cache if needed
          return handler.next(response);
        },
      ),
    );

    // Add logging interceptor if enabled
    if (enableLogging) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {
          // We're using our custom logger instead
        },
      ));
    }
    
    _isInitialized = true;
  }
  
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode == 503 || error.response?.statusCode == 504);
  }

  // Add proxy configuration to assist with troubleshooting
  void configureProxy(String proxyUrl) {
    if (proxyUrl.isNotEmpty && !kIsWeb) {
      try {
        // For mobile/desktop platforms
        if (_dio.httpClientAdapter is HttpClientAdapter) {
          (_dio.httpClientAdapter as dynamic).onHttpClientCreate = 
              (HttpClient client) {
            client.findProxy = (uri) {
              return 'PROXY $proxyUrl';
            };
            // Disable certificate verification for debugging if needed
            // client.badCertificateCallback = (cert, host, port) => true;
            return client;
          };
          
          if (kDebugMode) {
            print('Configured proxy: $proxyUrl');
          }
        } else {
          if (kDebugMode) {
            print('Unable to configure proxy: adapter is not HttpClientAdapter');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error configuring proxy: $e');
        }
      }
    } else if (kIsWeb) {
      if (kDebugMode) {
        print('Proxy configuration is not supported in web platform');
      }
    }
  }

  /// Performs a GET request and returns an ApiResponse
  Future<ApiResponse<Map<String, dynamic>>> get(String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool forceRefresh = false,
    bool checkConnectivity = true,
  }) async {
    await _initDio();
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl$endpoint';
    
    if (enableLogging) {
      ApiLogger.logRequest('GET', url, queryParameters);
    }

    // Check internet connection if enabled
    if (checkConnectivity) {
      final hasConnection = await hasInternetConnection();
      if (!hasConnection) {
        if (enableLogging) {
          ApiLogger.logError('GET', url, 'No internet connection detected. Please check your network settings.');
        }
        return ApiResponse.error('No internet connection detected. Please check your network settings.');
      }
    }

    try {
      // Set cache control headers if needed
      final requestOptions = options ?? Options();
      if (forceRefresh) {
        requestOptions.headers = {
          ...requestOptions.headers ?? {},
          'Cache-Control': 'no-cache',
        };
      }
      
      // When in debug mode, log detailed info about the request
      if (kDebugMode) {
        print('Making request to: $url');
        print('Base URL: $baseUrl');
        print('Endpoint: $endpoint');
        print('Full URL: ${_dio.options.baseUrl + endpoint}');
        print('Headers: ${requestOptions.headers}');
      }
      
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: requestOptions,
      );
      
      stopwatch.stop();
      
      if (enableLogging) {
        ApiLogger.logResponse(
          'GET', 
          url, 
          response.statusCode, 
          response.data, 
          stopwatch.elapsed
        );
      }

      return ApiResponse.success(
        response.data as Map<String, dynamic>,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      
      // Add detailed diagnostics for connection errors
      if (e.type == DioExceptionType.connectionError) {
        // Try to validate API reachability
        final isReachable = await isApiReachable();
        if (!isReachable) {
          final errorMessage = 'Cannot reach the API server. Please verify the server is running and accessible.';
          if (enableLogging) {
            ApiLogger.logError('GET', url, errorMessage);
          }
          return ApiResponse.error(errorMessage);
        }
      }
      
      final errorMessage = _handleDioError(e);
      
      if (enableLogging) {
        ApiLogger.logError('GET', url, errorMessage);
      }
      
      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      stopwatch.stop();
      
      if (enableLogging) {
        ApiLogger.logError('GET', url, e.toString());
      }
      
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Performs a POST request and returns an ApiResponse
  Future<ApiResponse<Map<String, dynamic>>> post(
    String endpoint, 
    dynamic data, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    await _initDio();
    final stopwatch = Stopwatch()..start();
    final url = '$baseUrl$endpoint';
    
    if (enableLogging) {
      ApiLogger.logRequest('POST', url, data);
    }

    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      
      stopwatch.stop();
      
      if (enableLogging) {
        ApiLogger.logResponse(
          'POST', 
          url, 
          response.statusCode, 
          response.data, 
          stopwatch.elapsed
        );
      }

      return ApiResponse.success(
        response.data as Map<String, dynamic>,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      stopwatch.stop();
      final errorMessage = _handleDioError(e);
      
      if (enableLogging) {
        ApiLogger.logError('POST', url, errorMessage);
      }
      
      return ApiResponse.error(
        errorMessage,
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      stopwatch.stop();
      
      if (enableLogging) {
        ApiLogger.logError('POST', url, e.toString());
      }
      
      return ApiResponse.error('Unexpected error: ${e.toString()}');
    }
  }

  /// Handles Dio errors and returns appropriate error messages
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Request timed out. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timed out. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;
        String message = 'Server error: $statusCode';
        
        if (responseData != null && responseData is Map) {
          // Try to extract error message from response
          if (responseData.containsKey('message')) {
            message = responseData['message'].toString();
          } else if (responseData.containsKey('error')) {
            message = responseData['error'].toString();
          }
        }
        return message;
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'No internet connection detected. Please check your network settings.';
      case DioExceptionType.badCertificate:
        return 'Bad certificate. Please contact support.';
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          return 'Network error: Unable to connect to the server. Please check your internet connection and try again.';
        } else if (error.message?.contains('SocketException') ?? false) {
          return 'Network error: Unable to connect to the server. Please check your internet connection and try again.';
        } else if (error.message?.contains('certificate') ?? false) {
          return 'SSL Certificate Error: There is a problem with the security certificate. Please contact support.';
        }
        return error.message ?? 'An unexpected error occurred';
    }
  }
  
  /// Clears cookies and session data
  Future<void> clearSession() async {
    await _cookieJar?.deleteAll();
  }

  /// Close client when done
  void dispose() {
    _dio.close();
  }
}

/// A generic hook-like class that manages fetching data from an API
/// similar to React Query's useQuery
class ApiQuery<T> extends ChangeNotifier {
  ApiResponse<T> _response = ApiResponse<T>(isLoading: true);
  final ApiService _apiService;
  final String _endpoint;
  final T Function(Map<String, dynamic>)? _parser;
  final Map<String, dynamic>? _queryParameters;
  bool _isMounted = true;
  Timer? _refreshTimer;
  int _retryCount = 0;
  final int _maxRetries;
  Duration _retryDelay;

  ApiQuery({
    required ApiService apiService,
    required String endpoint,
    T Function(Map<String, dynamic>)? parser,
    Map<String, dynamic>? queryParameters,
    bool autoFetch = true,
    Duration? refreshInterval,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) : _apiService = apiService,
      _endpoint = endpoint,
      _parser = parser,
      _queryParameters = queryParameters,
      _maxRetries = maxRetries,
      _retryDelay = retryDelay {
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
  int? get statusCode => _response.statusCode;
  bool get isRetrying => _retryCount > 0;
  int get retryCount => _retryCount;
  
  /// Sets the retry delay (useful for implementing exponential backoff)
  set retryDelay(Duration delay) {
    _retryDelay = delay;
  }

  Future<void> fetchData({bool forceRefresh = false}) async {
    if (!_isMounted) return;
    
    _response = ApiResponse<T>(isLoading: true);
    notifyListeners();

    try {
      final apiResponse = await _apiService.get(
        _endpoint, 
        queryParameters: _queryParameters,
        forceRefresh: forceRefresh
      );
      
      if (apiResponse.hasError) {
        if (!_isMounted) return;
        
        // Handle retry logic if needed
        if (_retryCount < _maxRetries && _shouldRetry(apiResponse.statusCode)) {
          _retryCount++;
          notifyListeners(); // Notify listeners that we're retrying
          
          // Implement exponential backoff
          final delay = _retryDelay * (_retryCount);
          
          if (kDebugMode) {
            print('Retrying request $_retryCount/$_maxRetries after ${delay.inSeconds}s');
          }
          
          // Delay and retry
          await Future.delayed(delay);
          return fetchData();
        }
        
        // Reset retry count
        _retryCount = 0;
        
        _response = ApiResponse.error(
          apiResponse.error!,
          statusCode: apiResponse.statusCode
        );
      } else if (apiResponse.hasData) {
        if (!_isMounted) return;
        
        // Reset retry count on success
        _retryCount = 0;
        
        final parsedData = _parser != null 
          ? _parser!(apiResponse.data!) 
          : apiResponse.data as T;
        _response = ApiResponse.success(
          parsedData,
          statusCode: apiResponse.statusCode
        );
      }
    } catch (e) {
      if (!_isMounted) return;
      _response = ApiResponse.error('Error parsing data: $e');
    }
    
    notifyListeners();
  }
  
  /// Determine if we should retry based on status code
  bool _shouldRetry(int? statusCode) {
    // Retry server errors (5xx) and some client errors
    return statusCode == null || 
           statusCode >= 500 || 
           statusCode == 408 || // Request Timeout
           statusCode == 429;   // Too Many Requests
  }

  Future<void> refetch() async {
    _retryCount = 0;
    await fetchData(forceRefresh: true);
  }

  @override
  void dispose() {
    _isMounted = false;
    _refreshTimer?.cancel();
    super.dispose();
  }
} 