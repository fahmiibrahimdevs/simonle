import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:simonle/screens/dashboard_screen.dart';
import 'package:simonle/screens/history_screen.dart';
import 'package:simonle/screens/notifications_screen.dart';
import 'package:simonle/screens/settings_screen.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _pageIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  void _navigateToPage(int pageIndex) {
    setState(() {
      _pageIndex = pageIndex;
    });
  }

  List<Widget> _pages(BuildContext context) {
    return [
      DashboardPage(),
      SettingsPage(),
      HistoryPage(),
      NotificationsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages(context)[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 70,
        // ignore: prefer_const_literals_to_create_immutables
        items: [
          Icon(Icons.home, size: 35),
          Icon(Icons.settings, size: 35),
          Icon(Icons.history, size: 35),
          Icon(Icons.notifications, size: 35),
        ],
        buttonBackgroundColor: Colors.white,
        backgroundColor: TWColors.gray.shade100,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 500),
        letIndexChange: (index) => true,
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}
