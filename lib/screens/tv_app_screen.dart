import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class TVAppScreen extends StatefulWidget {
  const TVAppScreen({super.key});

  @override
  State<TVAppScreen> createState() => _TVAppScreenState();
}

class _TVAppScreenState extends State<TVAppScreen> {
  int _selectedIndex = 0;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FocusScope(
        autofocus: true,
        child: Column(
          children: [
            // Navigation bar
            _buildNavigationBar(),
            
            // Main Content Area
            Expanded(
              child: _buildScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      height: 60,
      color: AppTheme.cardColor,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24 , top: 15 , bottom: 15 , right: 10),
            child: Row(
              
              children: [
            
            //logo
            Image.asset('assets/images/logo.png', height: 40),
            const SizedBox(width: 10),
            //text zynoflix
            const Text('Zynoflix', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
            ],
            ),
          ),

          Spacer(),

          //search bar
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Container(
              width: 240,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded, 
                      color: AppTheme.primaryColor,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Search', 
                      style: TextStyle(
                        color: AppTheme.secondaryTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Ctrl+S',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),


          Spacer(),

          Padding(
            padding: const EdgeInsets.only(right: 24  , left: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Icon(
                        Icons.notifications_outlined, 
                        color: AppTheme.secondaryTextColor,
                        size: 24,
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'User',
                        style: TextStyle(
                          color: AppTheme.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )


        ],
      ),
    );
  }

  Widget _buildNavButton(int index, String label, IconData icon) {
    final bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _handleNavigation(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.secondaryTextColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.secondaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_selectedIndex) {
      case 0: // Home
        return const HomeScreen();
      case 1: // Apple TV+
        return _buildPlaceholderScreen('Apple TV+');
      case 2: // Movies
        return _buildPlaceholderScreen('Movies');
      case 3: // TV Shows
        return _buildPlaceholderScreen('TV Shows');
      default:
        return const HomeScreen();
    }
  }

  Widget _buildPlaceholderScreen(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 0; // Go back to home
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
            child: const Text('Go to Home'),
          ),
        ],
      ),
    );
  }

  void _handleNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
} 