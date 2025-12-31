import 'package:flutter/material.dart';

class SavingsAccountScreen extends StatefulWidget {
  const SavingsAccountScreen({super.key});

  @override
  State<SavingsAccountScreen> createState() => _SavingsAccountScreenState();
}

class _SavingsAccountScreenState extends State<SavingsAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Ahorros",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E90FF),
        onPressed: () => _openCreateGoal(context),
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _totalSavings(),
          const SizedBox(height: 24),
          _goalCard(
            context,
            title: "Viaje a la playa",
            saved: 30000,
            goal: 50000,
          ),
          _goalCard(
            context,
            title: "Fondo de emergencia",
            saved: 50000,
            goal: 100000,
          ),
        ],
      ),
    );
  }

  // ===================== TOTAL =====================

  Widget _totalSavings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF162544),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: const [
          Text(
            "Total ahorrado",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 6),
          Text(
            "₡80,000",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  // ===================== METAS =====================

  Widget _goalCard(BuildContext context,
      {required String title,
      required int saved,
      required int goal}) {
    final progress = saved / goal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162544),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("₡$saved / ₡$goal",
              style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white12,
            color: Colors.teal,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openAddMoney(context),
                  child: const Text("Agregar aporte"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===================== MODALES =====================

  void _openCreateGoal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateSavingGoalScreen()),
    );
  }

  void _openAddMoney(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddSavingMoneyScreen()),
    );
  }
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
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Nueva meta de ahorro"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Nombre de la meta", Icons.flag),
            _input("Monto objetivo", Icons.attach_money,
                keyboard: TextInputType.number),
            _datePicker(context),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Guardar meta"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _datePicker(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: "Fecha objetivo",
        prefixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime(2035),
              initialDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => selectedDate = date);
            }
          },
        ),
        hintText:
            selectedDate != null ? selectedDate.toString().split(" ")[0] : "",
      ),
    );
  }
}

// ===================================================
// ================= AGREGAR APORTE ==================
// ===================================================

class AddSavingMoneyScreen extends StatelessWidget {
  const AddSavingMoneyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Agregar aporte"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _input("Monto a agregar", Icons.attach_money),
            _input("Descripción (opcional)", Icons.notes),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Registrar aporte"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}
