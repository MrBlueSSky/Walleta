import 'package:flutter/material.dart';

class profileTest extends StatelessWidget {
  const profileTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _profileHeader(),
            const SizedBox(height: 24),
            _summaryCards(),
            const SizedBox(height: 28),
            _chartsSection(),
            const SizedBox(height: 28),
            _actionsSection(context),
          ],
        ),
      ),
    );
  }

  // ===================== PERFIL =====================

  Widget _profileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: const Color(0xFF1E90FF),
          child: const Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text(
          "Fabricio Usuario",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          "fabricio@email.com",
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  // ===================== RESUMEN =====================

  Widget _summaryCards() {
    return Column(
      children: [
        Row(
          children: [
            _summaryItem("Debes", "₡20,000", Colors.red),
            const SizedBox(width: 12),
            _summaryItem("Te deben", "₡35,000", Colors.green),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _summaryItem("Balance", "₡15,000", Colors.blue),
            const SizedBox(width: 12),
            _summaryItem("Ahorros", "₡50,000", Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF162544),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===================== GRÁFICAS =====================

  Widget _chartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Resumen financiero",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),

        // Distribución general
        _chartCard(
          "Distribución general",
          [
            _chartBar("Debes", 0.4, Colors.red),
            _chartBar("Te deben", 0.7, Colors.green),
            _chartBar("Ahorros", 0.9, Colors.teal),
          ],
        ),

        const SizedBox(height: 16),

        // Progreso financiero + ahorros
        _chartCard(
          "Progreso financiero y ahorro",
          [
            _chartBar("Pagos realizados", 0.75, Colors.green),
            _chartBar("Pagos pendientes", 0.25, Colors.orange),
            _chartBar("Meta de ahorro", 0.6, Colors.teal),
          ],
        ),
      ],
    );
  }

  Widget _chartCard(String title, List<Widget> bars) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162544),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          ...bars,
        ],
      ),
    );
  }

  Widget _chartBar(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: value,
            color: color,
            backgroundColor: Colors.white12,
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  // ===================== ACCIONES =====================

  Widget _actionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Cuenta",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        _actionTile(Icons.edit, "Editar perfil"),
        _actionTile(Icons.settings, "Configuración"),
        _actionTile(Icons.security, "Seguridad"),
        _actionTile(Icons.logout, "Cerrar sesión", isDanger: true),
      ],
    );
  }

  Widget _actionTile(
    IconData icon,
    String title, {
    bool isDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF162544),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDanger ? Colors.redAccent : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDanger ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
