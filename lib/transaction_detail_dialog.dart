import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_icon_map.dart';

class TransactionDetailDialog extends StatelessWidget {
  final String title;
  final String subtitle;
  final int amount;
  final IconData icon;
  final Color color;
  final String date;
  final String docId;

  const TransactionDetailDialog({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.icon,
    required this.color,
    required this.date,
    required this.docId,
  });

  Future<void> _delete(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    final txRef = firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .doc(docId);

    final walletRef =
    firestore.collection('users').doc(uid).collection('meta').doc('wallet');

    await firestore.runTransaction((tx) async {
      final snap = await txRef.get();
      final wallet = await tx.get(walletRef);
      final data = snap.data()!;

      int amt = data['amount'];
      double balance = (wallet['balance'] ?? 0).toDouble();
      double income = (wallet['income'] ?? 0).toDouble();
      double expenses = (wallet['expenses'] ?? 0).toDouble();

      if (subtitle == 'income') {
        balance -= amt;
        income -= amt;
      } else {
        balance += amt;
        expenses -= amt;
      }

      tx.delete(txRef);
      tx.set(walletRef, {
        "balance": balance,
        "income": income,
        "expenses": expenses,
      }, SetOptions(merge: true));
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(date),
          const SizedBox(height: 10),
          Text(
            "Rp ${amount.abs()}",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: subtitle == 'income' ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("CANCEL"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          onPressed: () => _delete(context),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text("DELETE"),
        ),
        ElevatedButton(
          child: const Text("EDIT"),
          onPressed: () {
            // hook for edit
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
