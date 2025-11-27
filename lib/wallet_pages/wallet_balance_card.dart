import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Model Data
class WalletData {
  final double totalBalance;
  final double income;
  final double expenses;
  final bool isBalanceHidden;

  WalletData({
    required this.totalBalance,
    required this.income,
    required this.expenses,
    this.isBalanceHidden = true,
  });
}

class WalletBalanceCard extends StatelessWidget {
  final WalletData data;
  final VoidCallback onToggleVisibility;

  // --- TAMBAHAN PARAMETER MATA UANG ---
  final String currencyCode; // Contoh: IDR, USD
  final String currencySymbol; // Contoh: Rp, $
  final double exchangeRate; // Rate konversi dari IDR ke mata uang terpilih

  const WalletBalanceCard({
    super.key,
    required this.data,
    required this.onToggleVisibility,
    required this.currencyCode,
    required this.currencySymbol,
    required this.exchangeRate,
  });

  // Helper Format Uang (IDR vs Asing)
  String _formatMoney(double baseAmountIdr, bool isHidden) {
    if (isHidden) {
      return '$currencySymbol ••••••';
    }

    // Konversi nilai
    double convertedAmount = baseAmountIdr * exchangeRate;

    // Format angka
    // IDR & JPY biasanya 0 desimal, lainnya 2 desimal
    int decimalDigits = (currencyCode == 'IDR' || currencyCode == 'JPY') ? 0 : 2;

    return NumberFormat.currency(
      locale: 'en_US', // Gunakan format internasional (titik sebagai desimal)
      symbol: '$currencySymbol ',
      decimalDigits: decimalDigits,
    ).format(convertedAmount);
  }

  @override
  Widget build(BuildContext context) {
    const Color incomeColor = Colors.green;
    const Color expensesColor = Colors.red;
    const Color cardColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(15.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'WALLET ($currencyCode)', // Tampilkan kode mata uang
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    letterSpacing: 1.5,
                  ),
                ),
                GestureDetector(
                  onTap: onToggleVisibility,
                  child: Row(
                    children: [
                      Icon(
                        data.isBalanceHidden ? Icons.visibility_off : Icons.visibility,
                        color: Colors.black54,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.monetization_on, color: Colors.black54, size: 20),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 30, thickness: 0.5, color: Colors.black12),

            // Total Balance
            Text('Total', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54)),
            Text(
              _formatMoney(data.totalBalance, data.isBalanceHidden),
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),

            const SizedBox(height: 15),

            // Income & Expense Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Income', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                      Text(
                        _formatMoney(data.income, data.isBalanceHidden),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: incomeColor),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Expenses', style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)),
                      Text(
                        _formatMoney(data.expenses, data.isBalanceHidden),
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: expensesColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}