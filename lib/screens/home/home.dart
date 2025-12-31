import 'package:flutter/material.dart';
import 'package:walleta/screens/dashboard/dashboardTest.dart';
import 'package:walleta/screens/profile/profile.dart';
import 'package:walleta/screens/savings/savings_account.dart';
import 'package:walleta/screens/sharedExpenses/shared_expenses.dart';
import 'package:walleta/screens/loans/loans.dart';
import 'package:walleta/screens/profile/profileTest.dart';
import 'package:walleta/themes/app_colors.dart';
import 'package:walleta/widgets/layaout/navbar/navBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  void handleTabChange(int index) {
    setState(() => selectedIndex = index);
  }

  Widget _buildBody() {
    switch (selectedIndex) {
      case 0:
        return const Dashboardtest();         
      case 1:
        return const SavingsAccountScreen();  
      case 2:
        return const SharedExpensesScreen();   
      case 3:
        return const Loans();                
      case 4:
        return const Profile();           
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: _buildBody(),
      bottomNavigationBar: NavBar(
        currentIndex: selectedIndex,
        onTabChanged: handleTabChange,
      ),
    );
  }
}
