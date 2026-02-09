// En tu App class - ARCHIVO COMPLETO CORREGIDO
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:walleta/blocs/financialSummary/bloc/financial_summary_bloc.dart';
import 'package:walleta/blocs/income/bloc/incomes_bloc.dart';
import 'package:walleta/blocs/income_payment/bloc/income_payment_bloc.dart';
import 'package:walleta/blocs/loan/bloc/loan_bloc.dart';
import 'package:walleta/blocs/payment/bloc/payment_bloc.dart';
import 'package:walleta/blocs/personalExpense/bloc/personal_expense_bloc.dart';
import 'package:walleta/blocs/personalExpensePayment/bloc/personal_expense_payment_bloc.dart';
import 'package:walleta/blocs/sharedExpensePayment/bloc/shared_expense_payment_bloc.dart';
import 'package:walleta/blocs/saving/bloc/saving_bloc.dart';
import 'package:walleta/providers/ads_provider.dart';
import 'package:walleta/providers/auth_provider.dart';
import 'package:walleta/providers/theme_provider.dart';
import 'package:walleta/repository/FinancialSummary/financial_summary_repository.dart';
import 'package:walleta/repository/SharedExpensePayment/shared_expense_payment_repository.dart';
import 'package:walleta/repository/income/income_repository.dart';
import 'package:walleta/repository/incomePayment/income_payment_repository.dart';
import 'package:walleta/repository/loan/loan_repository.dart';
import 'package:walleta/repository/payment/payment.dart';
import 'package:walleta/repository/personalExpense/personal_expense.dart';
import 'package:walleta/repository/personalExpensePayment/personal_expense_payment_repository.dart';
import 'package:walleta/repository/repository.dart';
import 'package:walleta/repository/saving/saving_repository.dart';
import 'package:walleta/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/blocs/sharedExpense/bloc/shared_expense_bloc.dart';
import 'package:walleta/repository/sharedExpense/shared_expense_repository.dart';

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

          // 🔥 CAMBIAR: Constructor sin parámetros
          ChangeNotifierProvider<AdsProvider>(create: (_) => AdsProvider()),

          BlocProvider(
            create:
                (_) => AuthenticationBloc(
                  authenticationRepository: authenticationRepository,
                ),
          ),
          BlocProvider(
            create:
                (_) => SharedExpenseBloc(
                  sharedExpenseRepository: SharedExpenseRepository(),
                ),
          ),
          BlocProvider(
            create: (_) => LoanBloc(loanRepository: LoanRepository()),
          ),
          BlocProvider(
            create: (_) => PaymentBloc(paymentRepository: PaymentRepository()),
          ),
          BlocProvider(
            create:
                (_) => ExpensePaymentBloc(
                  repository: SharedExpensePaymentRepository(),
                ),
          ),
          BlocProvider(
            create:
                (_) => PersonalExpensePaymentBloc(
                  repository: PersonalExpensePaymentRepository(),
                ),
          ),
          BlocProvider<PersonalExpenseBloc>(
            create:
                (_) => PersonalExpenseBloc(
                  repository: PersonalExpenseRepository(),
                ),
          ),
          BlocProvider<IncomesBloc>(
            create: (_) => IncomesBloc(repository: IncomesRepository()),
          ),
          BlocProvider<IncomesPaymentBloc>(
            create:
                (_) =>
                    IncomesPaymentBloc(repository: IncomePaymentRepository()),
          ),
          BlocProvider<FinancialSummaryBloc>(
            create:
                (_) => FinancialSummaryBloc(
                  repository: FinancialSummaryRepository(),
                ),
          ),
          BlocProvider(
            create: (_) => SavingBloc(repository: SavingGoalRepository()),
          ),
        ],
        child: Builder(
          builder: (context) {
            // 🔥 INICIALIZAR AdsProvider después de que el árbol esté construido
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final adsProvider = context.read<AdsProvider>();
              adsProvider.initialize(context);
            });

            return AppView();
          },
        ),
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
          theme: themeProvider.theme,
          locale: const Locale('es', 'ES'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],
          builder: (context, child) {
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
                  default:
                    break;
                }
              },
              child: child,
            );
          },
        );
      },
    );
  }
}
