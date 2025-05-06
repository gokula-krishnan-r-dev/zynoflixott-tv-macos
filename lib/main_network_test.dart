import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';

/// A simple app to test network connectivity
/// Run this with: flutter run -t lib/main_network_test.dart
void main() {
  runApp(const NetworkTestApp());
}

class NetworkTestApp extends StatelessWidget {
  const NetworkTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Connectivity Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Provider<ApiService>(
        create: (context) => ApiService(),
        dispose: (_, service) => service.dispose(),
        child: const NetworkTestScreen(),
      ),
    );
  }
}

class NetworkTestScreen extends StatefulWidget {
  const NetworkTestScreen({super.key});

  @override
  State<NetworkTestScreen> createState() => _NetworkTestScreenState();
}

class _NetworkTestScreenState extends State<NetworkTestScreen> {
  bool _isLoading = false;
  String _status = 'Not checked';
  String _detailedStatus = '';
  bool _hasInternetConnection = false;
  bool _isApiReachable = false;

  // Run all network tests
  Future<void> _runNetworkTests() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    
    setState(() {
      _isLoading = true;
      _status = 'Checking...';
      _detailedStatus = '';
    });

    try {
      // Check internet connectivity
      final hasInternet = await apiService.hasInternetConnection();
      
      // If internet is available, check API reachability
      bool apiReachable = false;
      if (hasInternet) {
        apiReachable = await apiService.isApiReachable();
      }
      
      // Update state with results
      setState(() {
        _hasInternetConnection = hasInternet;
        _isApiReachable = apiReachable;
        
        if (hasInternet && apiReachable) {
          _status = 'All systems go!';
          _detailedStatus = 'Network connection is active and API server is reachable.';
        } else if (hasInternet && !apiReachable) {
          _status = 'API Unreachable';
          _detailedStatus = 'Your device has internet connection, but cannot reach the API server. The server might be down or there might be a DNS issue.';
        } else {
          _status = 'No Internet Connection';
          _detailedStatus = 'Your device is not connected to the internet. Please check your network settings.';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error';
        _detailedStatus = 'An error occurred during network testing: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Run tests automatically on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runNetworkTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Connectivity Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                _hasInternetConnection ? Icons.wifi : Icons.wifi_off,
                size: 80,
                color: _hasInternetConnection ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                _status,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                _detailedStatus,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatusCard(
                    'Internet',
                    _hasInternetConnection,
                    Icons.signal_wifi_4_bar,
                  ),
                  _buildStatusCard(
                    'API Server',
                    _isApiReachable,
                    Icons.cloud,
                  ),
                ],
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _runNetworkTests,
                icon: _isLoading 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isLoading ? 'Checking...' : 'Test Connection'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 48),
                const Text('Debug Information', 
                  style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('API Base URL: ${Provider.of<ApiService>(context).baseUrl}'),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusCard(String title, bool isSuccess, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSuccess ? Colors.green : Colors.red,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              isSuccess ? 'Connected' : 'Disconnected',
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 