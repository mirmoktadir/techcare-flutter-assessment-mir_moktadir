import 'package:flutter/material.dart';

import '../../../../core/utils/number_formatter.dart';

class BalanceCard extends StatefulWidget {
  final double balance;
  final double income;
  final double expense;
  final bool showBalance;
  final VoidCallback onToggle;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.income,
    required this.expense,
    required this.showBalance,
    required this.onToggle,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    if (!widget.showBalance) _controller.value = 1;
  }

  @override
  void didUpdateWidget(covariant BalanceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showBalance != oldWidget.showBalance) {
      if (widget.showBalance) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: Colors.white.withValues(alpha: 0.95),
          child: InkWell(
            onTap: widget.onToggle,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value * 3.14159;
                return Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  alignment: Alignment.center,
                  child: angle > 1.57 ? _buildBack() : _buildFront(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormatter.format(widget.balance),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildSummary('Income', widget.income, Colors.green),
              const SizedBox(width: 24),
              _buildSummary('Expense', widget.expense, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.visibility_off, size: 48, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'Tap to show balance',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
        Text(
          NumberFormatter.format(amount),
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
