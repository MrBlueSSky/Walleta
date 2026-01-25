import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/saving/bloc/saving_bloc.dart';
import 'package:walleta/blocs/saving/bloc/saving_event.dart';
import 'package:walleta/blocs/saving/bloc/saving_state.dart';
import 'package:walleta/models/savings.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:walleta/screens/savings/savings_account.dart';

import 'savings_account.dart';

class SavingsAccountScreen extends StatefulWidget {
  final String userId;

  const SavingsAccountScreen({super.key, required this.userId});

  @override
  State<SavingsAccountScreen> createState() => _SavingsAccountScreenState();
}

class _SavingsAccountScreenState extends State<SavingsAccountScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SavingBloc>().add(LoadSavingGoals(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: BlocBuilder<SavingBloc, SavingState>(
          builder: (context, state) {
            if (state.status == SavingStateStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == SavingStateStatus.error) {
              return const Center(child: Text('❌ Error al cargar metas'));
            }

            final goals = state.goals;

            if (goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.wallet, size: 100, color: Colors.grey[300]),
                    const SizedBox(height: 20),
                    Text(
                      'No hay ahorros registrados',
                      style: TextStyle(fontSize: 18, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  backgroundColor: backgroundColor,
                  elevation: 0,
                  title: const Text(
                    "Mis Ahorros",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _openCreateGoal(context),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tus metas de ahorro",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "${goals.length} metas",
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isDark
                                    ? Colors.white70
                                    : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildGoalCard(context, goals[index]);
                    }, childCount: goals.length),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingGoal goal) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (goal.saved / goal.goal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return GestureDetector(
      onTap: () => _showPaymentHistory(context, goal),
      onLongPress: () => _showGoalOptions(context, goal),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                isDark
                    ? const Color(0xFF334155).withOpacity(0.3)
                    : const Color(0xFFE5E7EB).withOpacity(0.8),
            width: 0.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Icon(goal.icon, color: goal.color),
                ),
                Text(
                  '${_formatCurrency(goal.saved)} / ${_formatCurrency(goal.goal)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: goal.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor:
                    isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
                valueColor: AlwaysStoppedAnimation(goal.color),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: goal.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fecha límite: ${_formatDate(goal.targetDate)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage% completado',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: goal.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalOptions(BuildContext context, SavingGoal goal) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Editar'),
              onTap: () {
                Navigator.pop(context);
                _openCreateGoal(context, goal: goal);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Borrar'),
              onTap: () {
                context.read<SavingBloc>().add(DeleteSavingGoal(goal.id));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Abonar'),
              onTap: () {
                Navigator.pop(context);
                _openAddMoney(context, goal);
              },
            ),
          ],
        );
      },
    );
  }

  void _showPaymentHistory(BuildContext context, SavingGoal goal) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Historial de abonos - ${goal.title}'),
          content: SizedBox(
            width: double.maxFinite,
            child:
                goal.payments.isEmpty
                    ? const Text('No hay abonos realizados')
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: goal.payments.length,
                      itemBuilder: (context, index) {
                        final payment = goal.payments[index];
                        final date = payment.date;
                        final amount = payment.amount;
                        return ListTile(
                          leading: const Icon(Iconsax.money),
                          title: Text('${_formatCurrency(amount)}'),
                          subtitle: Text(_formatDate(date)),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  void _openCreateGoal(BuildContext context, {SavingGoal? goal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateGoalBottomSheet(userId: widget.userId, goal: goal),
    );
  }

  void _openAddMoney(BuildContext context, SavingGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMoneyBottomSheet(goal: goal, userId: widget.userId),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) return '₡${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '₡${(amount / 1000).toStringAsFixed(1)}K';
    return '₡${amount.toStringAsFixed(0)}';
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}

/// ===========================
/// BOTTOM SHEET CREAR META
/// ===========================
class _CreateGoalBottomSheet extends StatefulWidget {
  final String userId;
  final SavingGoal? goal;
  const _CreateGoalBottomSheet({required this.userId, this.goal});

  @override
  State<_CreateGoalBottomSheet> createState() => _CreateGoalBottomSheetState();
}

class _CreateGoalBottomSheetState extends State<_CreateGoalBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  DateTime? _selectedDate;
  Color _selectedColor = Colors.blue;
  IconData _selectedIcon = Icons.savings;

  final List<IconData> _icons = [
    Icons.savings,
    Icons.shopping_cart,
    Icons.car_rental,
    Icons.home,
    Icons.flight,
    Icons.sports_soccer,
    Icons.school,
    Icons.phone_iphone,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.goal != null) {
      _titleController.text = widget.goal!.title;
      _goalController.text = widget.goal!.goal.toString();
      _selectedDate = widget.goal!.targetDate;
      _selectedColor = widget.goal!.color;
      _selectedIcon = widget.goal!.icon;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.goal == null ? 'Crear nueva meta' : 'Editar meta',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator:
                        (value) => value!.isEmpty ? 'Ingrese un título' : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _goalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto objetivo',
                    ),
                    validator:
                        (value) => value!.isEmpty ? 'Ingrese un monto' : null,
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha límite',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!)
                            : 'Selecciona una fecha',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Color de la card: '),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _pickColor,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black26),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _icons.length,
                      itemBuilder: (context, index) {
                        final icon = _icons[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedIcon = icon;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color:
                                  _selectedIcon == icon
                                      ? _selectedColor.withOpacity(0.2)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: _selectedColor),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGoal,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.goal == null ? 'Guardar meta' : 'Actualizar meta',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (_) {
        Color tempColor = _selectedColor;
        return AlertDialog(
          title: const Text('Selecciona un color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (color) => tempColor = color,
              enableAlpha: false,
              showLabel: false,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() => _selectedColor = tempColor);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final goal = SavingGoal(
        id: widget.goal?.id ?? '',
        title: _titleController.text,
        saved: widget.goal?.saved ?? 0,
        goal: double.parse(_goalController.text),
        icon: _selectedIcon,
        color: _selectedColor,
        targetDate: _selectedDate!,
      );

      if (widget.goal == null) {
        context.read<SavingBloc>().add(
          AddSavingGoal(goal: goal, userId: widget.userId),
        );
      } else {
        context.read<SavingBloc>().add(
          UpdateSavingGoal(goalId: goal.id, goal: goal),
        );
      }

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${monthNames[date.month - 1]} ${date.year}';
  }
}

/// ===========================
/// BOTTOM SHEET ABONAR DINERO
/// ===========================
class _AddMoneyBottomSheet extends StatefulWidget {
  final SavingGoal goal;
  final String userId;
  const _AddMoneyBottomSheet({required this.goal, required this.userId});

  @override
  State<_AddMoneyBottomSheet> createState() => _AddMoneyBottomSheetState();
}

class _AddMoneyBottomSheetState extends State<_AddMoneyBottomSheet> {
  final _controller = TextEditingController();
  String? _errorMessage; // <-- Guardará el mensaje de error

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Abonar a ${widget.goal.title}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto a abonar'),
              onChanged: (_) {
                if (_errorMessage != null) {
                  setState(() {
                    _errorMessage = null; // Limpiar el error al escribir
                  });
                }
              },
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addMoney,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Abonar'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMoney() {
    final amount = double.tryParse(_controller.text);

    // Validación: monto válido
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Ingrese un monto válido';
      });
      return;
    }

    // Validación: que no se pase del objetivo
    final remaining = widget.goal.goal - widget.goal.saved;
    if (amount > remaining) {
      setState(() {
        _errorMessage =
            'No puede abonar más de ₡${remaining.toStringAsFixed(0)}';
      });
      return;
    }

    // Si todo está bien, agregar abono al Bloc
    context.read<SavingBloc>().add(
      AddMoneyToSavingGoal(goalId: widget.goal.id, amount: amount),
    );

    // Cerrar el bottom sheet
    Navigator.pop(context);
  }
}
