import 'package:flutter/material.dart';
import 'package:flutters/statistik_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'statistik_screen.dart';

// --- 1. DATA MODEL & DUMMY DATA ---
// Kita buat class agar data rapi dan bisa dipanggil di mana saja
class Transaction {
  final String title;
  final String subtitle;
  final int amount;
  final bool isIncome;
  final IconData icon;
  final Color color;

  Transaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.color,
  });
}

// Ini daftar semua transaksi (History Lengkap)
List<Transaction> allTransactions = [
  Transaction(title: "Uang Bulanan", subtitle: "Transfer dari orang tua", amount: 1500000, isIncome: true, icon: Icons.account_balance_wallet, color: Colors.green),
  Transaction(title: "Makanan", subtitle: "Kopi pagi", amount: 25000, isIncome: false, icon: Icons.fastfood, color: Colors.red),
  Transaction(title: "Transportasi", subtitle: "Ojek online ke kampus", amount: 15000, isIncome: false, icon: Icons.motorcycle, color: Colors.red),
  Transaction(title: "Pulsa & Data", subtitle: "Paket internet bulanan", amount: 100000, isIncome: false, icon: Icons.wifi, color: Colors.blue),
  Transaction(title: "Hiburan", subtitle: "Nonton bioskop", amount: 50000, isIncome: false, icon: Icons.movie, color: Colors.purple),
  Transaction(title: "Belanja", subtitle: "Kebutuhan sabun & sampo", amount: 75000, isIncome: false, icon: Icons.shopping_bag, color: Colors.orange),
  Transaction(title: "Freelance", subtitle: "Project pembuatan web", amount: 500000, isIncome: true, icon: Icons.laptop_mac, color: Colors.green),
];

void main() {
  runApp(const FinanceApp());
}

class FinanceApp extends StatelessWidget {
  const FinanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Keuangan Ripia',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

// --- 2. HALAMAN UTAMA (HOME) ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = const Color(0xFF585CE5);

    return Scaffold(
      backgroundColor: primaryColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Halo, Ripia! 👋", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text("Selamat Datang Kembali", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                ],
              ),
            ),

            // Body Putih
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  children: [
                    // Kartu Saldo
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Saldo Saat Ini", style: GoogleFonts.poppins(color: Colors.grey[600])),
                          const SizedBox(height: 8),
                          Text(formatRupiah(1810000), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF585CE5))),
                          const SizedBox(height: 24),
                          Row(
                            children: const [
                              Expanded(child: InfoBox(label: "Pemasukan", amount: 2000000, color: Colors.green, bgColor: Color(0xFFE8F5E9), icon: Icons.trending_up)),
                              SizedBox(width: 16),
                              Expanded(child: InfoBox(label: "Pengeluaran", amount: 190000, color: Colors.red, bgColor: Color(0xFFFFEBEE), icon: Icons.trending_down)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Menu
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector( // <-- Tambahkan ini
                            onTap: () {
                              // Navigasi ke Halaman Statistik
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const StatistikScreen()),
                              );
                            },
                            child: const ActionButton(icon: Icons.pie_chart, label: "Statistik"),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(child: ActionButton(icon: Icons.history, label: "Riwayat")),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- BAGIAN TRANSAKSI TERAKHIR (UPDATE DI SINI) ---
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        children: [
                          // Header dengan Tombol Selengkapnya
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Transaksi Terakhir", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              GestureDetector(
                                onTap: () {
                                  // Navigasi ke Halaman Riwayat
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                                  );
                                },
                                child: const Text(
                                  "Selengkapnya",
                                  style: TextStyle(fontSize: 12, color: Color(0xFF585CE5), fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Menampilkan HANYA 3 transaksi teratas
                          ...allTransactions.take(3).map((transaksi) {
                            return TransactionItem(data: transaksi);
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 3. HALAMAN BARU: RIWAYAT TRANSAKSI (HISTORY SCREEN) ---
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Riwayat Transaksi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), // Tombol back hitam
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        // ListView.builder lebih efisien untuk list panjang
        child: ListView.builder(
          itemCount: allTransactions.length,
          itemBuilder: (context, index) {
            final transaksi = allTransactions[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10), // Jarak antar item
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100), // Garis tipis
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5),
                ],
              ),
              child: TransactionItem(data: transaksi), // Reuse widget yang sama
            );
          },
        ),
      ),
    );
  }
}

// --- WIDGET COMPONENTS ---

// Helper Format Rupiah
String formatRupiah(int amount) {
  return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
}

class InfoBox extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const InfoBox({super.key, required this.label, required this.amount, required this.color, required this.bgColor, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 16, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontSize: 12))]),
          const SizedBox(height: 8),
          Text(formatRupiah(amount), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [Icon(icon, color: Colors.black87), const SizedBox(height: 8), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))],
      ),
    );
  }
}

// Widget Item Transaksi (UPDATED: Menerima object Transaction)
class TransactionItem extends StatelessWidget {
  final Transaction data;

  const TransactionItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: data.color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(data.subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(
            (data.isIncome ? "+" : "-") + formatRupiah(data.amount),
            style: TextStyle(color: data.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}