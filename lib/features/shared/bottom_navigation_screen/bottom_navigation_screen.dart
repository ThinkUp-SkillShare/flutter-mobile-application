import 'package:flutter/material.dart';
import 'package:skill_share/features/files/presentation/views/files_screen.dart';
import 'package:skill_share/features/my_groups/presentation/views/groups_screen.dart';
import 'package:skill_share/features/home/presentation/views/home_screen.dart';
import 'package:skill_share/features/profile/presentation/views/profile_screen.dart';
import 'package:skill_share/features/search/presentation/views/search_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    HomeScreen(),
    GroupsScreen(),
    SearchScreen(),
    MyFilesScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey[850],
        selectedItemColor: const Color(0xFF0F4C75),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Groups'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explorer'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Files'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}
