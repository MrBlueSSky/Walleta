import 'package:flutter/material.dart';
import 'package:walleta/widgets/buttons/search_button.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 12), child: SearchButton()),
        ],
      ),
      body: const Center(child: Text('Dashboard')),
    );
  }
}
