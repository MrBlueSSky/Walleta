import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/sharedExpense/sharedExpense.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/widgets/buttons/search_button.dart';

class AddExpenseSheet extends StatefulWidget {
  final Function(SharedExpense) onSave;

  const AddExpenseSheet({Key? key, required this.onSave}) : super(key: key);

  @override
  State<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends State<AddExpenseSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalController = TextEditingController();
  final _paidController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? selectedCategory;
  List<Map<String, dynamic>> selectedParticipants = [];

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Comida',
      'icon': Icons.restaurant,
      'color': const Color(0xFF00C896),
    },
    {
      'name': 'Viajes',
      'icon': Iconsax.airplane,
      'color': const Color(0xFF2D5BFF),
    },
    {
      'name': 'Entretenimiento',
      'icon': Iconsax.video_play,
      'color': const Color(0xFF9C27B0),
    },
    {'name': 'Hogar', 'icon': Iconsax.home, 'color': const Color(0xFFFFA726)},
    {
      'name': 'Transporte',
      'icon': Iconsax.car,
      'color': const Color(0xFFFF6B6B),
    },
    {'name': 'Otros', 'icon': Iconsax.more, 'color': const Color(0xFF9CA3AF)},
  ];

  void _addParticipant(Map<String, dynamic> user) {
    bool alreadyAdded = selectedParticipants.any(
      (participant) => participant['username'] == user['username'],
    );

    if (!alreadyAdded) {
      setState(() {
        selectedParticipants.add(user);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      selectedParticipants.removeAt(index);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _paidController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final secondaryTextColor =
        isDark ? Colors.white70 : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header fijo
            Container(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Título y botón de cerrar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nuevo Gasto Compartido',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Iconsax.close_circle, size: 22),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenido principal con SingleChildScrollView
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sección 1: Información básica
                      Card(
                        elevation: 0,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFFE5E7EB).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Título del gasto
                              _buildSectionLabel('Título del gasto', isDark),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _titleController,
                                style: TextStyle(color: textColor),
                                decoration: InputDecoration(
                                  hintText:
                                      'Ej: Cena en restaurante, Viaje a la playa...',
                                  hintStyle: TextStyle(
                                    color: secondaryTextColor,
                                  ),
                                  filled: true,
                                  fillColor:
                                      isDark
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFFF9FAFB),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2D5BFF),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa un título';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Montos (Total y Pagado)
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionLabel('Total', isDark),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _totalController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: textColor,
                                            height: 1.0,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(
                                              color: secondaryTextColor,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16,
                                                right: 8,
                                              ),
                                              child: Align(
                                                widthFactor: 1.0,
                                                heightFactor: 1.0,
                                                child: Text(
                                                  '₡',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF00C896,
                                                    ),
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 0,
                                                ),
                                            filled: true,
                                            fillColor:
                                                isDark
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFFF9FAFB),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF2D5BFF),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                            alignLabelWithHint: true,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Requerido';
                                            }
                                            final total = double.tryParse(
                                              value,
                                            );
                                            if (total == null) {
                                              return 'Ingresa un número válido';
                                            }
                                            if (total <= 0) {
                                              return 'El total debe ser mayor a 0';
                                            }
                                            return null;
                                          },
                                          onChanged: (_) {
                                            // Forzar validación cruzada cuando cambia el total
                                            if (_paidController
                                                .text
                                                .isNotEmpty) {
                                              _formKey.currentState?.validate();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionLabel('Pagado', isDark),
                                        const SizedBox(height: 8),
                                        TextFormField(
                                          controller: _paidController,
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            color: textColor,
                                            height: 1.0,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(
                                              color: secondaryTextColor,
                                            ),
                                            prefixIcon: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 16,
                                                right: 8,
                                              ),
                                              child: Align(
                                                widthFactor: 1.0,
                                                heightFactor: 1.0,
                                                child: Text(
                                                  '₡',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(
                                                      0xFF00C896,
                                                    ),
                                                    height: 1.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                  minWidth: 24,
                                                  minHeight: 0,
                                                ),
                                            filled: true,
                                            fillColor:
                                                isDark
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFFF9FAFB),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide.none,
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF2D5BFF),
                                                width: 2,
                                              ),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 16,
                                                ),
                                            alignLabelWithHint: true,
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Requerido';
                                            }
                                            final paid = double.tryParse(value);
                                            if (paid == null) {
                                              return 'Ingresa un número válido';
                                            }
                                            if (paid < 0) {
                                              return 'El monto no puede ser negativo';
                                            }

                                            // NUEVA VALIDACIÓN: Pagado debe ser menor o igual al total
                                            final totalText =
                                                _totalController.text;
                                            if (totalText.isNotEmpty) {
                                              final total = double.tryParse(
                                                totalText,
                                              );
                                              if (total != null &&
                                                  paid > total) {
                                                return 'No puede pagar más del total';
                                              }
                                            }

                                            return null;
                                          },
                                          onChanged: (_) {
                                            // Forzar validación cruzada cuando cambia lo pagado
                                            if (_totalController
                                                .text
                                                .isNotEmpty) {
                                              _formKey.currentState?.validate();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Mensaje informativo de validación
                              if (_totalController.text.isNotEmpty &&
                                  _paidController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: _buildValidationMessage(),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sección 2: Categoría
                      Card(
                        elevation: 0,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFFE5E7EB).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Categoría', isDark),
                              const SizedBox(height: 16),

                              // Grid de categorías (2x3)
                              GridView.count(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                childAspectRatio: 1.2,
                                children:
                                    categories.map((cat) {
                                      final isSelected =
                                          selectedCategory == cat['name'];
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedCategory = cat['name'];
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                isSelected
                                                    ? cat['color'] as Color
                                                    : isDark
                                                    ? const Color(0xFF0F172A)
                                                    : const Color(0xFFF9FAFB),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? cat['color'] as Color
                                                      : const Color(0xFFE5E7EB),
                                              width: isSelected ? 0 : 1,
                                            ),
                                            boxShadow:
                                                isSelected
                                                    ? [
                                                      BoxShadow(
                                                        color: (cat['color']
                                                                as Color)
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ]
                                                    : null,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                cat['icon'] as IconData,
                                                color:
                                                    isSelected
                                                        ? Colors.white
                                                        : cat['color'] as Color,
                                                size: 22,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                cat['name'],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : textColor,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Sección 3: Participantes
                      Card(
                        elevation: 0,
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color(0xFFE5E7EB).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionLabel('Participantes', isDark),
                                  if (selectedParticipants.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2D5BFF,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${selectedParticipants.length}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D5BFF),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Botón de búsqueda de participantes (CON TEXTO)
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      isDark
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE5E7EB),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) =>
                                                _buildParticipantSearchDialog(
                                                  isDark,
                                                ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.search_normal,
                                            color: const Color(0xFF2D5BFF),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              'Buscar participantes...',
                                              style: TextStyle(
                                                color: secondaryTextColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Iconsax.arrow_right_3,
                                            color: secondaryTextColor,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Lista de participantes seleccionados
                              if (selectedParticipants.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Participantes seleccionados:',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: secondaryTextColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          selectedParticipants
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                                final index = entry.key;
                                                final participant = entry.value;
                                                final colorIndex =
                                                    index % categories.length;
                                                final chipColor =
                                                    categories[colorIndex]['color']
                                                        as Color;

                                                return _buildParticipantChip(
                                                  participant['username'] ??
                                                      'Usuario',
                                                  index,
                                                  chipColor,
                                                  isDark,
                                                );
                                              })
                                              .toList(),
                                    ),
                                  ],
                                ),

                              if (selectedParticipants.isEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? const Color(0xFF0F172A)
                                            : const Color(0xFFF9FAFB),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                      width: 1,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Iconsax.people,
                                        size: 32,
                                        color: secondaryTextColor.withOpacity(
                                          0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No hay participantes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Agrega amigos usando el buscador',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: secondaryTextColor.withOpacity(
                                            0.7,
                                          ),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),

            // Botón flotante (FIXED)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationMessage() {
    final totalText = _totalController.text;
    final paidText = _paidController.text;

    if (totalText.isEmpty || paidText.isEmpty) return const SizedBox();

    final total = double.tryParse(totalText) ?? 0;
    final paid = double.tryParse(paidText) ?? 0;
    final remaining = total - paid;

    Color getMessageColor() {
      if (paid == 0) return const Color(0xFFF59E0B); // Amarillo/naranja
      if (paid < total) return const Color(0xFF2D5BFF); // Azul
      return const Color(0xFF10B981); // Verde
    }

    String getMessage() {
      if (paid == 0) return 'Falta pagar: ₡${remaining.toStringAsFixed(2)}';
      if (paid < total) return 'Restante: ₡${remaining.toStringAsFixed(2)}';
      return '✓ Pago completo';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: getMessageColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: getMessageColor().withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            paid >= total ? Iconsax.tick_circle : Iconsax.info_circle,
            size: 16,
            color: getMessageColor(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              getMessage(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: getMessageColor(),
              ),
            ),
          ),
          if (paid < total)
            Text(
              '${((paid / total) * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: getMessageColor(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildParticipantSearchDialog(bool isDark) {
    return Dialog(
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Buscar Participantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),

            // Aquí iría el SearchButton real
            SearchButton(
              onUserSelected: (user) {
                _addParticipant(user);
                Navigator.pop(context);
              },
              iconColor: const Color(0xFF2D5BFF),
              size: 20,
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF374151),
      ),
    );
  }

  Widget _buildParticipantChip(
    String username,
    int index,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar inicial
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(
              child: Text(
                username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Nombre de usuario
          Text(
            username,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 8),
          // Botón para eliminar
          GestureDetector(
            onTap: () => _removeParticipant(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 12, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D5BFF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: const Color(0xFF2D5BFF).withOpacity(0.3),
            ),
            child: const Text(
              'Crear Gasto Compartido',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate() &&
        selectedCategory != null &&
        selectedParticipants.isNotEmpty) {
      // VALIDACIÓN FINAL: Asegurar que pagado <= total
      final total = double.tryParse(_totalController.text) ?? 0;
      final paid = double.tryParse(_paidController.text) ?? 0;

      if (paid > total) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('El monto pagado no puede ser mayor al total'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }

      final category = categories.firstWhere(
        (cat) => cat['name'] == selectedCategory,
      );

      final expense = SharedExpense(
        title: _titleController.text,
        total: total,
        paid: paid,
        participants:
            selectedParticipants.map((p) => p['username'] as String).toList(),
        category: selectedCategory!,
        categoryIcon: category['icon'],
        categoryColor: category['color'],
      );

      final AppUser user = context.read<AuthenticationBloc>().state.user;
      context.read<SharedExpenseBloc>().add(
        AddSharedExpense(userId: user.uid, expense: expense),
      );

      widget.onSave(expense);
      Navigator.pop(context);
    } else {
      String message = 'Por favor completa todos los campos';
      if (selectedParticipants.isEmpty) {
        message = 'Agrega al menos un participante';
      } else if (selectedCategory == null) {
        message = 'Selecciona una categoría';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}
