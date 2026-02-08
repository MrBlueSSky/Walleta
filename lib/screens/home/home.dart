// lib/screens/home.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:walleta/blocs/authentication/authentication.dart';
import 'package:walleta/screens/dashboard/dashbard.dart';
import 'package:walleta/screens/loans/loans.dart';
import 'package:walleta/screens/profile/profile.dart';
import 'package:walleta/screens/sharedExpenses/shared_expenses.dart';
import 'package:walleta/services/voice/voice_command_router.dart';
import 'package:walleta/services/voice/voice_finance.dart';
import 'package:walleta/widgets/animations/robot_thinking.dart';
import 'package:walleta/widgets/layaout/navbar/navBar.dart';
import 'package:walleta/widgets/popups/voice_result.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  bool _isRecording = false;
  late PageController _pageController;
  late VoiceFinanceService _voiceService;

  // Para mostrar resultados
  Map<String, dynamic>? _lastVoiceResult;
  bool _showVoiceResult = false;

  // Control del popup
  OverlayEntry? _voiceResultOverlay;
  bool _showVoicePopup = false;

  OverlayEntry? _processingOverlay;
  bool _isProcessing = false;

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
    _voiceService = VoiceFinanceService();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _voiceService.dispose();
    _hideVoiceResultPopup();
    super.dispose();
  }

  Future<void> _onMicPressed(bool isRecordingStart, bool isPremium) async {
    if (!isPremium) {
      _showErrorTopSnackbar(
        context,
        'Esta función es exclusiva para usuarios premium. ¡Actualiza para disfrutarla!',
      );
      return;
    }

    setState(() {
      if (isRecordingStart) {
        // Iniciar grabación
        _isRecording = true;
        _showVoiceResult = false;
        _lastVoiceResult = null;
        _startRecording();
      } else {
        // Detener grabación y procesar
        _isRecording = false;
        _processRecording();
      }
    });
  }

  Future<void> _startRecording() async {
    try {
      await _voiceService.startRecording();
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _showErrorTopSnackbar(context, 'Error iniciando grabación: $e');
    }
  }

  Future<void> _processRecording() async {
    _showProcessingSnackbar();

    try {
      final result = await _voiceService.stopRecordingAndProcess();

      _hideProcessingOverlay();

      if (result['data']['transaction_type'] != 'invalid') {
        setState(() {
          _lastVoiceResult = result;
          _showVoiceResult = true;
        });
        _showVoiceResultPopup(result);
      } else {
        _hideProcessingOverlay();
        _showErrorTopSnackbar(
          context,
          'No se pudo detectar una transacción válida. Intenta de nuevo.',
        );
      }
    } catch (e) {
      _hideProcessingOverlay();
      _showErrorTopSnackbar(context, 'Error procesando audio: $e');
    }
  }

  void _showProcessingSnackbar() {
    setState(() {
      _isProcessing = true;
    });

    _processingOverlay = OverlayEntry(
      builder: (context) {
        return RobotThinking();
      },
    );

    Overlay.of(context).insert(_processingOverlay!);
  }

  // Crea un método para ocultar el overlay
  void _hideProcessingOverlay() {
    if (_processingOverlay != null) {
      _processingOverlay!.remove();
      _processingOverlay = null;
    }
    setState(() {
      _isProcessing = false;
    });
  }

  void _showErrorTopSnackbar(BuildContext context, String message) {
    TopSnackBarOverlay.show(
      context: context,
      message: message,
      verticalOffset: 70.0,
      backgroundColor: const Color(0xFFFF6B6B),
    );
  }

  void _showVoiceResultPopup(Map<String, dynamic> result) {
    _hideVoiceResultPopup();

    _voiceResultOverlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _hideVoiceResultPopup,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),

            VoiceResultPopup(
              result: result,
              onSave: () async {
                _hideVoiceResultPopup();
                await VoiceCommandRouter.routeCommand(context, result);
              },
              onCancel: () {
                _hideVoiceResultPopup();
                setState(() {
                  _showVoiceResult = false;
                });
              },
              onClose: () {
                _hideVoiceResultPopup();
              },
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_voiceResultOverlay!);
    setState(() {
      _showVoicePopup = true;
    });
  }

  void _hideVoiceResultPopup() {
    if (_voiceResultOverlay != null) {
      _voiceResultOverlay!.remove();
      _voiceResultOverlay = null;
    }
    setState(() {
      _showVoicePopup = false;
    });
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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        final isPremium = authState.user.isPremium;

        final primaryColor = Theme.of(context).primaryColor;
        final primaryWithOpacity = Theme.of(
          context,
        ).primaryColor.withOpacity(0.3);

        return Scaffold(
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
                physics: const _SmoothNoOverscrollPhysics(),
                scrollDirection: Axis.horizontal,
                pageSnapping: true,
                children: _screens,
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            onMicPressed:
                (isRecordingStart) =>
                    _onMicPressed(isRecordingStart, isPremium),
            isRecording: _isRecording,
            isPremium: isPremium,
          ),

          floatingActionButton:
              _showVoiceResult && _lastVoiceResult != null && !_showVoicePopup
                  ? FloatingActionButton(
                    onPressed: () => _showVoiceResultPopup(_lastVoiceResult!),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryWithOpacity],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.voice_chat,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  )
                  : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        );
      },
    );
  }
}

//!Mover a otro archivo
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
    return offset * 1.5;
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    if (value < position.minScrollExtent) {
      return value - position.minScrollExtent;
    }
    if (value > position.maxScrollExtent) {
      return value - position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 120, stiffness: 300, damping: 1.8);
}
