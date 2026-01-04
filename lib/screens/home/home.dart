import 'package:flutter/material.dart';
import 'package:walleta/screens/dashboard/dashbard.dart';
import 'package:walleta/screens/loans/loans.dart';
import 'package:walleta/screens/profile/profile.dart';
import 'package:walleta/screens/sharedExpenses/shared_expenses.dart';
import 'package:walleta/widgets/layaout/navbar/navBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  bool _isRecording = false;
  late PageController _pageController;

  final List<Widget> _screens = [
    const FinancialDashboard(),
    const Loans(),
    const SharedExpensesScreen(),
    const Profile(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onMicPressed() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      // Iniciar grabación
    } else {
      // Detener grabación
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      extendBody: true,
      body: Container(
        color: const Color(0xFFF8FAFD),
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (notification) {
            notification.disallowIndicator();
            return true;
          },
          child: PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            physics: const _SmoothNoOverscrollPhysics(), // Un poco más suave
            scrollDirection: Axis.horizontal,
            pageSnapping: true,
            children: _screens,
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onMicPressed: _onMicPressed,
        isRecording: _isRecording,
      ),
    );
  }
}

// Physics un poco más suave pero manteniendo restricciones
class _SmoothNoOverscrollPhysics extends ScrollPhysics {
  const _SmoothNoOverscrollPhysics({super.parent});

  @override
  _SmoothNoOverscrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SmoothNoOverscrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get dragStartDistanceMotionThreshold => 1.0;

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Pequeño aumento de sensibilidad
    return offset * 1.5;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Previene overscroll pero permite un movimiento más suave
    if (value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    }
    if (value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  SpringDescription get spring => const SpringDescription(
    mass: 120, // Un poco más ligero == más rápido/responsivo
    stiffness: 300, // Menos rígido = más fácil de mover
    damping: 1.8, // Un poco menos amortiguación =
  );
}
