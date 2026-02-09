import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_event.dart';
import 'package:walleta/blocs/loan/bloc/loan_state.dart';
import 'package:walleta/blocs/payment/bloc/payment_bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_event.dart';
import 'package:walleta/blocs/payment/bloc/payment_state.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/models/payment.dart';
import 'package:walleta/models/transaction.dart';
import 'package:walleta/utils/formatters.dart';

class LoansSection extends StatefulWidget {
  const LoansSection({
    super.key,
    required this.cardColor,
    required this.textColor,
  });
  final Color cardColor;
  final Color textColor;

  @override
  State<LoansSection> createState() => _LoansSectionState();
}

class _LoansSectionState extends State<LoansSection> {
  bool _initialLoadDone = false;
  bool _isLoading = false;
  bool _paymentsLoaded = false;

  // Método actualizado usando Formatters
  String _formatCurrencyNoDecimals(double amount) {
    return Formatters.formatCurrencyNoDecimals(amount);
  }

  @override
  void initState() {
    super.initState();
    // Cargar datos después de que el widget esté montado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    if (!_initialLoadDone && !_isLoading && mounted) {
      final authState = context.read<AuthenticationBloc>().state;
      final userId = authState.user.uid;

      print('🔄 Cargando datos para usuario: $userId');

      // Solo cargar préstamos primero
      final loanState = context.read<LoanBloc>().state;
      if (loanState.status == LoanStateStatus.initial ||
          loanState.status == LoanStateStatus.error) {
        context.read<LoanBloc>().add(LoadLoans(userId));
      } else {
        // Si ya tenemos préstamos, cargar pagos
        _loadPaymentsBasedOnLoans(loanState.loans, userId);
      }

      _initialLoadDone = true;
    }
  }

  void _loadPaymentsBasedOnLoans(List<Loan> loans, String userId) {
    if (loans.isEmpty) {
      print('⚠️  Usuario sin préstamos, no hay pagos que cargar');
      return;
    }

    final loanIds = loans.map((loan) => loan.id).toList();
    print('📋 IDs de préstamos para buscar pagos: ${loanIds.length}');

    // Cargar pagos usando los IDs de préstamos
    context.read<PaymentBloc>().add(LoadPaymentsByLoanIds(userId, loanIds));
    _paymentsLoaded = true;
  }

  void _retryLoading() {
    if (mounted) {
      setState(() {
        _initialLoadDone = false;
        _isLoading = false;
        _paymentsLoaded = false; // ✅ Resetear también esta variable
      });
      _loadInitialData();
    }
  }

  // Combinar préstamos y pagos en una sola lista de transacciones
  List<Transaction> _combineTransactions(
    List<Loan> loans,
    List<Payment> payments,
    String currentUserId,
  ) {
    final transactions = <Transaction>[];

    // 1. Procesar préstamos
    _addLoanTransactions(transactions, loans, currentUserId);

    // 2. Procesar pagos (con validación estricta)
    _addPaymentTransactions(transactions, payments, loans, currentUserId);

    // 3. Ordenar
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  void _addLoanTransactions(
    List<Transaction> transactions,
    List<Loan> loans,
    String currentUserId,
  ) {
    for (var loan in loans) {
      try {
        // Validar que el usuario participa en el préstamo
        final userParticipates =
            loan.lenderUserId.uid == currentUserId ||
            loan.borrowerUserId.uid == currentUserId;

        if (!userParticipates) {
          continue;
        }

        final isLender = loan.lenderUserId.uid == currentUserId;
        final otherPerson =
            isLender
                ? '${loan.borrowerUserId.name} ${loan.borrowerUserId.surname}'
                : '${loan.lenderUserId.name} ${loan.lenderUserId.surname}';
        final transactionDate = loan.createdAt ?? loan.dueDate;

        transactions.add(
          Transaction(
            id: 'loan_${loan.id}',
            date: transactionDate,
            amount: loan.amount,
            isOutgoing: isLender, // Es salida si es prestamista
            description:
                loan.description.isNotEmpty
                    ? loan.description
                    : 'Préstamo ${isLender ? 'otorgado' : 'recibido'}',
            otherPersonName: otherPerson,
            type: TransactionType.loanCreated,
            color: loan.color,
          ),
        );
      } catch (e) {
        print('Error procesando préstamo ${loan.id}: $e');
      }
    }
  }

  void _addPaymentTransactions(
    List<Transaction> transactions,
    List<Payment> payments,
    List<Loan> loans,
    String currentUserId,
  ) {
    // Crear mapa para búsqueda rápida de préstamos
    final loanMap = {for (var loan in loans) loan.id: loan};

    for (var payment in payments) {
      // Validaciones antes de procesar
      if (!_isValidPayment(payment, currentUserId, loanMap)) {
        continue;
      }

      final associatedLoan = loanMap[payment.loanId]!;
      final isUserLender = associatedLoan.lenderUserId.uid == currentUserId;

      final otherPerson =
          isUserLender
              ? '${associatedLoan.borrowerUserId.name} ${associatedLoan.borrowerUserId.surname}'
              : '${associatedLoan.lenderUserId.name} ${associatedLoan.lenderUserId.surname}';

      transactions.add(
        Transaction(
          id: 'payment_${payment.id}',
          date: payment.date,
          amount: payment.amount,
          isOutgoing: payment.userId == currentUserId,
          description:
              payment.userId == currentUserId
                  ? 'Pago realizado'
                  : 'Pago recibido',
          otherPersonName: otherPerson,
          type: TransactionType.payment,
        ),
      );
    }
  }

  bool _isValidPayment(
    Payment payment,
    String currentUserId,
    Map<String, Loan> loanMap,
  ) {
    // 1. Debe tener un loanId válido
    if (payment.loanId.isEmpty) {
      return false;
    }

    // 2. Debe existir el préstamo asociado
    if (!loanMap.containsKey(payment.loanId)) {
      print('⚠️  Pago ${payment.id} sin préstamo válido: ${payment.loanId}');
      return false;
    }

    final loan = loanMap[payment.loanId]!;

    // 3. El usuario debe participar en el préstamo como LENDER o BORROWER
    final userParticipates =
        loan.lenderUserId.uid == currentUserId ||
        loan.borrowerUserId.uid == currentUserId;

    if (!userParticipates) {
      print('⚠️  Usuario no participa en préstamo ${loan.id}');
      return false;
    }

    // 4. ACEPTAR el pago sin importar quién lo hizo
    // (antes solo aceptaba si payment.userId == currentUserId)
    return true;
  }

  // Icono según tipo de transacción
  IconData _getTransactionIcon(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.loanCreated:
        return transaction.isOutgoing
            ? Icons.credit_card_outlined
            : Icons.account_balance_wallet_outlined;
      case TransactionType.payment:
        return transaction.isOutgoing
            ? Icons.arrow_upward
            : Icons.arrow_downward;
    }
  }

  // Texto descriptivo según tipo
  String _getTransactionDescription(Transaction transaction) {
    switch (transaction.type) {
      case TransactionType.loanCreated:
        return transaction.isOutgoing
            ? 'Préstamo otorgado'
            : 'Préstamo recibido';
      case TransactionType.payment:
        return transaction.description;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Hoy ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (transactionDate == yesterday) {
      return 'Ayer ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    final diff = today.difference(transactionDate).inDays;
    if (diff < 7) {
      return 'Hace $diff días';
    }

    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        final currentUserId = authState.user.uid;

        return BlocConsumer<LoanBloc, LoanState>(
          listener: (context, loanState) {
            // ✅ Cuando los préstamos se cargan exitosamente, cargar los pagos
            if (loanState.status == LoanStateStatus.success &&
                !_paymentsLoaded &&
                mounted) {
              final loanIds = loanState.loans.map((loan) => loan.id).toList();
              if (loanIds.isNotEmpty) {
                print('🔄 Préstamos cargados, ahora cargando pagos...');
                print('📋 IDs de préstamos para pagos: ${loanIds.length}');

                context.read<PaymentBloc>().add(
                  LoadPaymentsByLoanIds(currentUserId, loanIds),
                );
                _paymentsLoaded = true;
              } else {
                print('⚠️  No hay préstamos, no se cargarán pagos');
              }
            }
          },
          builder: (context, loanState) {
            return BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, paymentState) {
                // Verificar si necesitamos cargar datos iniciales
                if (loanState.status == LoanStateStatus.initial &&
                    !_initialLoadDone &&
                    !_isLoading &&
                    mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadInitialData();
                  });
                }

                // Si hay error en cualquiera de los dos, mostrar estado de error
                if (loanState.status == LoanStateStatus.error ||
                    paymentState.status == PaymentStateStatus.error) {
                  print(
                    'Error detectado - LoanState: ${loanState.status}, PaymentState: ${paymentState.status}',
                  );
                  return _buildErrorState(
                    loanError: loanState.status == LoanStateStatus.error,
                    paymentError:
                        paymentState.status == PaymentStateStatus.error,
                  );
                }

                // Si está cargando (préstamos O pagos)
                if (loanState.status == LoanStateStatus.loading ||
                    paymentState.status == PaymentStateStatus.loading) {
                  return _buildLoadingState();
                }

                // Verificar si los préstamos se cargaron pero no los pagos
                if (loanState.status == LoanStateStatus.success &&
                    !_paymentsLoaded &&
                    loanState.loans.isNotEmpty) {
                  // Esto debería dispararse en el listener, pero por si acaso
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_paymentsLoaded) {
                      final loanIds =
                          loanState.loans.map((loan) => loan.id).toList();
                      context.read<PaymentBloc>().add(
                        LoadPaymentsByLoanIds(currentUserId, loanIds),
                      );
                      _paymentsLoaded = true;
                    }
                  });
                  return _buildLoadingState();
                }

                // Si no hay préstamos ni pagos
                if (loanState.loans.isEmpty && paymentState.payments.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Combinar transacciones
                final transactions = _combineTransactions(
                  loanState.loans,
                  paymentState.payments,
                  currentUserId,
                );

                // Tomar solo los últimos 6 movimientos
                final recentTransactions = transactions.take(6).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: widget.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Todos los Movimientos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: widget.textColor,
                            ),
                          ),
                          Text(
                            '${transactions.length} mov${transactions.length != 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.textColor.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Resumen rápido
                      if (transactions.isNotEmpty) ...[
                        _buildQuickSummary(transactions),
                        const SizedBox(height: 16),
                      ],

                      // Lista de movimientos
                      if (recentTransactions.isEmpty)
                        _buildEmptyState(context)
                      else
                        Column(
                          children:
                              recentTransactions.map((transaction) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      // Icono con color
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color:
                                              transaction.isOutgoing
                                                  ? const Color(
                                                    0xFFFF6B6B,
                                                  ).withOpacity(0.1)
                                                  : const Color(
                                                    0xFF00C896,
                                                  ).withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            _getTransactionIcon(transaction),
                                            size: 18,
                                            color:
                                                transaction.isOutgoing
                                                    ? const Color(0xFFFF6B6B)
                                                    : const Color(0xFF00C896),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Detalles
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction.otherPersonName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: widget.textColor,
                                              ),
                                            ),
                                            Text(
                                              _getTransactionDescription(
                                                transaction,
                                              ),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: widget.textColor
                                                    .withOpacity(0.6),
                                              ),
                                            ),
                                            if (transaction.type ==
                                                TransactionType
                                                    .loanCreated) ...[
                                              const SizedBox(height: 2),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: (transaction.color ??
                                                          Colors.grey)
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  transaction.isOutgoing
                                                      ? 'Otorgado'
                                                      : 'Recibido',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color:
                                                        transaction.color ??
                                                        Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Monto y fecha
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${transaction.isOutgoing ? '-' : '+'}${_formatCurrencyNoDecimals(transaction.amount)}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  transaction.isOutgoing
                                                      ? const Color(0xFFFF6B6B)
                                                      : const Color(0xFF00C896),
                                            ),
                                          ),
                                          Text(
                                            _formatDate(transaction.date),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: widget.textColor
                                                  .withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        ),

                      // Botón para ver más si hay muchos movimientos
                      if (transactions.length > 6)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                //! Navegar a historial completo solo si user premium
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: widget.textColor.withOpacity(
                                  0.7,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Ver historial completo',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: widget.textColor.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: widget.textColor.withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Resumen rápido de ingresos vs egresos
  Widget _buildQuickSummary(List<Transaction> transactions) {
    double totalIngresos = 0;
    double totalEgresos = 0;

    for (var transaction in transactions) {
      if (transaction.isOutgoing) {
        totalEgresos += transaction.amount;
      } else {
        totalIngresos += transaction.amount;
      }
    }

    final balance = totalIngresos - totalEgresos;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.textColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'Ingresos',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '+${_formatCurrencyNoDecimals(totalIngresos)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00C896),
                ),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 1,
            color: widget.textColor.withOpacity(0.2),
          ),
          Column(
            children: [
              Text(
                'Egresos',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '-${_formatCurrencyNoDecimals(totalEgresos)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
          Container(
            height: 30,
            width: 1,
            color: widget.textColor.withOpacity(0.2),
          ),
          Column(
            children: [
              Text(
                'Balance',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.textColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${balance >= 0 ? '+' : ''}${_formatCurrencyNoDecimals(balance.abs())}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      balance >= 0
                          ? const Color(0xFF00C896)
                          : const Color(0xFFFF6B6B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            height: 20,
            decoration: BoxDecoration(
              color: widget.textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: widget.textColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100,
                          height: 14,
                          decoration: BoxDecoration(
                            color: widget.textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 80,
                          height: 12,
                          decoration: BoxDecoration(
                            color: widget.textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 60,
                        height: 14,
                        decoration: BoxDecoration(
                          color: widget.textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                          color: widget.textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({bool loanError = true, bool paymentError = true}) {
    String errorMessage = 'Error al cargar movimientos';

    if (loanError && !paymentError) {
      errorMessage = 'Error al cargar préstamos';
    } else if (!loanError && paymentError) {
      errorMessage = 'Error al cargar pagos';
    }

    return Container(
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Todos los Movimientos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.textColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: const Color(0xFFFF6B6B),
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _retryLoading,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2D5BFF),
                  ),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final isSmallScreen = MediaQuery.of(context).size.width < 350;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 0),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 24 : 32,
      ),
      decoration: BoxDecoration(
        color: widget.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: primaryColor.withOpacity(0.1), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Contenedor circular para el ícono
          Container(
            width: isSmallScreen ? 80 : 100,
            height: isSmallScreen ? 80 : 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor.withOpacity(0.1),
                  primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    size: isSmallScreen ? 40 : 48,
                    color: primaryColor.withOpacity(0.7),
                  ),
                ),
                // Efecto sutil de puntos
                Positioned(
                  top: isSmallScreen ? 12 : 16,
                  right: isSmallScreen ? 12 : 16,
                  child: Container(
                    width: isSmallScreen ? 8 : 10,
                    height: isSmallScreen ? 8 : 10,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: isSmallScreen ? 20 : 24,
                  left: isSmallScreen ? 20 : 24,
                  child: Container(
                    width: isSmallScreen ? 6 : 8,
                    height: isSmallScreen ? 6 : 8,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 24),

          // Título principal
          Text(
            'No hay movimientos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
              height: 1.3,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          // Descripción
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
            child: Text(
              'Los préstamos activos y los pagos realizados aparecerán aquí automáticamente',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: widget.textColor.withOpacity(0.6),
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
        ],
      ),
    );
  }
}
