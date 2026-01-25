import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:walleta/models/appUser.dart';

class ProfileFloatingWidget extends StatefulWidget {
  final AppUser user;

  const ProfileFloatingWidget({Key? key, required this.user}) : super(key: key);

  @override
  _ProfileFloatingWidgetState createState() => _ProfileFloatingWidgetState();
}

class _ProfileFloatingWidgetState extends State<ProfileFloatingWidget> {
  late AppUser _editableUser;
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _editableUser = widget.user;

    // Inicializar controladores y focus nodes
    final fields = ['username', 'name', 'surname', 'phoneNumber'];
    for (var field in fields) {
      _controllers[field] = TextEditingController();
      _focusNodes[field] = FocusNode();
    }

    // Asignar valores
    _controllers['username']!.text = _editableUser.username;
    _controllers['name']!.text = _editableUser.name;
    _controllers['surname']!.text = _editableUser.surname;
    _controllers['phoneNumber']!.text = _editableUser.phoneNumber;
  }

  void _saveChanges() {
    setState(() {
      _editableUser = AppUser(
        uid: _editableUser.uid,
        username: _controllers['username']!.text,
        name: _controllers['name']!.text,
        surname: _controllers['surname']!.text,
        email: _editableUser.email,
        phoneNumber: _controllers['phoneNumber']!.text,
        profilePictureUrl: _editableUser.profilePictureUrl,
        isPremium: _editableUser.isPremium,
        premiumUntil: _editableUser.premiumUntil,
      );
    });
    Navigator.of(context).pop(_editableUser);
  }

  String _formatMemberSince() {
    return 'Enero 2024';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header fijo
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.profile_circle,
                            size: isSmallScreen ? 18 : 20,
                            color:
                                isDark ? Colors.white : const Color(0xFF2D5BFF),
                          ),
                          SizedBox(width: isSmallScreen ? 6 : 8),
                          Expanded(
                            child: Text(
                              'Información Personal',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    isDark
                                        ? Colors.white
                                        : const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              size: isSmallScreen ? 16 : 18,
                              color:
                                  isDark
                                      ? Colors.white70
                                      : const Color(0xFF6B7280),
                            ),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contenido desplazable
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 14 : 16,
                          vertical: 8,
                        ),
                        child: Column(
                          children: [
                            _buildEditableRow(
                              icon: Iconsax.user,
                              label: 'Username',
                              controller: _controllers['username']!,
                              focusNode: _focusNodes['username']!,
                              color: const Color(0xFF2D5BFF),
                              isDark: isDark,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 12),
                            _buildEditableRow(
                              icon: Iconsax.user,
                              label: 'Nombre',
                              controller: _controllers['name']!,
                              focusNode: _focusNodes['name']!,
                              color: const Color(0xFF2D5BFF),
                              isDark: isDark,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 12),
                            _buildEditableRow(
                              icon: Iconsax.user,
                              label: 'Apellido',
                              controller: _controllers['surname']!,
                              focusNode: _focusNodes['surname']!,
                              color: const Color(0xFF2D5BFF),
                              isDark: isDark,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 12),
                            _buildEditableRow(
                              icon: Iconsax.call,
                              label: 'Teléfono',
                              controller: _controllers['phoneNumber']!,
                              focusNode: _focusNodes['phoneNumber']!,
                              color: const Color(0xFF00C896),
                              isDark: isDark,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 10 : 12),
                            _buildInfoRow(
                              icon: Iconsax.calendar,
                              label: 'Miembro desde',
                              value: _formatMemberSince(),
                              color: const Color(0xFFFFA726),
                              isDark: isDark,
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),

                            // Botón de verificación
                            InkWell(
                              onTap:
                                  () => _showPlaceholderDialog('Verificación'),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(0.3),
                                    width: 0.5,
                                  ),
                                ),
                                padding: EdgeInsets.all(
                                  isSmallScreen ? 12 : 16,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Iconsax.verify,
                                      size: 18,
                                      color: Color(0xFF10B981),
                                    ),
                                    SizedBox(width: isSmallScreen ? 10 : 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Verificación de identidad',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 13 : 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  isDark
                                                      ? Colors.white
                                                      : const Color(0xFF1F2937),
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Tu cuenta está verificada',
                                            style: TextStyle(
                                              fontSize: isSmallScreen ? 11 : 12,
                                              color:
                                                  isDark
                                                      ? Colors.white70
                                                      : const Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Iconsax.arrow_right_3,
                                      size: 16,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botones de acción fijos en la parte inferior
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 10 : 12,
                                ),
                                side: BorderSide(
                                  color:
                                      isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color:
                                      isDark
                                          ? Colors.white70
                                          : const Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: isSmallScreen ? 10 : 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2D5BFF),
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmallScreen ? 10 : 12,
                                ),
                              ),
                              child: Text(
                                'Guardar',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 13 : 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditableRow({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Color color,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(focusNode);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark ? Color(0xFF0F172A).withOpacity(0.5) : Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color:
                focusNode.hasFocus
                    ? color.withOpacity(0.3)
                    : Colors.transparent,
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
              child: Icon(icon, size: isSmallScreen ? 16 : 18, color: color),
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Iconsax.edit_2,
                        size: isSmallScreen ? 12 : 14,
                        color: color.withOpacity(0.8),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 13 : 14,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Ingresa tu $label',
                      hintStyle: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color:
                            isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
    required bool isSmallScreen,
  }) {
    final displayValue = value.isEmpty ? 'No especificado' : value;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF0F172A).withOpacity(0.5) : Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
            child: Icon(icon, size: isSmallScreen ? 16 : 18, color: color),
          ),
          SizedBox(width: isSmallScreen ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  displayValue,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 13 : 14,
                    color: isDark ? Colors.white : const Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaceholderDialog(String title) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text('Funcionalidad de $title'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  @override
  void dispose() {
    // Dispose de todos los controladores
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }
}

// Función para mostrar el widget
void showProfileFloatingWidget(BuildContext context, AppUser user) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) => ProfileFloatingWidget(user: user),
  );
}
