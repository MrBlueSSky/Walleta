import 'package:flutter/material.dart';
import 'package:walleta/screens/dashboard/dashbard.dart';
import 'package:walleta/screens/profile/profile.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/layaout/navbar/navBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<DriverPostBloc>().add(LoadDriversPosts());
    // });
  }

  void handleTabChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (selectedIndex) {
      case 0:
        return const Dashboard();
      case 1:
        return const Center(child: Text("Quien me debe/debo"));
      case 2:
        return const Center(child: Text("Gastos Compartidos"));
      case 3:
        return const Profile();
      default:
        return const Center(child: Text("Pantalla no encontrada"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: _buildBody(),
      bottomNavigationBar: NavBar(
        onTabChanged: handleTabChange,
        currentIndex: selectedIndex,
      ),
    );
  }
}
