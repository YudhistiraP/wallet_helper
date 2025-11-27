import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatBarChart extends StatelessWidget {
  final bool isExpense;
  final String viewMode; // "Monthly" atau "Yearly"

  const StatBarChart({
    super.key,
    required this.isExpense,
    required this.viewMode,
  });

  @override
  Widget build(BuildContext context) {
    // --- DUMMY DATA GENERATOR ---
    // Di aplikasi nyata, data ini dikirim dari parent berdasarkan database
    List<double> barData;
    List<String> labels;

    if (viewMode == "Monthly") {
      // Data Mingguan (4 Minggu)
      barData = isExpense
          ? [500000, 700000, 300000, 450000] // Expense mingguan
          : [1200000, 0, 500000, 0];         // Income mingguan
      labels = ["W1", "W2", "W3", "W4"];
    } else {
      // Data Tahunan (12 Bulan)
      // Kita pakai data dummy pendek saja biar chart tidak terlalu padat
      barData = isExpense
          ? [1.5, 2.0, 1.2, 3.0, 2.5, 1.8, 2.2, 1.5, 3.5, 2.0, 1.0, 4.0] // Skala Juta
          : [5.0, 5.0, 5.0, 6.0, 5.0, 5.5, 5.0, 5.0, 7.0, 5.0, 5.0, 8.0];
      labels = ["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"];
    }

    // Tentukan warna bar
    Color barColor = isExpense ? Colors.redAccent : Colors.green;
    double maxY = barData.reduce((curr, next) => curr > next ? curr : next) * 1.2; // Sedikit ruang di atas

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          viewMode == "Monthly" ? "Weekly Breakdown" : "Monthly Breakdown",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 20),
        AspectRatio(
          aspectRatio: 1.6,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              // Hilangkan grid & border
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),

              // Judul (Labels)
              titlesData: FlTitlesData(
                show: true,
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hilangkan angka Y-axis agar bersih
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() < labels.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            labels[value.toInt()],
                            style: GoogleFonts.poppins(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),

              // Data Batang
              barGroups: List.generate(barData.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: barData[index],
                      color: barColor,
                      width: viewMode == "Monthly" ? 20 : 12, // Lebih tipis jika tahunan
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY, // Background abu-abu penuh sampai atas
                        color: Colors.grey.withOpacity(0.1),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}