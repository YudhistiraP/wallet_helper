import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'stat_model.dart';

class StatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getTransactions({
    required String uid,
    required DateTime start,
    required DateTime end,
    required bool isExpense,
  }) async {
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('created', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created', isLessThan: Timestamp.fromDate(end))
        .where('type', isEqualTo: isExpense ? 'expense' : 'income')
        .get();

    return snap.docs.map((d) => d.data()).toList();
  }

  List<StatData> _buildCategoryStats(List<Map<String, dynamic>> items) {
    final Map<String, double> sums = {};

    for (final data in items) {
      final String title = (data['title'] ?? 'Lainnya').toString();
      final dynamic rawAmount = data['amount'];

      final double amount = rawAmount is int
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount.toString()) ?? 0;

      if (amount <= 0) continue;

      sums[title] = (sums[title] ?? 0) + amount;
    }

    final colors = <Color>[
      const Color(0xFFE91E63),
      const Color(0xFF3F51B5),
      const Color(0xFFFF9800),
      const Color(0xFF4CAF50),
      const Color(0xFF9C27B0),
      const Color(0xFF009688),
    ];

    final icons = <IconData>[
      Icons.home_outlined,
      Icons.fastfood_outlined,
      Icons.shopping_bag_outlined,
      Icons.directions_car_outlined,
      Icons.movie_outlined,
      Icons.more_horiz,
    ];

    int i = 0;
    final list = sums.entries.map<StatData>((e) {
      final idx = i++;
      return StatData(
        e.key,
        e.value,
        colors[idx % colors.length],
        icons[idx % icons.length],
      );
    }).toList();

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }

  Future<List<StatData>> getStatsForMonth({
    required String uid,
    required DateTime month,
    required bool isExpense,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final items = await _getTransactions(
      uid: uid,
      start: start,
      end: end,
      isExpense: isExpense,
    );
    return _buildCategoryStats(items);
  }

  Future<List<StatData>> getStatsForYear({
    required String uid,
    required int year,
    required bool isExpense,
  }) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final items = await _getTransactions(
      uid: uid,
      start: start,
      end: end,
      isExpense: isExpense,
    );
    return _buildCategoryStats(items);
  }

  Future<List<double>> getWeeklyTotals({
    required String uid,
    required DateTime month,
    required bool isExpense,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final items = await _getTransactions(
      uid: uid,
      start: start,
      end: end,
      isExpense: isExpense,
    );

    final totals = List<double>.filled(4, 0);

    for (final data in items) {
      final created = data['created'];
      if (created is! Timestamp) continue;
      final date = created.toDate();

      int index = ((date.day - 1) / 7).floor();
      if (index < 0) index = 0;
      if (index > 3) index = 3;

      final dynamic rawAmount = data['amount'];
      final double amount = rawAmount is int
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount.toString()) ?? 0;

      if (amount <= 0) continue;
      totals[index] += amount;
    }

    return totals;
  }

  Future<List<double>> getMonthlyTotals({
    required String uid,
    required int year,
    required bool isExpense,
  }) async {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);
    final items = await _getTransactions(
      uid: uid,
      start: start,
      end: end,
      isExpense: isExpense,
    );

    final totals = List<double>.filled(12, 0);

    for (final data in items) {
      final created = data['created'];
      if (created is! Timestamp) continue;
      final date = created.toDate();
      final int index = date.month - 1;
      if (index < 0 || index >= 12) continue;

      final dynamic rawAmount = data['amount'];
      final double amount = rawAmount is int
          ? rawAmount.toDouble()
          : double.tryParse(rawAmount.toString()) ?? 0;

      if (amount <= 0) continue;
      totals[index] += amount;
    }

    return totals;
  }
}
