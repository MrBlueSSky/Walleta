// lib/screens/home.dart
import 'package:flutter/material.dart';
import 'package:walleta/screens/dashboard/dashbard.dart';
import 'package:walleta/screens/loans/loans.dart';
import 'package:walleta/screens/profile/profile.dart';
import 'package:walleta/screens/sharedExpenses/shared_expenses.dart';
import 'package:walleta/services/voice/voice_command_router.dart';
import 'package:walleta/services/voice/voice_finance.dart';
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
  late VoiceFinanceService _voiceService;

  // Para mostrar resultados
  Map<String, dynamic>? _lastVoiceResult;
  bool _showVoiceResult = false;

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
    super.dispose();
  }

  Future<void> _onMicPressed() async {
    setState(() {
      if (!_isRecording) {
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

      // Mostrar indicador de grabación
      _showRecordingSnackbar();
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      _showErrorSnackbar('Error iniciando grabación: $e');
    }
  }

  Future<void> _processRecording() async {
    // Mostrar indicador de procesamiento
    _showProcessingSnackbar();

    try {
      final result = await _voiceService.stopRecordingAndProcess();

      setState(() {
        _lastVoiceResult = result;
        _showVoiceResult = true;
      });

      // Mostrar resultado
      _showVoiceResultDialog(result);
    } catch (e) {
      _showErrorSnackbar('Error procesando audio: $e');
    }
  }

  void _showRecordingSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 10),
            const Text('Grabando... Habla ahora'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 10), // Largo porque es grabación
        action: SnackBarAction(
          label: 'Cancelar',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isRecording = false;
            });
            _voiceService.cancelRecording();
          },
        ),
      ),
    );
  }

  void _showProcessingSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
            const SizedBox(width: 10),
            const Text('Procesando con IA...'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showVoiceResultDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result['success'] == true ? Icons.check_circle : Icons.error,
                  color: result['success'] == true ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 10),
                Text(result['success'] == true ? 'Comando procesado' : 'Error'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Transcripción
                  if (result['transcription'] != null &&
                      result['transcription'].toString().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dijiste:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '"${result['transcription']}"',
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),

                  // Datos procesados
                  if (result['data'] != null && result['success'] == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Acción detectada:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        ListTile(
                          leading: _getTransactionTypeIcon(
                            result['data']['transaction_type']?.toString() ??
                                '',
                          ),
                          title: Text(
                            _getTransactionTypeText(
                              result['data']['transaction_type']?.toString() ??
                                  '',
                            ),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (result['data']['title'] != null &&
                                  result['data']['title'].toString().isNotEmpty)
                                Text('Título: ${result['data']['title']}'),
                              if (result['data']['amount'] != null)
                                Text(
                                  'Monto: \$${result['data']['amount']} ${result['data']['currency']?.toString() ?? 'MXN'}',
                                ),
                              if (result['data']['category'] != null &&
                                  result['data']['category'] != 'other')
                                Text(
                                  'Categoría: ${_getCategoryText(result['data']['category']?.toString() ?? '')}',
                                ),
                              if (result['data']['target_person'] != null &&
                                  result['data']['target_person']
                                      .toString()
                                      .isNotEmpty)
                                Text(
                                  'Persona: ${result['data']['target_person']}',
                                ),
                              if (result['data']['is_shared'] == true)
                                const Text('(Compartido)'),
                              if (result['data']['is_loan'] == true)
                                const Text('(Préstamo)'),
                            ],
                          ),
                        ),
                      ],
                    ),

                  // Mensaje del usuario
                  if (result['message'] != null &&
                      result['message'].toString().isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const Text(
                          'Mensaje:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(result['message'].toString()),
                        ),
                      ],
                    ),

                  // Información faltante
                  if (result['data']?['missing_info'] is List &&
                      (result['data']?['missing_info'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const Text(
                          'Información faltante:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ...(result['data']?['missing_info'] as List)
                            .map<Widget>(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '• ${_getMissingInfoText(item.toString())}',
                                  style: TextStyle(color: Colors.orange[700]),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),

                  // Acciones sugeridas
                  if (result['data']?['suggested_actions'] is List &&
                      (result['data']?['suggested_actions'] as List).isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const Text(
                          'Sugerencias:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 5),
                        ...(result['data']?['suggested_actions'] as List)
                            .map<Widget>(
                              (action) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  '• ${_getActionText(action.toString())}',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),

                  // Error
                  if (result['error'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const Text(
                          'Error:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          result['error'].toString(),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              if (result['success'] == true)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Cerrar diálogo
                    await VoiceCommandRouter.routeCommand(context, result);
                  },
                  child: const Text('Aceptar y Guardar'),
                ),
            ],
          ),
    );
  }

  // // Método para navegar basado en el tipo de transacción
  // void _navigateBasedOnTransaction(Map<String, dynamic>? data) {
  //   if (data == null) return;

  //   final type = data['transaction_type']?.toString() ?? '';

  //   switch (type) {
  //     case 'shared_expense':
  //     case 'split_bill':
  //       _onTabTapped(2); // Navegar a gastos compartidos
  //       break;
  //     case 'loan_given':
  //     case 'loan_received':
  //       _onTabTapped(1); // Navegar a préstamos
  //       break;
  //     default:
  //       // Mantenerse en el dashboard
  //       _onTabTapped(0);
  //   }
  // }

  Icon _getTransactionTypeIcon(String type) {
    switch (type) {
      case 'expense':
        return const Icon(Icons.money_off, color: Colors.red);
      case 'income':
        return const Icon(Icons.attach_money, color: Colors.green);
      case 'shared_expense':
        return const Icon(Icons.people, color: Colors.blue);
      case 'payment_to_person':
        return const Icon(Icons.person, color: Colors.purple);
      case 'loan_given':
        return const Icon(Icons.arrow_upward, color: Colors.orange);
      case 'loan_received':
        return const Icon(Icons.arrow_downward, color: Colors.teal);
      case 'money_request':
        return const Icon(Icons.notifications_active, color: Colors.amber);
      case 'split_bill':
        return const Icon(Icons.restaurant, color: Colors.pink);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  String _getTransactionTypeText(String type) {
    switch (type) {
      case 'expense':
        return 'Gasto';
      case 'income':
        return 'Ingreso';
      case 'shared_expense':
        return 'Gasto compartido';
      case 'payment_to_person':
        return 'Pago a persona';
      case 'loan_given':
        return 'Préstamo otorgado';
      case 'loan_received':
        return 'Préstamo recibido';
      case 'money_request':
        return 'Solicitud de dinero';
      case 'split_bill':
        return 'Cuenta dividida';
      case 'budget_setting':
        return 'Configurar presupuesto';
      case 'balance_check':
        return 'Consultar saldo';
      default:
        return 'Transacción';
    }
  }

  String _getCategoryText(String category) {
    switch (category) {
      case 'food':
        return 'Comida';
      case 'transport':
        return 'Transporte';
      case 'housing':
        return 'Hogar';
      case 'entertainment':
        return 'Entretenimiento';
      case 'shopping':
        return 'Compras';
      case 'health':
        return 'Salud';
      case 'education':
        return 'Educación';
      case 'salary':
        return 'Salario';
      case 'business':
        return 'Negocios';
      case 'investment':
        return 'Inversión';
      case 'savings':
        return 'Ahorros';
      case 'debt':
        return 'Deudas';
      default:
        return 'Otros';
    }
  }

  String _getMissingInfoText(String field) {
    switch (field) {
      case 'amount':
        return 'Monto';
      case 'currency':
        return 'Moneda';
      case 'category':
        return 'Categoría';
      case 'target_person':
        return 'Persona';
      case 'target_person_type':
        return 'Tipo de persona';
      case 'payment_method':
        return 'Método de pago';
      case 'title':
        return 'Título';
      default:
        return field;
    }
  }

  String _getActionText(String action) {
    switch (action) {
      case 'solicitar_monto':
        return 'Especifica el monto';
      case 'solicitar_persona':
        return 'Indica a quién se refiere';
      case 'solicitar_titulo':
        return 'Proporciona un título';
      case 'definir_participantes':
        return 'Define los participantes';
      case 'configurar_division':
        return 'Configura la división';
      case 'definir_plazo':
        return 'Define el plazo del préstamo';
      case 'establecer_interes':
        return 'Establece la tasa de interés';
      default:
        return action;
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
        onMicPressed: _onMicPressed,
        isRecording: _isRecording,
      ),

      // Mostrar floating button con resultado reciente
      floatingActionButton:
          _showVoiceResult && _lastVoiceResult != null
              ? FloatingActionButton(
                onPressed: () => _showVoiceResultDialog(_lastVoiceResult!),
                backgroundColor: Colors.deepPurple,
                child: const Icon(Icons.voice_chat),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
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
