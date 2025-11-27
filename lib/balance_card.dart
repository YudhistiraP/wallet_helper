import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BalanceCard extends StatefulWidget {
  final String formattedDate;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onSelectMonth;

  final int totalBalance;
  final int totalIncome;
  final int totalExpense;

  const BalanceCard({
    super.key,
    required this.formattedDate,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onSelectMonth,
    this.totalBalance = 0,
    this.totalIncome = 0,
    this.totalExpense = 0,
  });

  @override
  State<BalanceCard> createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true;

  void _toggleVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: widget.onPrevMonth,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_back_ios, size: 16, color: Colors.blue),
                      ),
                    ),

                    GestureDetector(
                      onTap: widget.onSelectMonth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          widget.formattedDate,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: TextDecoration.underline,
                            decorationStyle: TextDecorationStyle.dotted,
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: widget.onNextMonth,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),

                IconButton(
                  onPressed: _toggleVisibility,
                  icon: Icon(
                    _isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.black54,
                  ),
                  tooltip: _isBalanceVisible ? "Sembunyikan Saldo" : "Tampilkan Saldo",
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBalanceItem("Total", widget.totalBalance, Colors.grey),
                _buildBalanceItem("Income", widget.totalIncome, Colors.green),
                _buildBalanceItem("Expenses", widget.totalExpense, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, int amount, Color colorVal) {
    return Column(
      children: [
        Text(
          _isBalanceVisible ? formatRupiah(amount) : "Rp ••••••",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: colorVal
          ),
        ),
        Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)
        ),
      ],
    );
  }

  String formatRupiah(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0).format(amount);
  }
}