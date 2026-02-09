import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_event.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/models/loan.dart';
import 'package:walleta/widgets/buttons/search_button.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';
import 'package:provider/provider.dart'; // 🔥 Asegúrate de importar Provider
import 'package:walleta/providers/ads_provider.dart'; // 🔥 Cambiar a AdsProvider

class AddLoanForm extends StatefulWidget {
  final BuildContext context;
  final bool isDark;
  final ScrollController scrollController;
  final StateSetter setDialogState;
  final List<Loan> _iOwe;

  const AddLoanForm({
    super.key,
    required this.context,
    required this.isDark,
    required this.scrollController,
    required this.setDialogState,
    required List<Loan> iOwe,
  }) : _iOwe = iOwe;

  @override
  State<AddLoanForm> createState() => _AddLoanFormState();
}

class _AddLoanFormState extends State<AddLoanForm> {
  late TextEditingController _personController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  final Uuid _uuid = Uuid();

  DateTime? _selectedDate;
  AppUser? _selectedUser;

  @override
  void initState() {
    super.initState();
    _personController = TextEditingController();
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _personController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, authState) {
        if (authState.status == AuthenticationStatus.unauthenticated) {
          return const SizedBox.shrink();
        }

        final appUser = authState.user!;

        return SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color:
                        widget.isDark
                            ? Colors.white30
                            : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Nuevo Préstamo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),

              // Campo de persona con buscador
              _buildPersonSearchField(),
              const SizedBox(height: 20),

