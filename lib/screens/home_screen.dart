import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'banner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        title: Row(
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              height: 32,
              errorBuilder: (context, error, stackTrace) => 
                const Text('ZynoFlix', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Spacer(),
            
            // Search button
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Handle search
              },
            ),
            
            // Profile button
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryColor,
              child: const Text('G', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      
      body: _buildBody(),
      
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surfaceColor,
        selectedIndex: _selectedNavIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.video_library_outlined),
            selectedIcon: Icon(Icons.video_library),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  Widget _buildBody() {
    switch (_selectedNavIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildLibraryTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }
  
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner section
          const SizedBox(
            height: 500, // Adjust based on screen size
            child: BannerScreen(),
          ),
          
          // Trending section
          _buildSection('Trending Now', _buildPlaceholderRow()),
          
          // Popular section
          _buildSection('Popular Movies', _buildPlaceholderRow()),
          
          // New releases section
          _buildSection('New Releases', _buildPlaceholderRow()),
        ],
      ),
    );
  }
  
  Widget _buildExploreTab() {
    return const Center(
      child: Text(
        'Explore Tab',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  
  Widget _buildLibraryTab() {
    return const Center(
      child: Text(
        'Library Tab',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  
  Widget _buildProfileTab() {
    return const Center(
      child: Text(
        'Profile Tab',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
  
  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderRow() {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return _buildPlaceholderCard();
        },
      ),
    );
  }
  
  Widget _buildPlaceholderCard() {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: const Center(
                child: Icon(Icons.movie, color: Colors.white30, size: 32),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                'Loading...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize:
                  12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 