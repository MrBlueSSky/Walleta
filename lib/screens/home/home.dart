import 'package:flutter/material.dart';
import 'package:walleta/screens/dashboard/dashbard.dart';
import 'package:walleta/screens/profile/profile.dart';
import 'package:walleta/screens/savings/savings_account.dart';
import 'package:walleta/screens/sharedExpenses/shared_expenses.dart';
import 'package:walleta/widgets/layaout/navbar/navBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // int selectedIndex = 0;

  // void handleTabChange(int index) {
  //   setState(() => selectedIndex = index);
  // }

  int _currentIndex = 0;
  bool _isRecording = false;

  final List<Widget> _screens = [
    const FinancialDashboard(), // Tu dashboard
    const SavingsAccountScreen(),
    const SharedExpensesScreen(),
    const Profile(),
  ];

  void _onMicPressed() {
    setState(() {
      _isRecording = !_isRecording;
    });

    // Aquí puedes manejar la lógica del micrófono
    if (_isRecording) {
      // Iniciar grabación
    } else {
      // Detener grabación
    }
  }

  // Widget _buildBody() {
  //   switch (selectedIndex) {
  //     case 0:
  //       return const FinancialDashboard();
  //     case 1:
  //       return const SavingsAccountScreen();
  //     case 2:
  //       return const SharedExpensesScreen();
  //     case 3:
  //       return const Loans();
  //     case 4:
  //       return const Profile();
  //     default:
  //       return const SizedBox();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      extendBody:
          true, // Esto permite que el contenido se extienda detrás del navbar
      body: _screens[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onMicPressed: _onMicPressed,
        isRecording: _isRecording,
      ),
    );
  }
}
