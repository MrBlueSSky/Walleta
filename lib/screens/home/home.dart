import 'package:flutter/material.dart';

import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/layaout/navbar/navBar.dart';

//!Cambiar todo esto
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<DriverPostBloc>().add(LoadDriversPosts());
    // });
  }

  int selectedIndex = 0;

  void handleTabChange(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  Widget _buildBody() {
    switch (selectedIndex) {
      case 0:
        return const Text("Inicio");
      case 1:
        return const Text("Quien me debe/debo");
      case 2:
        return const Text("Gastos Compartidos");
      case 3:
        return const Text("Perfil");
      default:
        return const Center(child: Text("Pantalla no encontrada"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        title: const Text(
          'Clientes Home',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Center(
        child: Text(
          'Bienvenido al Home de Clientes',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 20),
        ),
      ),
      bottomNavigationBar: NavBar(
        onTabChanged: handleTabChange,
        currentIndex: selectedIndex,
      ),
    );
  }
}
