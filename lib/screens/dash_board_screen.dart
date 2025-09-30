import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/widgets/perfomance.dart';
import '../providers/health_provider.dart';
import '../providers/sim_provider.dart';
import '../widgets/step_card.dart';
import '../widgets/hr_card.dart';
import '../widgets/steps_chart.dart';
import '../widgets/hr_chart.dart';

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
            onPressed: () {
              Navigator.pushNamed(context, '/permissions');
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.pushNamed(context, '/debug');
            },
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
          _buildBody(healthState, simState),
          if (_showHUD) PerformanceHUD(key: performanceHUDKey),
        ],
      ),
      floatingActionButton: !healthState.hasAllPermissions
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, '/permissions');
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Grant Permissions'),
            )
          : null,
    );
  }

  Widget _buildBody(HealthState healthState, SimState simState) {
    if (!healthState.hasAllPermissions && !simState.isEnabled) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Permissions Required',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please grant Health Connect permissions\nor enable simulation mode',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/permissions');
              },
              icon: const Icon(Icons.lock_open),
              label: const Text('Grant Permissions'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/debug');
              },
              icon: const Icon(Icons.bug_report),
              label: const Text('Enable Simulation'),
            ),
          ],
        ),
      );
    }

    if (healthState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (healthState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              healthState.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(healthProviderInstance.notifier).checkPermissions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (healthState.hasAllPermissions) {
          await ref.read(healthProviderInstance.notifier).startPolling();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (simState.isEnabled)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bug_report, color: Colors.orange),const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Simulation Mode Active',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        ref.read(simProviderInstance.notifier).disable();
                      },
                      child: const Text('Disable'),
                    ),
                  ],
                ),
              ),
            if (simState.isEnabled) const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StepCard(
                    // steps: healthState.todaySteps,
                    // subtitle: healthState.isPolling ? 'Live' : 'Today',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: HRCard(
                    lastHR: healthState.lastHR,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            StepsChart(
              records: healthState.stepRecords,
              windowMinutes: 60,
            ),
            const SizedBox(height: 16),
            HRChart(
              records: healthState.hrRecords,
              enableSmoothing: false,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}