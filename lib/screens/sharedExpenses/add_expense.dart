import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/sharedExpense/sharedExpense.dart';
import 'package:walleta/models/shared_expense.dart';
import 'package:walleta/models/appUser.dart';
import 'package:walleta/themes/app_colors.dart';
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

  String? selectedCategory;
  List<Map<String, dynamic>> selectedParticipants = [];

  final List<Map<String, dynamic>> categories = [
    {'name': 'Comida', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Viajes', 'icon': Icons.flight, 'color': Colors.blue},
    {'name': 'Entretenimiento', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'Hogar', 'icon': Icons.home, 'color': Colors.green},
    {'name': 'Transporte', 'icon': Icons.directions_car, 'color': Colors.red},
    {'name': 'Otros', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  void _addParticipant(Map<String, dynamic> user) {
    // Verificar si el usuario ya está agregado
    bool alreadyAdded = selectedParticipants.any(
      (participant) => participant['username'] == user['username'],
    );

    if (!alreadyAdded) {
      setState(() {
        selectedParticipants.add(user);
      });
    }
  }

  void _removeParticipant(int index) {
    setState(() {
      selectedParticipants.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    Color inputColor = Theme.of(context).textTheme.labelSmall!.color!;
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nuevo Gasto Compartido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Form content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del gasto
                    _buildSectionLabel(context, 'Título del gasto'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Cena en restaurante',
                        filled: true,
                        fillColor: inputColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
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

                    const SizedBox(height: 24),

                    // Montos (Total y Pagado)
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(context, 'Total'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _totalController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0',
                                  prefixText: '₡ ',
                                  prefixStyle: const TextStyle(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  filled: true,
                                  fillColor: inputColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requerido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel(context, 'Pagado'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _paidController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: '0',
                                  prefixText: '₡ ',
                                  prefixStyle: const TextStyle(
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  filled: true,
                                  fillColor: inputColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requerido';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Categoría
                    _buildSectionLabel(context, 'Categoría'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          categories.map((cat) {
                            final isSelected = selectedCategory == cat['name'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategory = cat['name'];
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? (cat['color'] as Color).withOpacity(
                                            0.1,
                                          )
                                          : inputColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? cat['color'] as Color
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      cat['icon'] as IconData,
                                      color: cat['color'] as Color,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat['name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? cat['color'] as Color
                                                : Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Participantes
                    _buildSectionLabel(context, 'Participantes'),
                    const SizedBox(height: 12),

                    // Botón de búsqueda
                    SearchButton(
                      onUserSelected: (user) {
                        _addParticipant(user);
                      },
                      iconColor: Theme.of(context).iconTheme.color,
                      size: 26,
                    ),

                    const SizedBox(height: 16),

                    // Lista de participantes seleccionados
                    Wrap(
                      spacing: 8, // espacio horizontal entre chips
                      runSpacing: 8, // espacio vertical entre filas
                      children: [
                        if (selectedParticipants.isNotEmpty)
                          ...selectedParticipants.asMap().entries.map((entry) {
                            final index = entry.key;
                            final participant = entry.value;

                            return _buildParticipantChip(
                              participant['username'] ?? 'Usuario',
                              index,
                            );
                          }),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),

          // Bottom button
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildParticipantChip(String username, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar inicial
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                username[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Nombre de usuario
          Text(
            username,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          // Botón para eliminar
          GestureDetector(
            onTap: () => _removeParticipant(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _saveExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Crear Gasto',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
      final category = categories.firstWhere(
        (cat) => cat['name'] == selectedCategory,
      );

      final expense = SharedExpense(
        title: _titleController.text,
        total: double.parse(_totalController.text),
        paid: double.parse(_paidController.text),
        participants:
            selectedParticipants.map((p) => p['username'] as String).toList(),
        category: selectedCategory!,
        categoryIcon: category['icon'],
        categoryColor: category['color'],
      );

      final AppUser user = context.read<AuthenticationBloc>().state.user;
      print("📍📍📍📍User ID: ${user.uid} aaaaa ${expense}");
      context.read<SharedExpenseBloc>().add(
        AddSharedExpense(userId: user.uid, expense: expense),
      );

      // widget.onSave(expense);
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
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _totalController.dispose();
    _paidController.dispose();
    super.dispose();
  }
}
