import 'package:fl_chart/fl_chart.dart'; // Import wajib untuk grafik
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Back & Judul
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Statistik Keuangan",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Kartu Total Pengeluaran (Transparan)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2), // Efek kaca
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Pengeluaran Bulan Ini", style: GoogleFonts.poppins(color: Colors.white70)),
                        const SizedBox(height: 8),
                        Text(
                          "Rp 190.000",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. ISI KONTEN (Card-card putih)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // A. Row Rata-rata & Transaksi
                  Row(
                    children: [
                      Expanded(child: _buildSummaryCard("Rata-rata Harian", "Rp 6.333,33")),
                      const SizedBox(width: 16),
                      Expanded(child: _buildSummaryCard("Transaksi", "6 kali")),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // B. PIE CHART (Pengeluaran per Kategori)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Pengeluaran per Kategori", style: _titleStyle()),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 200, // Tinggi area chart
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 0, // 0 = Full Pie, >0 = Donut
                              sections: [
                                _buildPieSection(color: const Color(0xFF2196F3), value: 39, title: "39%"), // Makanan
                                _buildPieSection(color: const Color(0xFFE91E63), value: 53, title: "53%"), // Hiburan
                                _buildPieSection(color: const Color(0xFF9C27B0), value: 8, title: "8%"),  // Transport
                              ],
                            ),
                          ),
                        ),
                        // Legenda Manual (Label)
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildLegend(color: const Color(0xFF2196F3), label: "Makanan"),
                            _buildLegend(color: const Color(0xFFE91E63), label: "Hiburan"),
                            _buildLegend(color: const Color(0xFF9C27B0), label: "Transport"),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // C. DETAIL KATEGORI (Progress Bars)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Detail Kategori", style: _titleStyle()),
                        const SizedBox(height: 20),
                        _buildCategoryProgress("Makanan", "Rp 75.000", 0.39, const Color(0xFF2196F3)),
                        _buildCategoryProgress("Transportasi", "Rp 15.000", 0.08, const Color(0xFF9C27B0)),
                        _buildCategoryProgress("Hiburan", "Rp 100.000", 0.53, const Color(0xFFE91E63)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // D. BAR CHART (Tren Mingguan)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: _cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tren Pengeluaran Mingguan", style: _titleStyle()),
                        const SizedBox(height: 20),
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: BarChart(
                            BarChartData(
                              gridData: const FlGridData(show: false), // Hapus garis grid
                              titlesData: FlTitlesData(
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 8.0),
                                        child: Text("Minggu 47", style: TextStyle(fontSize: 12)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(color: Colors.black12),
                                  bottom: BorderSide(color: Colors.black12),
                                ),
                              ),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 190000, // Tinggi batang
                                      color: const Color(0xFF585CE5),
                                      width: 40,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40), // Spacer bawah agar scroll enak
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS (Supaya kode utama rapi) ---

  // Style untuk Judul Section (Contoh: "Detail Kategori")
  TextStyle _titleStyle() {
    return GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87);
  }

  // Style Dekorasi Kartu Putih
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 2, offset: const Offset(0, 4)),
      ],
    );
  }

  // Widget Kartu Kecil (Rata-rata & Transaksi)
  Widget _buildSummaryCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  // Helper untuk membuat Bagian Pie Chart
  PieChartSectionData _buildPieSection({required Color color, required double value, required String title}) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: 50,
      titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  // Helper untuk Legenda Pie Chart
  Widget _buildLegend({required Color color, required String label}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  // Widget Progress Bar (Detail Kategori)
  Widget _buildCategoryProgress(String label, String amount, double percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: GoogleFonts.poppins(color: Colors.grey[700])),
              Text(amount, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage, // 0.0 sampai 1.0
            backgroundColor: Colors.grey[200],
            color: color,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}