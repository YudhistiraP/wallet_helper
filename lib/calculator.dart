import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calculator_keyboard.dart';
import 'category_grid.dart';
import 'category_icon_map.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  bool isExpense = true;
  String? selectedCategory;
  final TextEditingController noteController = TextEditingController();

  String display = "0";
  String current = "";
  double? prev;
  String? op;
  int? finalAmount;
  bool loading = false;

  // ✅ ICONS FROM category_icon_map.dart
  List<Map<String, dynamic>> get expenseCategories => [
    {"name": "food", "icon": categoryIcon["food"]},
    {"name": "transport", "icon": categoryIcon["transport"]},
    {"name": "clothes", "icon": categoryIcon["clothes"]},
    {"name": "beauty", "icon": categoryIcon["beauty"]},
    {"name": "education", "icon": categoryIcon["education"]},
    {"name": "medical", "icon": categoryIcon["medical"]},
    {"name": "bills", "icon": categoryIcon["bills"]},
    {"name": "entertain", "icon": categoryIcon["entertain"]},
    {"name": "travel", "icon": categoryIcon["travel"]},
    {"name": "social", "icon": categoryIcon["social"]},
    {"name": "games", "icon": categoryIcon["games"]},
    {"name": "other", "icon": categoryIcon["other"]},
  ];

  List<Map<String, dynamic>> get incomeCategories => [
    {"name": "wage", "icon": categoryIcon["wage"]},
    {"name": "investment", "icon": categoryIcon["investment"]},
    {"name": "part time", "icon": categoryIcon["part time"]},
    {"name": "bonus", "icon": categoryIcon["bonus"]},
  ];

  List<Map<String, dynamic>> get activeCategories =>
      isExpense ? expenseCategories : incomeCategories;

  void onKey(String key) {
    setState(() {
      if (key == 'C') {
        display = "0";
        current = "";
        prev = null;
        op = null;
        finalAmount = null;
      } else if (key == 'DEL') {
        if (current.isNotEmpty) {
          current = current.substring(0, current.length - 1);
          display = current.isEmpty ? "0" : current;
        }
      } else if (['+', '-', 'x', '÷'].contains(key)) {
        prev = double.tryParse(current.isEmpty ? "0" : current) ?? 0;
        op = key;
        current = "";
      } else if (key == '=') {
        final second = double.tryParse(current.isEmpty ? "0" : current) ?? 0;

        double result = prev ?? second;
        if (op == '+') result = (prev ?? 0) + second;
        if (op == '-') result = (prev ?? 0) - second;
        if (op == 'x') result = (prev ?? 0) * second;
        if (op == '÷') result = second == 0 ? 0 : (prev ?? 0) / second;

        final intResult = result.round();
        finalAmount = intResult;
        display = intResult.toString();
        current = display;
      } else {
        current += key;
        display = current;
      }
    });
  }

  Future<void> saveTransaction() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showMessage("User belum login");
      return;
    }

    final note = noteController.text.trim();
    final title = note.isNotEmpty
        ? note
        : (selectedCategory != null ? selectedCategory! : "Transaksi");

    int? amount = finalAmount;
    if (amount == null || amount <= 0) {
      amount = int.tryParse(display);
    }
    if (amount == null || amount <= 0) {
      showMessage("Jumlah belum diisi");
      return;
    }

    try {
      setState(() => loading = true);

      final firestore = FirebaseFirestore.instance;
      final uid = user.uid;

      final transactionRef = firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc();

      final walletRef =
      firestore.collection('users').doc(uid).collection('meta').doc('wallet');

      await transactionRef.set({
        "title": title,
        "amount": amount,
        "type": isExpense ? "expense" : "income",
        "created": Timestamp.now(),
        "category": selectedCategory,
        "note": note,
      });

      await firestore.runTransaction((tx) async {
        final snap = await tx.get(walletRef);

        double balance = 0;
        double income = 0;
        double expenses = 0;

        if (snap.exists) {
          final data = snap.data()!;
          balance = (data['balance'] ?? 0).toDouble();
          income = (data['income'] ?? 0).toDouble();
          expenses = (data['expenses'] ?? 0).toDouble();
        }

        if (isExpense) {
          balance -= amount!;
          expenses += amount;
        } else {
          balance += amount!;
          income += amount;
        }

        tx.set(
          walletRef,
          {
            "balance": balance,
            "income": income,
            "expenses": expenses,
            "updated": Timestamp.now(),
          },
          SetOptions(merge: true),
        );
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    Color yellowColor = const Color(0xFFFFF78A);
    Color peachColor = const Color(0xFFF6A987);

    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add",
          style: GoogleFonts.poppins(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loading ? null : saveTransaction,
            icon: const Icon(Icons.check, color: Colors.black87),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTypeButton("Expenses", true),
                  const SizedBox(width: 4),
                  _buildTypeButton("Income", false),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: peachColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 230,
                    child: CategoryGrid(
                      categories: activeCategories,
                      selectedCategory: selectedCategory,
                      onCategorySelected: (name) {
                        setState(() {
                          selectedCategory = name;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF5DD),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: noteController,
                                    decoration:
                                    const InputDecoration(labelText: "Note"),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  display,
                                  style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          CalculatorKeyboard(onKeyTap: onKey),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String text, bool value) {
    final bool active = isExpense == value;
    return GestureDetector(
      onTap: () {
        if (!active) {
          setState(() {
            isExpense = value;
            selectedCategory = null;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: active ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
