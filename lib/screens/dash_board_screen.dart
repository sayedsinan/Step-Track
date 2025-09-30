import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/widgets/dashboard_body.dart';
import 'package:step_track/widgets/perfomance.dart';
import '../providers/health_provider.dart';
import '../providers/sim_provider.dart';


class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _showHUD = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(healthProviderInstance.notifier).checkPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthProviderInstance);
    final simState = ref.watch(simProviderInstance);

    final startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final buildTime = DateTime.now().difference(startTime);
      performanceHUDKey.currentState?.recordBuildTime(buildTime);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/permissions'),
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Navigator.pushNamed(context, '/debug'),
          ),
          IconButton(
            icon: Icon(_showHUD ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showHUD = !_showHUD;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          DashboardBody(
            healthState: healthState,
            simState: simState,
            ref: ref,
          ),
          if (_showHUD) PerformanceHUD(key: performanceHUDKey),
        ],
      ),
      floatingActionButton: !healthState.hasAllPermissions
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/permissions'),
              icon: const Icon(Icons.lock_open),
              label: const Text('Grant Permissions'),
            )
          : null,
    );
  }
}
