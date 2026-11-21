import 'package:flutter/material.dart';
import '../../data/datasources/dashboard_mock_data_source.dart';
import 'farmer_shell.dart';

/// Main Home Dashboard Screen for Green Flow.
/// Wraps and returns the persistent FarmerShell architecture.
class HomeScreen extends StatelessWidget {
  final DashboardMockDataSource dataSource;

  const HomeScreen({
    super.key,
    this.dataSource = const DashboardMockDataSource(),
  });

  @override
  Widget build(BuildContext context) {
    return const FarmerShell();
  }
}
