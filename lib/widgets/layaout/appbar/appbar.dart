// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:un_ride/appColors.dart';
// import 'package:un_ride/blocs/authentication/bloc/authentication_bloc.dart';
// import 'package:un_ride/cubits/role_cubit/user_role.dart';
// import 'package:un_ride/screens/Widgets/buttons/role_button.dart';
// import 'package:un_ride/screens/Widgets/loaders/car_loader.dart';

// class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final bool canSwitch;
//   final bool isDriverMode;
//   // final ValueChanged<bool> onRoleChange;

//   const MainAppBar({
//     super.key,
//     required this.canSwitch,
//     required this.isDriverMode,
//     // required this.onRoleChange,
//   });

//   @override
//   State<MainAppBar> createState() => _MainAppBarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// class _MainAppBarState extends State<MainAppBar> {
//   late bool _isDriverMode;

//   @override
//   void initState() {
//     super.initState();
//     _isDriverMode = widget.isDriverMode;
//   }

//   Future<void> toggleRole(bool isDriver) async {
//     setState(() {
//       _isDriverMode = isDriver;
//     });

//     await showLoader();

//     changeView(isDriver);
//   }

//   void changeView(bool isDriver) {
//     if (isDriver) {
//       context.read<RoleCubit>().setDriver();
//       Navigator.of(
//         context,
//       ).pushNamedAndRemoveUntil('/drivers', (route) => false);
//     } else {
//       context.read<RoleCubit>().setClient();
//       Navigator.of(
//         context,
//       ).pushNamedAndRemoveUntil('/clients', (route) => false);
//     }
//   }

//   Future<void> showLoader() async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => CarLoader(),
//     );

//     await Future.delayed(const Duration(milliseconds: 3000));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: const Text(
//         "Un Ride",
//         style: TextStyle(color: AppColors.textPrimary),
//       ),
//       backgroundColor: AppColors.scaffoldBackground,
//       elevation: 0,
//       actions: [
//         BlocBuilder<AuthenticationBloc, AuthenticationState>(
//           builder: (context, state) {
//             if (state.status == AuthenticationStatus.authenticatedWithVehicle) {
//               return Padding(
//                 padding: const EdgeInsets.only(right: 16.0),
//                 child: RoleSwitchButton(
//                   isDriverMode: _isDriverMode,
//                   onChanged: toggleRole,
//                   canSwitch: widget.canSwitch,
//                 ),
//               );
//             } else {
//               return const SizedBox.shrink();
//             }
//           },
//         ),
//       ],
//     );
//   }
// }
