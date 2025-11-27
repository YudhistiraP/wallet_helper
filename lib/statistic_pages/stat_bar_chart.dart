import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatBarChart extends StatelessWidget {
  final bool isExpense;
  final String viewMode;
  final List<double> barData;
  final List<String> labels;

  const StatBarChart({
    super.key,
    required this.isExpense,
    required this.viewMode,
    required this.barData,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    List<double> safeData = barData.isEmpty ? [0, 0, 0, 0] : barData;

    Color barColor = isExpense ? Colors.redAccent : Colors.green;
    double maxY = safeData.reduce((curr, next) => curr > next ? curr : next);
    if (maxY == 0) {
      maxY = 1;
    }
    maxY = maxY * 1.2;

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
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                                fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              barGroups: List.generate(safeData.length, (index) {
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: safeData[index],
                      color: barColor,
                      width: viewMode == "Monthly" ? 20 : 12,
                      borderRadius: BorderRadius.circular(4),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
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
