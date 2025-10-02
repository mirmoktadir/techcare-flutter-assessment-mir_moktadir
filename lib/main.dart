import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/widgets/app_bottom_nav.dart';
import 'features/transactions/bloc/transaction_bloc.dart';
import 'features/transactions/presentation/pages/add_transaction_page.dart';
import 'features/transactions/presentation/pages/transactions_page.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: {
        '/': (context) => const MainBottomNav(), // home
        '/transactions': (context) => BlocProvider.value(
          value: di.sl<TransactionBloc>(),
          child: const TransactionsPage(),
        ),
        '/add-transaction': (context) => const AddTransactionPage(),
        // Add others if needed
      },
      initialRoute: '/',
    );
  }
}
