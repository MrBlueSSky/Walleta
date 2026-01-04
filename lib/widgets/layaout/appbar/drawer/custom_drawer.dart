import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback onClose;
  final Function(String) onItemSelected;

  const CustomDrawer({
    Key? key,
    required this.onClose,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1D1F);
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFD);
    final surfaceColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final premiumColor =
        isDark ? const Color(0xFFFFD700) : const Color(0xFFFFB800);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header minimalista
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Configuración',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Iconsax.close_circle,
                      color: textColor.withOpacity(0.7),
                      size: 24,
                    ),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),

            // Contenido del drawer
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Opción Premium - Simple pero llamativa
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onItemSelected('premium'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: premiumColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: premiumColor.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Iconsax.star,
                                    color: premiumColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Mejorar a Premium',
                                          style: TextStyle(
                                            color: premiumColor,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Funciones exclusivas y sin límites',
                                          style: TextStyle(
                                            color: premiumColor.withOpacity(
                                              0.8,
                                            ),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: premiumColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'PRO',
                                      style: TextStyle(
                                        color: premiumColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Opciones regulares
                      _buildMenuItem(
                        icon: Iconsax.notification,
                        title: 'Notificaciones',
                        subtitle: 'Configurar alertas',
                        onTap: () => widget.onItemSelected('notifications'),
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                      ),

                      _buildMenuItem(
                        icon: Iconsax.document_text,
                        title: 'Verificar identidad',
                        subtitle: 'Verifica tu cuenta',
                        onTap: () => widget.onItemSelected('verify'),
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                      ),

                      _buildMenuItem(
                        icon: Iconsax.document_text,
                        title: 'Reportes',
                        subtitle: 'Generar y exportar',
                        onTap: () => widget.onItemSelected('reports'),
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                      ),

                      _buildMenuItem(
                        icon: Iconsax.message_question,
                        title: 'Ayuda y Soporte',
                        subtitle: 'Centro de ayuda',
                        onTap: () => widget.onItemSelected('help'),
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                      ),

                      _buildMenuItem(
                        icon: Iconsax.gift,
                        title: 'Invitar Amigos',
                        subtitle: 'Comparte y gana',
                        onTap: () => widget.onItemSelected('invite'),
                        surfaceColor: surfaceColor,
                        textColor: textColor,
                      ),

                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Divider(
                          color: Colors.grey.withOpacity(0.1),
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cerrar Sesión
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFF6B6B).withOpacity(0.08),
                            border: Border.all(
                              color: const Color(0xFFFF6B6B).withOpacity(0.15),
                              width: 1.0,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => widget.onItemSelected('logout'),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFFF6B6B,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(
                                        Iconsax.logout,
                                        color: const Color(0xFFFF6B6B),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Cerrar Sesión',
                                            style: TextStyle(
                                              color: const Color(0xFFFF6B6B),
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Salir de tu cuenta',
                                            style: TextStyle(
                                              color: const Color(
                                                0xFFFF6B6B,
                                              ).withOpacity(0.7),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Iconsax.arrow_right_3,
                                      color: const Color(
                                        0xFFFF6B6B,
                                      ).withOpacity(0.5),
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Footer minimalista - CENTRADO
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Walleta v1.0.0',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.4),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '© 2026 Todos los derechos reservados',
                                style: TextStyle(
                                  color: textColor.withOpacity(0.3),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required Color surfaceColor,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.05),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5BFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, color: const Color(0xFF2D5BFF), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Iconsax.arrow_right_3,
                  color: textColor.withOpacity(0.4),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
