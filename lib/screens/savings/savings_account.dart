import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class SavingsAccountScreen extends StatefulWidget {
  const SavingsAccountScreen({super.key});

  @override
  State<SavingsAccountScreen> createState() => _SavingsAccountScreenState();
}

class _SavingsAccountScreenState extends State<SavingsAccountScreen> {
  double totalSaved = 80000;
  final List<SavingGoal> goals = [
    SavingGoal(
      title: "Viaje a la playa",
      saved: 30000,
      goal: 50000,
      icon: Icons.beach_access,
      color: const Color(0xFF00C896),
      targetDate: DateTime.now().add(const Duration(days: 90)), // 3 meses
    ),
    SavingGoal(
      title: "Fondo de emergencia",
      saved: 50000,
      goal: 100000,
      icon: Iconsax.shield_tick,
      color: const Color(0xFF2D5BFF),
      targetDate: DateTime.now().add(const Duration(days: 180)), // 6 meses
    ),
    SavingGoal(
      title: "Nueva computadora",
      saved: 15000,
      goal: 80000,
      icon: Iconsax.monitor,
      color: const Color(0xFFFFA726),
      targetDate: DateTime.now().add(const Duration(days: 120)), // 4 meses
    ),
    SavingGoal(
      title: "Curso de inglés",
      saved: 0,
      goal: 120000,
      icon: Iconsax.book,
      color: const Color(0xFF9C27B0),
      targetDate: DateTime.now().add(const Duration(days: 365)), // 1 año
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Color iconsColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // AppBar personalizado
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: backgroundColor,
              elevation: 0,
              title: Text(
                "Mis Ahorros",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add, color: iconsColor),
                  onPressed: () => _openCreateGoal(context),
                ),
              ],
            ),

            // Sección de total ahorrado
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 16,
            //       vertical: 8,
            //     ),
            //     child: _buildTotalSavings(isDark),
            //   ),
            // ),

            // Título de metas
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Tus metas de ahorro",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      "${goals.length} metas",
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            isDark ? Colors.white70 : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Grid de metas
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _buildGoalCard(context, goals[index], isDark);
                }, childCount: goals.length),
              ),
            ),

            // Espacio final
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSavings(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: screenWidth - 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5BFF), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D5BFF).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(10),
                child: const Icon(
                  Iconsax.wallet_money,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: const Text(
                  '+12.5%',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Total Ahorrado',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatCurrency(totalSaved),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, SavingGoal goal, bool isDark) {
    final progress = goal.saved / goal.goal;
    final percentage = (progress * 100).toInt();
    final cardWidth = (MediaQuery.of(context).size.width - 44) / 2;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Encabezado con ícono y fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(goal.icon, color: goal.color, size: 18),
                ),
                // _buildDateIndicator(daysLeft, goal.color),

                // Fecha objetivo
                Row(
                  children: [
                    Icon(Iconsax.calendar_1, size: 10, color: goal.color),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(goal.targetDate),
                      style: TextStyle(
                        fontSize: 10,
                        color: goal.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Título y progreso
            Text(
              goal.title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Montos
            Text(
              '${_formatCurrency(goal.saved)} / ${_formatCurrency(goal.goal)}',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white70 : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),

            // Fecha objetivo
            // Row(
            //   children: [
            //     Icon(Iconsax.calendar_1, size: 10, color: goal.color),
            //     const SizedBox(width: 4),
            //     Text(
            //       _formatDate(goal.targetDate),
            //       style: TextStyle(
            //         fontSize: 10,
            //         color: goal.color,
            //         fontWeight: FontWeight.w500,
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(height: 8),

            // Barra de progreso
            SizedBox(
              width: cardWidth - 24,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 5,
                        decoration: BoxDecoration(
                          color:
                              isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      Container(
                        height: 5,
                        width: (cardWidth - 24) * progress.clamp(0.0, 1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [goal.color, goal.color.withOpacity(0.8)],
                          ),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Porcentaje y botón
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: goal.color,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openAddMoney(context, goal),
                        child: Container(
                          decoration: BoxDecoration(
                            color: goal.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(4),
                          child: Icon(Iconsax.add, size: 12, color: goal.color),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildDateIndicator(int daysLeft, Color color) {
  //   if (daysLeft <= 0) {
  //     return Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //       decoration: BoxDecoration(
  //         color: const Color(0xFF00C896).withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(10),
  //       ),
  //       child: Row(
  //         children: [
  //           Icon(Iconsax.tick_circle, size: 10, color: const Color(0xFF00C896)),
  //           const SizedBox(width: 4),
  //           Text(
  //             'Completada',
  //             style: TextStyle(
  //               fontSize: 9,
  //               color: const Color(0xFF00C896),
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   String text;
  //   Color bgColor;

  //   if (daysLeft <= 7) {
  //     text = '$daysLeft días';
  //     bgColor = const Color(0xFFFF6B6B);
  //   } else if (daysLeft <= 30) {
  //     text = '${daysLeft ~/ 7} sem';
  //     bgColor = const Color(0xFFFFA726);
  //   } else {
  //     text = '${daysLeft ~/ 30} mes';
  //     if (daysLeft > 60) {
  //       text += 'es';
  //     }
  //     bgColor = color;
  //   }

  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: bgColor.withOpacity(0.1),
  //       borderRadius: BorderRadius.circular(10),
  //     ),
  //     child: Row(
  //       children: [
  //         Icon(Iconsax.calendar_1, size: 10, color: bgColor),
  //         const SizedBox(width: 4),
  //         Text(
  //           text,
  //           style: TextStyle(
  //             fontSize: 9,
  //             color: bgColor,
  //             fontWeight: FontWeight.w600,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '₡${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '₡${(amount / 1000).toStringAsFixed(1)}K';
    }

    return '₡${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _openCreateGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (context) => const CreateSavingGoalScreen(),
    );
  }

  void _openAddMoney(BuildContext context, SavingGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      builder: (context) => AddSavingMoneyScreen(goal: goal),
    );
  }
}

class SavingGoal {
  final String title;
  final double saved;
  final double goal;
  final IconData icon;
  final Color color;
  final DateTime targetDate;

  SavingGoal({
    required this.title,
    required this.saved,
    required this.goal,
    required this.icon,
    required this.color,
    required this.targetDate,
  });
}

// ===================================================
// ================= CREAR META ======================
// ===================================================

class CreateSavingGoalScreen extends StatefulWidget {
  const CreateSavingGoalScreen({super.key});

  @override
  State<CreateSavingGoalScreen> createState() => _CreateSavingGoalScreenState();
}

class _CreateSavingGoalScreenState extends State<CreateSavingGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  DateTime? _selectedDate;
  String _selectedIcon = 'beach_access';

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final secondaryTextColor =
        isDark ? Colors.white70 : const Color(0xFF6B7280);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: mediaQuery.viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nueva meta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
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
            const SizedBox(height: 20),

            // Formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(
                    label: 'Nombre de la meta',
                    icon: Iconsax.flag,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildInputField(
                    label: 'Monto objetivo (₡)',
                    icon: Iconsax.money,
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Selector de fecha
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dateController,
                        decoration: InputDecoration(
                          labelText: 'Fecha objetivo (opcional)',
                          labelStyle: const TextStyle(color: Color(0xFF6B7280)),
                          prefixIcon: const Icon(
                            Iconsax.calendar,
                            color: Color(0xFF9CA3AF),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE5E7EB),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5BFF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Crear meta',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2D5BFF), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _dateController.text = '${date.day}/${date.month}/${date.year}';
      });
    }
  }

  void _saveGoal() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}

// ===================================================
// ================= AGREGAR APORTE ==================
// ===================================================

class AddSavingMoneyScreen extends StatefulWidget {
  final SavingGoal goal;

  const AddSavingMoneyScreen({super.key, required this.goal});

  @override
  State<AddSavingMoneyScreen> createState() => _AddSavingMoneyScreenState();
}

class _AddSavingMoneyScreenState extends State<AddSavingMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: mediaQuery.viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agregar aporte',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.goal.title,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Iconsax.close_circle, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Información de la fecha objetivo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.goal.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.calendar_1, size: 16, color: widget.goal.color),
                  const SizedBox(width: 8),
                  Text(
                    'Fecha objetivo: ${_formatDate(widget.goal.targetDate)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.goal.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Campos del formulario
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(
                    label: 'Monto a agregar (₡)',
                    icon: Iconsax.money_add,
                    controller: _amountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Número inválido';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Debe ser mayor a 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildInputField(
                    label: 'Descripción (opcional)',
                    icon: Iconsax.note,
                    controller: _descriptionController,
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveContribution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.goal.color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Registrar aporte',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${monthNames[date.month - 1]} ${date.year}';
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: maxLines > 1 ? null : TextInputType.number,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF6B7280)),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.goal.color, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 12 : 14,
        ),
      ),
    );
  }

  void _saveContribution() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
