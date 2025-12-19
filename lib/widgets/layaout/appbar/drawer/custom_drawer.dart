// import 'package:flutter/material.dart';
// import 'package:un_ride/appColors.dart';

// class CustomDrawer extends StatefulWidget {
//   final VoidCallback onClose;
//   final Function(String) onItemSelected;

//   const CustomDrawer({
//     Key? key,
//     required this.onClose,
//     required this.onItemSelected,
//   }) : super(key: key);

//   @override
//   State<CustomDrawer> createState() => _CustomDrawerState();
// }

// class _CustomDrawerState extends State<CustomDrawer>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 300),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(1.0, 0.0),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.scaffoldBackground,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(5.0),
//               decoration: BoxDecoration(
//                 color: AppColors.secondaryBackground,
//                 border: Border(
//                   bottom: BorderSide(
//                     color: AppColors.cardBackground,
//                     width: 0.5,
//                   ),
//                 ),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Configuración y actividad',
//                     style: TextStyle(
//                       color: AppColors.textPrimary,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Container(
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.close,
//                         color: AppColors.primary,
//                         size: 24,
//                       ),
//                       onPressed: widget.onClose,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Contenido del drawer
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 12),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 8.0,
//                       ),
//                       child: Text(
//                         'Cómo usas la app',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                     // Saved
//                     _buildMenuItem(
//                       icon: Icons.bookmark_border,
//                       title: 'Guardados',
//                       onTap: () => widget.onItemSelected('saved'),
//                     ),

//                     // Archive (marcado como seleccionado)
//                     _buildMenuItem(
//                       icon: Icons.history,
//                       title: 'Archivados',
//                       isSelected: true,
//                       onTap: () => widget.onItemSelected('archive'),
//                     ),

//                     // Your activity
//                     _buildMenuItem(
//                       icon: Icons.show_chart,
//                       title: 'Tu actividad',
//                       onTap: () => widget.onItemSelected('activity'),
//                     ),

//                     // Notifications
//                     _buildMenuItem(
//                       icon: Icons.notifications_none,
//                       title: 'Notificaciones',
//                       onTap: () => widget.onItemSelected('notifications'),
//                     ),

//                     // Time management
//                     _buildMenuItem(
//                       icon: Icons.access_time,
//                       title: 'Gestión del tiempo',
//                       onTap: () => widget.onItemSelected('time'),
//                     ),

//                     Divider(
//                       color: AppColors.cardBackground,
//                       height: 32,
//                       thickness: 0.5,
//                       indent: 16,
//                       endIndent: 16,
//                     ),

//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 12.0,
//                       ),
//                       child: Text(
//                         'Para profesionales',
//                         style: TextStyle(
//                           color: AppColors.primary,
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),

//                     // Insights
//                     _buildMenuItem(
//                       icon: Icons.bar_chart,
//                       title: 'Estadísticas',
//                       onTap: () => widget.onItemSelected('insights'),
//                     ),

//                     // Meta Verified
//                     _buildMenuItem(
//                       icon: Icons.verified,
//                       title: 'Meta Verificado',
//                       trailingText: 'No suscrito',
//                       onTap: () => widget.onItemSelected('verified'),
//                     ),

//                     // Scheduled content
//                     _buildMenuItem(
//                       icon: Icons.schedule,
//                       title: 'Contenido programado',
//                       onTap: () => widget.onItemSelected('scheduled'),
//                     ),

//                     // Creator tools and controls
//                     _buildMenuItem(
//                       icon: Icons.tune,
//                       title: 'Herramientas para creadores',
//                       onTap: () => widget.onItemSelected('creator'),
//                     ),

//                     Divider(
//                       color: AppColors.cardBackground,
//                       height: 32,
//                       thickness: 0.5,
//                       indent: 16,
//                       endIndent: 16,
//                     ),

//                     // Cerrar Sesion
//                     _buildMenuItem(
//                       icon: Icons.logout_rounded,
//                       title: 'Cerrar sesión',
//                       onTap: () => widget.onItemSelected('logout'),
//                     ),

//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMenuItem({
//     required IconData icon,
//     required String title,
//     bool isSelected = false,
//     String? trailingText,
//     required VoidCallback onTap,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//       decoration: BoxDecoration(
//         color:
//             isSelected
//                 ? AppColors.primary.withOpacity(0.1)
//                 : Colors.transparent,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ListTile(
//         onTap: onTap,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//         leading: Icon(
//           icon,
//           color: isSelected ? AppColors.primary : AppColors.textPrimary,
//           size: 24,
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             color: isSelected ? AppColors.primary : AppColors.textPrimary,
//             fontSize: 16,
//             fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//         trailing:
//             trailingText != null
//                 ? Text(
//                   trailingText,
//                   style: TextStyle(
//                     color: AppColors.textSecondary,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w400,
//                   ),
//                 )
//                 : null,
//       ),
//     );
//   }
// }
