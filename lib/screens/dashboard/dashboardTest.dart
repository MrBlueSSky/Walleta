import 'package:flutter/material.dart';

class Dashboardtest extends StatefulWidget {
  const Dashboardtest({super.key});

  @override
  State<Dashboardtest> createState() => _DashboardtestState();
}

class _DashboardtestState extends State<Dashboardtest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Walleta Test')),
      body: const Center(child: Text('Dashboard Test')),
    );
  }
}
