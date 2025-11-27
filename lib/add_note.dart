import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final titleController = TextEditingController();
  final amountController = TextEditingController();

  String type = "expense";
  bool loading = false;

  Future<void> saveTransaction() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final title = titleController.text.trim();
    final amountText = amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) {
      show("Judul dan jumlah wajib diisi");
      return;
    }

    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      show("Jumlah harus angka");
      return;
    }

    try {
      setState(() => loading = true);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .add({
        "title": title,
        "amount": amount,
        "type": type,
        "created": Timestamp.now(),
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      show(e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Transaksi")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Jumlah"),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text("Pengeluaran"),
                    value: "expense",
                    groupValue: type,
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text("Pemasukan"),
                    value: "income",
                    groupValue: type,
                    onChanged: (v) => setState(() => type = v!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: saveTransaction,
              child: Text(
                "SIMPAN",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
