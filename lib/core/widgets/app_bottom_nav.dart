// lib/features/common/widgets/app_bottom_nav.dart

import 'package:finance_tracker/features/categories/bloc/category_bloc.dart';
import 'package:finance_tracker/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/analytics/bloc/analytics_bloc.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/transactions/bloc/transaction_bloc.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    // Dashboard uses AnalyticsBloc + TransactionBloc
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: di.sl<AnalyticsBloc>()),
        BlocProvider.value(value: di.sl<TransactionBloc>()),
        BlocProvider.value(value: di.sl<CategoryBloc>()),
      ],
      child: const DashboardPage(),
    ),
    // Transactions screen
    BlocProvider.value(
      value: di.sl<TransactionBloc>(),
      child: const TransactionsPage(),
    ),
    // Analytics screen
    BlocProvider.value(
      value: di.sl<AnalyticsBloc>(),
      child: const AnalyticsPage(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}
