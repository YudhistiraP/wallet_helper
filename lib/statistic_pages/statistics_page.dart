import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'stat_model.dart';
import 'stat_pie_chart.dart';
import 'stat_bar_chart.dart';
import 'stat_category_list.dart';
import 'stat_service.dart';
import '../settings_page.dart';
import '../wallet_pages/wallet_page.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool isExpense = true;
  DateTime currentDate = DateTime.now();
  String viewMode = "Monthly";

  int _bottomNavIndex = 2;

  final StatService _statService = StatService();

  bool _loading = true;
  List<StatData> _activeData = [];
  List<double> _barData = [];
  List<String> _barLabels = [];
  double _totalAmount = 0;

  void _changeDate(int offset) {
    setState(() {
      if (viewMode == "Monthly") {
        currentDate =
            DateTime(currentDate.year, currentDate.month + offset);
      } else {
        currentDate =
            DateTime(currentDate.year + offset, currentDate.month);
      }
    });
    _loadStats();
  }

  void _onBottomNavTap(int index) {
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalletPage()),
      ).then((_) {
        setState(() => _bottomNavIndex = 2);
      });
    } else if (index == 2) {
      setState(() => _bottomNavIndex = index);
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SettingsPage()),
      ).then((_) {
        setState(() => _bottomNavIndex = 2);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      _loading = true;
    });

    final uid = user.uid;

    if (viewMode == "Monthly") {
      final categories = await _statService.getStatsForMonth(
        uid: uid,
        month: currentDate,
        isExpense: isExpense,
      );
      final weekly = await _statService.getWeeklyTotals(
        uid: uid,
        month: currentDate,
        isExpense: isExpense,
      );
      final total =
      categories.fold<double>(0, (sum, item) => sum + item.amount);

      setState(() {
        _activeData = categories;
        _totalAmount = total;
        _barData = weekly;
        _barLabels = ["W1", "W2", "W3", "W4"];
        _loading = false;
      });
    } else {
      final categories = await _statService.getStatsForYear(
        uid: uid,
        year: currentDate.year,
        isExpense: isExpense,
      );
      final monthly = await _statService.getMonthlyTotals(
        uid: uid,
        year: currentDate.year,
        isExpense: isExpense,
      );
      final total =
      categories.fold<double>(0, (sum, item) => sum + item.amount);

      setState(() {
        _activeData = categories;
        _totalAmount = total;
        _barData = monthly;
        _barLabels = [
          "J",
          "F",
          "M",
          "A",
          "M",
          "J",
          "J",
          "A",
          "S",
          "O",
          "N",
          "D"
        ];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color yellowColor = const Color(0xFFFFF78A);
    Color peachColor = const Color(0xFFF6A987);

    List<StatData> activeData = _activeData;
    double totalAmount = _totalAmount;

    String dateText = viewMode == "Monthly"
        ? DateFormat('MMMM yyyy', 'id_ID').format(currentDate)
        : DateFormat('yyyy', 'id_ID').format(currentDate);

    return Scaffold(
      backgroundColor: yellowColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
          const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Statistics",
          style: GoogleFonts.poppins(
              color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _changeDate(-1),
                  icon: const Icon(Icons.chevron_left,
                      size: 28, color: Colors.black54),
                ),
                Text(
                  dateText,
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                IconButton(
                  onPressed: () => _changeDate(1),
                  icon: const Icon(Icons.chevron_right,
                      size: 28, color: Colors.black54),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 35,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: viewMode,
                      icon: const Icon(Icons.arrow_drop_down,
                          color: Colors.black54),
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                      items: const [
                        DropdownMenuItem(
                            value: "Monthly", child: Text("M")),
                        DropdownMenuItem(
                            value: "Yearly", child: Text("Y")),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() => viewMode = newValue);
                          _loadStats();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                child: _loading
                    ? SizedBox(
                  height: 260,
                  child: Center(
                    child:
                    CircularProgressIndicator(),
                  ),
                )
                    : Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      margin:
                      const EdgeInsets.symmetric(
                          horizontal: 20),
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
                          StatPieChart(
                            data: activeData,
                            totalAmount: totalAmount,
                            isExpense: isExpense,
                          ),
                          const SizedBox(height: 30),
                          const Divider(),
                          const SizedBox(height: 20),
                          StatBarChart(
                            isExpense: isExpense,
                            viewMode: viewMode,
                            barData: _barData,
                            labels: _barLabels,
                          ),
                          const SizedBox(height: 30),
                          const Divider(),
                          const SizedBox(height: 20),
                          StatCategoryList(
                            data: activeData,
                            totalAmount: totalAmount,
                            isExpense: isExpense,
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
        GoogleFonts.poppins(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.account_balance_wallet_outlined),
              label: "Wallet"),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: "Statistics"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool targetIsExpense) {
    bool isActive = (isExpense == targetIsExpense);
    return GestureDetector(
      onTap: () {
        if (isExpense == targetIsExpense) return;
        setState(() => isExpense = targetIsExpense);
        _loadStats();
      },
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2E7D32)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (isActive)
              Icon(
                  targetIsExpense
                      ? Icons.money_off
                      : Icons.attach_money,
                  size: 16,
                  color: const Color(0xFFFFEB3B)),
            if (isActive) const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color:
                isActive ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
