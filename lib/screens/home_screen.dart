import 'package:flutter/material.dart';
import 'package:go_yangon/screens/kiloCalculator_screen.dart';
import 'package:go_yangon/screens/profile_screen.dart';
import 'package:go_yangon/screens/setting_screen.dart';
import 'package:latlong2/latlong.dart';

class GoYangonHomePage extends StatefulWidget {
  @override
  _GoYangonHomePageState createState() => _GoYangonHomePageState();
}

class _GoYangonHomePageState extends State<GoYangonHomePage> {
  LatLng? currentLocation;
  bool isLoading = true;
  int _currentIndex = 0; // Tracks the selected tab index

  final List<Widget> _pages = [
    KilocalculatorScreen(),
    ProfileScreen(),
    SettingScreen(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Go Yangon',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          Badge.count(
              offset: Offset(8, -8),
              // textStyle: GoogleFonts.inter(
              //     fontSize: 11, color: Colors.black87),
              count: 1,
              child: Icon(
                Icons.notifications,
                color: Colors.white,
              )),
          SizedBox(
            width: 15,
          ),
        ],
        centerTitle: true,
      ),
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.speed),
            label: 'Kilo Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.black,
      ),
    );
  }
}



// Profile Tab
