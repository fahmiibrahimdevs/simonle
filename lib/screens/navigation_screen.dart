import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:simonle/screens/dashboard_screen.dart';
import 'package:simonle/screens/history_screen.dart';
import 'package:simonle/screens/settings_screen.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _pageIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Widget _buildNavIcon(IconData icon, int index) {
    final bool isActive = _pageIndex == index;
    return Icon(
      icon,
      size: 30,
      color: isActive ? TWColors.white : TWColors.gray.shade400,
    );
  }

  final List<Widget> _pages = const [
    DashboardPage(),
    HistoryPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _pageIndex, children: _pages),
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: _pageIndex,
        height: 65,
        items: [
          _buildNavIcon(Icons.home_rounded, 0),
          _buildNavIcon(Icons.history_rounded, 1),
          _buildNavIcon(Icons.settings_rounded, 2),
        ],
        buttonBackgroundColor: TWColors.blue.shade600,
        backgroundColor: TWColors.gray.shade100,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 400),
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
