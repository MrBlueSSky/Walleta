import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/blocs/income/bloc/incomes_bloc.dart';
import 'package:walleta/blocs/income/bloc/incomes_event.dart';
import 'package:walleta/models/income.dart';
import 'package:walleta/widgets/snackBar/snackBar.dart';
import 'package:provider/provider.dart'; // 🔥 Importar Provider
import 'package:walleta/providers/ads_provider.dart'; // 🔥 Importar AdsProvider

class PersonalIncomeSheet extends StatefulWidget {
  final String userId;

  const PersonalIncomeSheet({Key? key, required this.userId}) : super(key: key);

  @override
  State<PersonalIncomeSheet> createState() => _AddPersonalIncomeSheetState();
}

class _AddPersonalIncomeSheetState extends State<PersonalIncomeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _totalController = TextEditingController();
  final _receivedController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? selectedCategory;
  DateTime? selectedDate;

  final List<Map<String, dynamic>> categories = [
    {'name': 'Salario', 'icon': Icons.work, 'color': const Color(0xFF2D5BFF)},
    {
      'name': 'Freelance',
      'icon': Icons.computer,
      'color': const Color(0xFF10B981),
    },
    {
      'name': 'Inversiones',
      'icon': Icons.trending_up,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'name': 'Regalos',
      'icon': Icons.card_giftcard,
      'color': const Color(0xFFEC4899),
    },
    {'name': 'Ventas', 'icon': Icons.store, 'color': const Color(0xFFF59E0B)},
    {
      'name': 'Otros',
      'icon': Icons.more_horiz,
      'color': const Color(0xFF9CA3AF),
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _receivedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: ThemeData(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF2D5BFF),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
            dialogBackgroundColor:
                isDark ? const Color(0xFF1E293B) : Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
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
        child: Stack(
          children: [
            Column(
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
                              'Nuevo Ingreso Personal',
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

                // Contenido principal
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
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
                                  // Título del ingreso
                                  _buildSectionLabel(
                                    'Título del ingreso',
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _titleController,
                                    style: TextStyle(color: textColor),
                                    decoration: InputDecoration(
                                      hintText:
                                          'Ej: Salario, Ventas, Inversión...',
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

                                  const SizedBox(height: 16),

                                  // Descripción (opcional)
                                  _buildSectionLabel(
                                    'Descripción (opcional)',
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _descriptionController,
                                    style: TextStyle(color: textColor),
                                    maxLines: 2,
                                    decoration: InputDecoration(
                                      hintText: 'Detalles adicionales...',
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
                                  ),

                                  const SizedBox(height: 16),

                                  // Fecha
                                  _buildSectionLabel(
                                    'Fecha del ingreso',
                                    isDark,
                                  ),
                                  const SizedBox(height: 12),
                                  GestureDetector(
                                    onTap: () => _selectDate(context),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
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
                                      child: Row(
                                        children: [
                                          Icon(
                                            Iconsax.calendar,
                                            color: const Color(0xFF2D5BFF),
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              selectedDate != null
                                                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                                                  : 'Seleccionar fecha',
                                              style: TextStyle(
                                                color:
                                                    selectedDate != null
                                                        ? textColor
                                                        : secondaryTextColor,
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
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sección 2: Montos
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
                                  _buildSectionLabel(
                                    'Monto del ingreso',
                                    isDark,
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionLabel(
                                              'Total esperado',
                                              isDark,
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              controller: _totalController,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                        ? const Color(
                                                          0xFF0F172A,
                                                        )
                                                        : const Color(
                                                          0xFFF9FAFB,
                                                        ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Color(
                                                              0xFFE5E7EB,
                                                            ),
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Color(
                                                              0xFF2D5BFF,
                                                            ),
                                                            width: 2,
                                                          ),
                                                    ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
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
                                                if (_receivedController
                                                    .text
                                                    .isNotEmpty) {
                                                  _formKey.currentState
                                                      ?.validate();
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
                                            _buildSectionLabel(
                                              'Recibido',
                                              isDark,
                                            ),
                                            const SizedBox(height: 8),
                                            TextFormField(
                                              controller: _receivedController,
                                              keyboardType:
                                                  TextInputType.number,
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                        fontWeight:
                                                            FontWeight.w600,
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
                                                        ? const Color(
                                                          0xFF0F172A,
                                                        )
                                                        : const Color(
                                                          0xFFF9FAFB,
                                                        ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Color(
                                                              0xFFE5E7EB,
                                                            ),
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: Color(
                                                              0xFF2D5BFF,
                                                            ),
                                                            width: 2,
                                                          ),
                                                    ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 16,
                                                    ),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Requerido';
                                                }
                                                final received =
                                                    double.tryParse(value);
                                                if (received == null) {
                                                  return 'Ingresa un número válido';
                                                }
                                                if (received < 0) {
                                                  return 'El monto no puede ser negativo';
                                                }
                                                final totalText =
                                                    _totalController.text;
                                                if (totalText.isNotEmpty) {
                                                  final total = double.tryParse(
                                                    totalText,
                                                  );
                                                  if (total != null &&
                                                      received > total) {
                                                    return 'No puede recibir más del total esperado';
                                                  }
                                                }
                                                return null;
                                              },
                                              onChanged: (_) {
                                                if (_totalController
                                                    .text
                                                    .isNotEmpty) {
                                                  _formKey.currentState
                                                      ?.validate();
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Mensaje informativo
                                  if (_totalController.text.isNotEmpty &&
                                      _receivedController.text.isNotEmpty)
                                    _buildValidationMessage(),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Sección 3: Categoría
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
                                      _buildSectionLabel('Categoría', isDark),
                                      if (selectedCategory != null)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: categories
                                                .firstWhere(
                                                  (cat) =>
                                                      cat['name'] ==
                                                      selectedCategory,
                                                )['color']
                                                .withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            selectedCategory!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  categories.firstWhere(
                                                    (cat) =>
                                                        cat['name'] ==
                                                        selectedCategory,
                                                  )['color'],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Grid de categorías (3x3)
                                  GridView.count(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                                        ? const Color(
                                                          0xFF0F172A,
                                                        )
                                                        : const Color(
                                                          0xFFF9FAFB,
                                                        ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color:
                                                      isSelected
                                                          ? cat['color']
                                                              as Color
                                                          : const Color(
                                                            0xFFE5E7EB,
                                                          ),
                                                  width: isSelected ? 0 : 1,
                                                ),
                                                boxShadow:
                                                    isSelected
                                                        ? [
                                                          BoxShadow(
                                                            color: (cat['color']
                                                                    as Color)
                                                                .withOpacity(
                                                                  0.3,
                                                                ),
                                                            blurRadius: 8,
                                                            offset:
                                                                const Offset(
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
                                                            : cat['color']
                                                                as Color,
                                                    size: 22,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    cat['name'],
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
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

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 🔥 BOTÓN CON ADSPROVIDER
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
    final receivedText = _receivedController.text;

    if (totalText.isEmpty || receivedText.isEmpty) return const SizedBox();

    final total = double.tryParse(totalText) ?? 0;
    final received = double.tryParse(receivedText) ?? 0;
    final remaining = total - received;

    Color getMessageColor() {
      if (received == 0) return const Color(0xFFF59E0B);
      if (received < total) return const Color(0xFF2D5BFF);
      return const Color(0xFF10B981);
    }

    String getMessage() {
      if (received == 0)
        return 'Falta recibir: ₡${remaining.toStringAsFixed(2)}';
      if (received < total)
        return 'Por recibir: ₡${remaining.toStringAsFixed(2)}';
      return '✓ Ingreso completo';
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
            received >= total ? Iconsax.tick_circle : Iconsax.info_circle,
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
          if (received < total)
            Text(
              '${((received / total) * 100).toStringAsFixed(0)}%',
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

  // 🔥 MODIFICADO: BOTÓN CON ADSPROVIDER
  Widget _buildBottomBar(bool isDark) {
    return Consumer<AdsProvider>(
      builder: (context, adsProvider, child) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(
              top: BorderSide(
                color:
                    isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
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
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      selectedCategory != null) {
                    // Validación final: Asegurar que recibido <= total
                    final total = double.tryParse(_totalController.text) ?? 0;
                    final received =
                        double.tryParse(_receivedController.text) ?? 0;

                    if (received > total) {
                      TopSnackBarOverlay.show(
                        context: context,
                        message:
                            'El monto recibido no puede ser mayor al total esperado',
                        verticalOffset: 70.0,
                        backgroundColor: const Color(0xFFFF6B6B),
                      );
                      return;
                    }

                    final category = categories.firstWhere(
                      (cat) => cat['name'] == selectedCategory,
                    );

                    final income = Incomes(
                      id: null,
                      title: _titleController.text,
                      total: total,
                      paid: received,
                      category: selectedCategory!,
                      categoryIcon: category['icon'] as IconData,
                      categoryColor: category['color'] as Color,
                      status:
                          received >= total
                              ? 'received'
                              : received > 0
                              ? 'partially_received'
                              : 'pending',
                      date: selectedDate,
                    );

                    // 🔥 USAR ADSPROVIDER PARA MOSTRAR ANUNCIO
                    await adsProvider.showAdOnButtonTap(
                      context: context,
                      onAfterAd: () {
                        // Guardar el ingreso después del anuncio
                        _saveIncomeDirectly(income);
                      },
                      onAdFailed: () {
                        // Si falla el anuncio, guardar igual
                        _saveIncomeDirectly(income);
                      },
                    );
                  } else {
                    String message = 'Por favor completa todos los campos';
                    if (selectedCategory == null) {
                      message = 'Selecciona una categoría';
                    }

                    TopSnackBarOverlay.show(
                      context: context,
                      message: message,
                      verticalOffset: 70.0,
                      backgroundColor: const Color(0xFFFF6B6B),
                    );
                  }
                },
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
                  'Guardar Ingreso Personal',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 🔥 NUEVO: Método para guardar directamente
  void _saveIncomeDirectly(Incomes income) {
    // Agregar el ingreso a través del BLoC
    context.read<IncomesBloc>().add(
      AddIncomes(income: income, userId: widget.userId),
    );

    TopSnackBarOverlay.show(
      context: context,
      message: 'Ingreso añadido',
      verticalOffset: 70.0,
      backgroundColor: const Color(0xFF00C896),
    );

    Navigator.pop(context);
  }

  // 🔥 MÉTODO ORIGINAL (para compatibilidad)
  void _saveIncome() {
    if (_formKey.currentState!.validate() && selectedCategory != null) {
      // Validación final: Asegurar que recibido <= total
      final total = double.tryParse(_totalController.text) ?? 0;
      final received = double.tryParse(_receivedController.text) ?? 0;

      if (received > total) {
        TopSnackBarOverlay.show(
          context: context,
          message: 'El monto recibido no puede ser mayor al total esperado',
          verticalOffset: 70.0,
          backgroundColor: const Color(0xFFFF6B6B),
        );
        return;
      }

      final category = categories.firstWhere(
        (cat) => cat['name'] == selectedCategory,
      );

      final income = Incomes(
        id: null,
        title: _titleController.text,
        total: total,
        paid: received,
        category: selectedCategory!,
        categoryIcon: category['icon'] as IconData,
        categoryColor: category['color'] as Color,
        status:
            received >= total
                ? 'received'
                : received > 0
                ? 'partially_received'
                : 'pending',
        date: selectedDate,
      );

      // Agregar el ingreso a través del BLoC
      context.read<IncomesBloc>().add(
        AddIncomes(income: income, userId: widget.userId),
      );

      TopSnackBarOverlay.show(
        context: context,
        message: 'Ingreso añadido',
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFF00C896),
      );

      Navigator.pop(context);
    } else {
      String message = 'Por favor completa todos los campos';
      if (selectedCategory == null) {
        message = 'Selecciona una categoría';
      }

      TopSnackBarOverlay.show(
        context: context,
        message: message,
        verticalOffset: 70.0,
        backgroundColor: const Color(0xFFFF6B6B),
      );
    }
  }
}
