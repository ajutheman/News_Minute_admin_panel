import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'news/news_list_screen.dart';
import 'categories/category_list_screen.dart';
import 'regions/region_list_screen.dart';
import 'ads/ad_list_screen.dart';
import 'users/user_list_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const NewsListScreen(),
    const CategoryListScreen(),
    const RegionListScreen(),
    const AdListScreen(),
    const UserListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedIconTheme: const IconThemeData(color: Color(0xFF2563EB), size: 28),
            unselectedIconTheme: IconThemeData(color: Colors.grey[400], size: 24),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: TextStyle(color: Colors.grey[600]),
            useIndicator: true,
            indicatorColor: const Color(0xFF2563EB).withOpacity(0.1),
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.newspaper_rounded, color: Color(0xFF2563EB), size: 32),
                ),
                const SizedBox(height: 32),
              ],
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                    tooltip: 'Logout',
                    onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
                  ),
                ),
              ),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.article_outlined),
                selectedIcon: Icon(Icons.article_rounded),
                label: Text('News'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category_rounded),
                label: Text('Categories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.public_outlined),
                selectedIcon: Icon(Icons.public_rounded),
                label: Text('Regions'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.campaign_outlined),
                selectedIcon: Icon(Icons.campaign_rounded),
                label: Text('Ads'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people_rounded),
                label: Text('Users'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),
        ],
      ),
    );
  }
}
