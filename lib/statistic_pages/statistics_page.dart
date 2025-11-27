import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// IMPORT FILE-FILE PENDUKUNG
import 'stat_model.dart';
import 'stat_pie_chart.dart';
import 'stat_bar_chart.dart';
import 'stat_category_list.dart';
import '../settings_page.dart'; // Import Settings Page
import '../wallet_pages/wallet_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  // State
  bool isExpense = true;
  DateTime currentDate = DateTime.now();
  String viewMode = "Monthly"; // "Monthly" or "Yearly"

  // State untuk Bottom Nav (Default 2 karena ini halaman Statistik)
  int _bottomNavIndex = 2;

  // Dummy Data
  final List<StatData> expenseData = [
    StatData("Food", 1500000, Colors.redAccent, Icons.fastfood),
    StatData("Transport", 500000, Colors.blueAccent, Icons.directions_car),
    StatData("Shopping", 750000, Colors.purple, Icons.shopping_bag),
    StatData("Utilities", 300000, Colors.orange, Icons.electric_bolt),
  ];

  final List<StatData> incomeData = [
    StatData("Salary", 5000000, Colors.green, Icons.account_balance_wallet),
    StatData("Freelance", 1500000, Colors.teal, Icons.laptop_mac),
    StatData("Bonus", 500000, Colors.amber, Icons.card_giftcard),
  ];

  void _changeDate(int offset) {
    setState(() {
      if (viewMode == "Monthly") {
        currentDate = DateTime(currentDate.year, currentDate.month + offset);
      } else {
        currentDate = DateTime(currentDate.year + offset, currentDate.month);
      }
    });
  }

  // Logika Navigasi Bottom Bar
  void _onBottomNavTap(int index) {
    // Jangan update state index jika akan pindah halaman (kecuali mau highlight sementara)
    // setState(() => _bottomNavIndex = index); 

    if (index == 0) {
      // 0 = Home: Kembali ke halaman utama
      Navigator.popUntil(context, (route) => route.isFirst);
    }
    else if (index == 1) {
      // 1 = Wallet
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalletPage()),
      ).then((_) {
        // Kembalikan highlight ke Statistics saat kembali
        setState(() => _bottomNavIndex = 2);
      });
    }
    else if (index == 2) {
      // 2 = Statistics: Sudah di sini
      setState(() => _bottomNavIndex = index);
    }
    else if (index == 3) {
      // 3 = Settings
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ).then((_) {
        // Kembalikan highlight ke Statistics saat kembali
        setState(() => _bottomNavIndex = 2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color yellowColor = const Color(0xFFFFF78A);
    Color peachColor = const Color(0xFFF6A987);

    List<StatData> activeData = isExpense ? expenseData : incomeData;
    double totalAmount = activeData.fold(0, (sum, item) => sum + item.amount);

    String dateText = viewMode == "Monthly"
        ? DateFormat('MMMM yyyy', 'id_ID').format(currentDate)
        : DateFormat('yyyy', 'id_ID').format(currentDate);

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
          "Statistics",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // HEADER NAVIGATOR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.chevron_left, size: 28, color: Colors.black54),
                ),
                Text(
                  dateText,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.chevron_right, size: 28, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 35,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: viewMode,
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                      items: const [
                        DropdownMenuItem(value: "Monthly", child: Text("M")),
                        DropdownMenuItem(value: "Yearly", child: Text("Y")),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) setState(() => viewMode = newValue);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // TOGGLE SWITCH
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE082),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleButton("Expenses", true),
                  const SizedBox(width: 4),
                  _buildToggleButton("Income", false),
                ],
              ),
            ),
          ),

          // KONTEN UTAMA (SCROLLABLE)
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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        children: [
                          // 1. PIE CHART
                          StatPieChart(
                              data: activeData,
                              totalAmount: totalAmount,
                              isExpense: isExpense
                          ),

                          const SizedBox(height: 30),
                          const Divider(),
                          const SizedBox(height: 20),

                          // 2. BAR CHART
                          StatBarChart(
                              isExpense: isExpense,
                              viewMode: viewMode
                          ),

                          const SizedBox(height: 30),
                          const Divider(),
                          const SizedBox(height: 20),

                          // 3. CATEGORY LIST
                          StatCategoryList(
                              data: activeData,
                              totalAmount: totalAmount,
                              isExpense: isExpense
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistics"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool targetIsExpense) {
    bool isActive = (isExpense == targetIsExpense);
    return GestureDetector(
      onTap: () => setState(() => isExpense = targetIsExpense),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (isActive)
              Icon(targetIsExpense ? Icons.money_off : Icons.attach_money,
                  size: 16, color: const Color(0xFFFFEB3B)),
            if (isActive) const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
