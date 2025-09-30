import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/screens/dash_board_screen.dart';
import 'package:step_track/screens/permission_screen.dart';

import 'screens/debug_screen.dart';

class HealthConnectApp extends ConsumerWidget {
  const HealthConnectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Health Connect Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const DashboardScreen(),
      routes: {
        '/permissions': (context) => const PermissionsScreen(),
        '/debug': (context) => const DebugScreen(),
      },
    );
  }
}