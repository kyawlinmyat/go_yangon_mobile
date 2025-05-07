import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screen.dart';

void main() => runApp(GoYangonApp());

class GoYangonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return GoYangonHomePage();
          }
          return LoadingScreen();
        },
      ),
    );
  }

  Future<void> _initializeApp() async {
    await Future.delayed(Duration(seconds: 3)); // Simulate loading
  }
}