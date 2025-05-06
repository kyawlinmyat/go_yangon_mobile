import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(GoYangonApp());

class GoYangonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GoYangonHomePage(),
    );
  }
}