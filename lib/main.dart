import 'package:flutter/material.dart';

import 'dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expanse Tracker - modul 4',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const DashboardScreen(),
    );
  }
}
