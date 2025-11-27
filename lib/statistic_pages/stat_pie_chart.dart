import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'stat_model.dart';

class StatPieChart extends StatefulWidget {
  final List<StatData> data;
  final double totalAmount;
  final bool isExpense;

  const StatPieChart({
    super.key,
    required this.data,
    required this.totalAmount,
    required this.isExpense,
  });

  @override
  State<StatPieChart> createState() => _StatPieChartState();
}

class _StatPieChartState extends State<StatPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final double safeTotal =
    widget.totalAmount == 0 ? 1 : widget.totalAmount;

    return Column(
      children: [
        Text(
          "Total ${widget.isExpense ? 'Pengeluaran' : 'Pemasukan'}",
          style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12),
        ),
        Text(
          NumberFormat.currency(
              locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
              .format(widget.totalAmount),
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback:
                    (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!
                            .touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(widget.data.length, (i) {
                final isTouched = i == touchedIndex;
                final fontSize = isTouched ? 16.0 : 12.0;
                final radius = isTouched ? 60.0 : 50.0;
                final item = widget.data[i];
                final percentage =
                    (item.amount / safeTotal) * 100;

                return PieChartSectionData(
                  color: item.color,
                  value: item.amount,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: radius,
                  titleStyle: GoogleFonts.poppins(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
