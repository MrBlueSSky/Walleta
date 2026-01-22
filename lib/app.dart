import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:walleta/blocs/loan/bloc/loan_bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_bloc.dart';
import 'package:walleta/providers/auth_provider.dart';
import 'package:walleta/providers/theme_provider.dart';
import 'package:walleta/repository/loan/loan_repository.dart';
import 'package:walleta/repository/payment/payment.dart';
import 'package:walleta/repository/repository.dart';
import 'package:walleta/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'blocs/authentication/bloc/authentication_bloc.dart';
import 'blocs/sharedExpense/bloc/shared_expense_bloc.dart';
import 'repository/sharedExpense/shared_expense_repository.dart';

class App extends StatelessWidget {
  final AuthenticationRepository authenticationRepository;
  const App({super.key, required this.authenticationRepository})
    : assert(authenticationRepository != null);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),

          BlocProvider(
            create:
                (_) => AuthenticationBloc(
                  authenticationRepository: authenticationRepository,
                ),
          ),
          BlocProvider(
            create:
                (context) => SharedExpenseBloc(
                  sharedExpenseRepository: SharedExpenseRepository(),
                ),
          ),
          BlocProvider(
            create: (context) => LoanBloc(loanRepository: LoanRepository()),
          ),
          BlocProvider(
            create:
                (context) =>
                    PaymentBloc(paymentRepository: PaymentRepository()),
          ),
          // ChangeNotifierProvider(create: (_) => UserProvider()),
          // BlocProvider(create: (_) => RoleCubit()),
        ],
        child: AppView(),
      ),
    );
  }
}

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: _navigatorKey,
          initialRoute: '/auth',
          routes: routes,
          theme: themeProvider.theme, // Usar el tema del provider
          locale: const Locale('es', 'ES'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
          builder: (context, child) {
            // return BlocBuilder<ConnectivityBloc, ConnectivityState>(
            //   builder: (context, connectivityState) {
            //     if (!connectivityState.isConnected) {
            //       return NoConnection1(connectivityState: connectivityState);
            //     } else {
            return BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                switch (state.status) {
                  case AuthenticationStatus.unauthenticated:
                    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      '/auth',
                      (route) => false,
                    );
                    break;

                  case AuthenticationStatus.authenticated:
                    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                      '/home',
                      (route) => false,
                    );
                    break;
                  // case AuthenticationStatus.unknown:
                  //   _navigatorKey.currentState?.pushNamedAndRemoveUntil(
                  //     '/splash',
                  //     (route) => false,
                  //   );
                  //   break;
                  default:
                    break;
                }
              },
              child: child,
            );
            //     }
            //   },
            // );
          },
        );
      },
    );
  }
}
