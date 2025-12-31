import 'package:flutter/material.dart';

class Loans extends StatelessWidget {
  const Loans({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Deudas y Préstamos",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E90FF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => const AddLoanScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCards(),
            const SizedBox(height: 24),
            _sectionTitle("Personas a las que debes"),
            _loanCard(
              context,
              "Carlos",
              "Casa",
              "20 Oct 2025",
              "Atrasado",
              Colors.red,
              0.4,
              "₡15,000",
            ),
            _loanCard(
              context,
              "Ana",
              "Viaje",
              "25 Oct 2025",
              "Por vencer",
              Colors.orange,
              0.7,
              "₡5,000",
            ),
            const SizedBox(height: 24),
            _sectionTitle("Personas que te deben"),
            _loanCard(
              context,
              "Pedro",
              "Supermercado",
              "30 Oct 2025",
              "Al día",
              Colors.green,
              0.2,
              "₡23,000",
              showPayButton: false,
            ),
          ],
        ),
      ),
    );
  }

  // ===================== UI =====================

  Widget _summaryCards() {
    return Row(
      children: [
        _summaryItem("Debes", "₡20,000", Colors.red),
        const SizedBox(width: 12),
        _summaryItem("Te deben", "₡35,000", Colors.green),
        const SizedBox(width: 12),
        _summaryItem("Balance", "₡15,000", Colors.blue),
      ],
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF162544),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _loanCard(
    BuildContext context,
    String name,
    String origin,
    String dueDate,
    String status,
    Color statusColor,
    double progress,
    String pending, {
    bool showPayButton = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162544),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Text(status,
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          Text("Origen: $origin",
              style: const TextStyle(color: Colors.white70)),
          Text("Vence: $dueDate",
              style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white12,
            color: Colors.green,
            minHeight: 6,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pendiente: $pending",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold)),
              if (showPayButton)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        fullscreenDialog: true,
                        builder: (_) =>
                            RegisterPaymentScreen(person: name),
                      ),
                    );
                  },
                  child: const Text("Registrar pago"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// PANTALLA COMPLETA – REGISTRAR PAGO
////////////////////////////////////////////////////////////////

class RegisterPaymentScreen extends StatelessWidget {
  final String person;

  const RegisterPaymentScreen({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Registrar pago"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Persona: $person",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto pagado",
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Confirmar pago"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////
/// PANTALLA COMPLETA – AGREGAR DEUDA
////////////////////////////////////////////////////////////////

class AddLoanScreen extends StatefulWidget {
  const AddLoanScreen({super.key});

  @override
  State<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends State<AddLoanScreen> {
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        title: const Text("Agregar deuda / préstamo"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Nombre de la persona",
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Monto",
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "debo", child: Text("Yo debo")),
                DropdownMenuItem(
                    value: "me_deben", child: Text("Me deben")),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: "Tipo"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField(
              items: const [
                DropdownMenuItem(value: "Casa", child: Text("Casa")),
                DropdownMenuItem(value: "Viaje", child: Text("Viaje")),
                DropdownMenuItem(value: "Otro", child: Text("Otro")),
              ],
              onChanged: (_) {},
              decoration: const InputDecoration(labelText: "Origen"),
            ),
            const SizedBox(height: 12),
            TextField(
              readOnly: true,
              onTap: _pickDate,
              decoration: InputDecoration(
                labelText: selectedDate == null
                    ? "Fecha límite"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                prefixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickDate,
                ),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
