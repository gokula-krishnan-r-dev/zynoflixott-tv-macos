import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;
  final Widget tv;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
    required this.tv,
  });

  // Screen size breakpoints
  static const int mobileMaxWidth = 650;
  static const int tabletMaxWidth = 1100;
  static const int desktopMaxWidth = 1920;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileMaxWidth &&
      MediaQuery.of(context).size.width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMaxWidth &&
      MediaQuery.of(context).size.width <= desktopMaxWidth;

  static bool isTV(BuildContext context) =>
      MediaQuery.of(context).size.width > desktopMaxWidth;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth > desktopMaxWidth) {
      return tv;
    }
    
    if (screenWidth > tabletMaxWidth) {
      return desktop;
    }
    
    if (screenWidth > mobileMaxWidth) {
      return tablet;
    }
    
    return mobile;
  }
} 