              // Campo de monto
              Text(
                'Monto',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color:
                      widget.isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        widget.isDark
                            ? const Color(0xFF334155).withOpacity(0.3)
                            : const Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color:
                                widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                            fontSize: 16,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: TextStyle(
                              color:
                                  widget.isDark
                                      ? Colors.white60
                                      : const Color(0xFF9CA3AF),
                              fontSize: 16,
                              height: 1.2,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(
                                left: 12,
                                right: 8,
                              ),
                              child: Icon(
                                Iconsax.money,
                                size: 20,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '₡',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color:
                              widget.isDark
                                  ? Colors.white70
                                  : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Campo de descripción
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color:
                      widget.isDark
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        widget.isDark
                            ? const Color(0xFF334155).withOpacity(0.3)
                            : const Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _descriptionController,
                    style: TextStyle(
                      color:
                          widget.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                      fontSize: 16,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ej: Préstamo para...',
                      hintStyle: TextStyle(
                        color:
                            widget.isDark
                                ? Colors.white60
                                : const Color(0xFF9CA3AF),
                        fontSize: 16,
                        height: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 0, right: 8),
                        child: Icon(
                          Iconsax.note,
                          size: 20,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Campo de fecha
              Text(
                'Fecha límite',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: const Color(0xFF2D5BFF),
                            onPrimary: Colors.white,
                            onSurface:
                                widget.isDark
                                    ? Colors.white
                                    : const Color(0xFF1F2937),
                            surface:
                                widget.isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                            background:
                                widget.isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                          ),
                          dialogBackgroundColor:
                              widget.isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                          textTheme: TextTheme(
                            bodyMedium: TextStyle(
                              color:
                                  widget.isDark
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (picked != null && picked != _selectedDate) {
                    widget.setDialogState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        widget.isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          widget.isDark
                              ? const Color(0xFF334155).withOpacity(0.3)
                              : const Color(0xFFE5E7EB),
                      width: 0.5,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(
                          Iconsax.calendar,
                          size: 20,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                              : 'Seleccionar fecha límite',
                          style: TextStyle(
                            color:
                                _selectedDate != null
                                    ? (widget.isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937))
                                    : (widget.isDark
                                        ? Colors.white60
                                        : const Color(0xFF9CA3AF)),
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Iconsax.close_circle, size: 18),
                          color: const Color(0xFF6B7280),
                          onPressed: () {
                            widget.setDialogState(() {
                              _selectedDate = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // 🔥 BOTÓN DE GUARDAR CON ADSPROVIDER
              // En el botón de AddLoanForm - ORDEN CORRECTO
              Consumer<AdsProvider>(
                builder: (context, adsProvider, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_validateForm()) return;

                        print('📍 Validación exitosa, mostrando anuncio...');

                        // 🔥 ORDEN CORRECTO: Usar showAdOnButtonTap con callback
                        await adsProvider.showAdOnButtonTap(
                          context: context,
                          onAfterAd: () async {
                            // Esto se ejecuta DESPUÉS del anuncio (o inmediatamente si es premium)
                            print('✅ Guardando préstamo...');
                            await _saveLoan(appUser);

                            // Cerrar diálogo
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          onAdFailed: () {
                            print('⚠️ Anuncio falló, pero guardando igual...');
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D5BFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Guardar Préstamo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  bool _validateForm() {
    if (_selectedUser == null || _personController.text.isEmpty) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'Por favor, selecciona una persona',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
      return false;
    }

    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'Por favor, ingresa un monto válido',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
      return false;
    }

    if (_selectedDate == null) {
      TopSnackBarOverlay.show(
        context: context,
        message: 'Por favor, selecciona una fecha límite',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
      return false;
    }

    return true;
  }

  // 🔥 SIMPLIFICADO: Ya no necesita isPremium
  Future<void> _saveLoan(AppUser appUser) async {
    final newLoan = Loan(
      id: _uuid.v4(),
      lenderUserId: appUser,
      borrowerUserId: _selectedUser!,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : 'Préstamo',
      amount: double.parse(_amountController.text),
      paidAmount: 0.0,
      dueDate: _selectedDate!,
      status: LoanStatus.pendiente,
      color: const Color(0xFF2D5BFF),
      createdAt: DateTime.now(),
    );

    // Guardar préstamo
    final loanBloc = context.read<LoanBloc>();
    loanBloc.add(AddLoan(newLoan));

    // Mostrar mensaje de éxito
    TopSnackBarOverlay.show(
      context: context,
      message: 'Préstamo agregado',
      verticalOffset: 70.0,
      backgroundColor: const Color(0xFF00C896),
    );

    // Limpiar controles
    _amountController.clear();
    _descriptionController.clear();
    _personController.clear();
    _selectedUser = null;
    _selectedDate = null;
  }

  Widget _buildPersonSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Persona',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: widget.isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 4),
              child: SearchButton(
                size: 22,
                onUserSelected: (user) {
                  widget.setDialogState(() {
                    _selectedUser = AppUser(
                      name: user['name'] ?? '',
                      surname: user['surname'] ?? '',
                      email: user['email'] ?? '',
                      username: user['username'] ?? '',
                      profilePictureUrl: user['profilePictureUrl'] ?? '',
                      uid: user['uid'] ?? '',
                      phoneNumber: user['phoneNumber'] ?? '',
                    );
                    _personController.text =
                        '${user['name']} ${user['surname']}';
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color:
                widget.isDark
                    ? const Color(0xFF0F172A)
                    : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  widget.isDark
                      ? const Color(0xFF334155).withOpacity(0.3)
                      : const Color(0xFFE5E7EB),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: TextField(
                    controller: _personController,
                    readOnly: true,
                    style: TextStyle(
                      color:
                          widget.isDark
                              ? Colors.white
                              : const Color(0xFF1F2937),
                      fontSize: 16,
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar persona...',
                      hintStyle: TextStyle(
                        color:
                            widget.isDark
                                ? Colors.white60
                                : const Color(0xFF9CA3AF),
                        fontSize: 16,
                        height: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(left: 12, right: 8),
                        child: Icon(
                          Iconsax.user,
                          size: 20,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      suffixIcon:
                          _personController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Iconsax.close_circle,
                                  size: 18,
                                ),
                                color: const Color(0xFF6B7280),
                                onPressed: () {
                                  widget.setDialogState(() {
                                    _personController.clear();
                                    _selectedUser = null;
                                  });
                                },
                              )
                              : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_selectedUser != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient:
                        _selectedUser!.profilePictureUrl.isNotEmpty
                            ? null
                            : const LinearGradient(
                              colors: [Color(0xFF2D5BFF), Color(0xFF00C896)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                  ),
                  child:
                      _selectedUser!.profilePictureUrl.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              _selectedUser!.profilePictureUrl,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Center(
                            child: Text(
                              _selectedUser!.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${_selectedUser!.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            widget.isDark
                                ? Colors.white70
                                : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
