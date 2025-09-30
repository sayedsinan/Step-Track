import 'package:flutter/material.dart';
import 'package:step_track/screens/permission_screen.dart';


class HealthConnectApp extends StatelessWidget {
  const HealthConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Connect Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  PermissionsScreen(),
    );
  }
}
