import 'package:flutter/material.dart';
import 'pages/pantry_page.dart';
import 'pages/recipes_page.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const LeftoverApp());
}

class LeftoverApp extends StatelessWidget {
  const LeftoverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leftover Recipe Generator',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const HomeNavigation(),
    );
  }
}

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({super.key});

  @override
  State<HomeNavigation> createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    PantryPage(),
    RecipesPage(),
    DashboardPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: "Pantry",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Recipes",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: "Dashboard",
          ),
        ],
      ),
    );
  }
}
