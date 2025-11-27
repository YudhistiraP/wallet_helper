import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'wallet_balance_card.dart';
import 'currency_service.dart'; // Import Service API
import '../statistic_pages/statistics_page.dart';
import '../settings_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // Data Saldo (Base: IDR)
  WalletData _currentData = WalletData(
    totalBalance: 15450000.0,
    income: 20000000.0,
    expenses: 4550000.0,
    isBalanceHidden: false,
  );

  // State Mata Uang
  String _selectedCurrencyCode = 'IDR';
  double _currentExchangeRate = 1.0; // Default 1:1 (IDR)
  Map<String, double> _exchangeRates = {}; // Cache rate
  bool _isLoadingRates = true;

  int _currentIndex = 1;

  // Daftar Mata Uang yang didukung
  final List<Map<String, String>> _currencies = [
    {'code': 'IDR', 'name': 'Indonesian Rupiah', 'symbol': 'Rp', 'flag': '🇮🇩'},
    {'code': 'USD', 'name': 'United States Dollar', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥', 'flag': '🇯🇵'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  // Ambil Data API Sekali Saja
  void _fetchExchangeRates() async {
    final rates = await CurrencyService().getAllRates();
    if (mounted) {
      setState(() {
        _exchangeRates = rates;
        _isLoadingRates = false;
      });
    }
  }

  // Ganti Mata Uang
  void _changeCurrency(String code) {
    setState(() {
      _selectedCurrencyCode = code;
      // Ambil rate dari cache map, jika tidak ada default ke 1.0
      _currentExchangeRate = _exchangeRates[code] ?? 1.0;
    });
  }

  void _toggleVisibility() {
    setState(() {
      _currentData = WalletData(
        totalBalance: _currentData.totalBalance,
        income: _currentData.income,
        expenses: _currentData.expenses,
        isBalanceHidden: !_currentData.isBalanceHidden,
      );
    });
  }

  void _onNavBarTap(int index) {
    if (index == 1) return;
    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const StatisticsPage()))
          .then((_) => setState(() => _currentIndex = 1));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()))
          .then((_) => setState(() => _currentIndex = 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cari simbol mata uang yang aktif
    String activeSymbol = _currencies.firstWhere((c) => c['code'] == _selectedCurrencyCode)['symbol']!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFF99), // Kuning

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My Wallet",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // --- 1. KARTU SALDO (LIVE CONVERT) ---
            WalletBalanceCard(
              data: _currentData,
              onToggleVisibility: _toggleVisibility,
              currencyCode: _selectedCurrencyCode,
              currencySymbol: activeSymbol,
              exchangeRate: _currentExchangeRate,
            ),

            // --- 2. LIST MATA UANG (CONTAINER PUTIH/PEACH BAWAH) ---
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6A987), // Peach Background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
                      child: Text(
                        "Select Currency",
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white // Text Putih agar kontras di Peach
                        ),
                      ),
                    ),

                    // List Currency
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white, // Kotak Putih List
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: _isLoadingRates
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.separated(
                          padding: const EdgeInsets.all(10),
                          itemCount: _currencies.length,
                          separatorBuilder: (ctx, i) => const Divider(indent: 70),
                          itemBuilder: (context, index) {
                            final item = _currencies[index];
                            final bool isSelected = item['code'] == _selectedCurrencyCode;

                            return ListTile(
                              onTap: () => _changeCurrency(item['code']!),
                              leading: Container(
                                width: 50,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  item['flag']!,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                              title: Text(
                                item['code']!,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                item['name']!,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.circle_outlined, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavBarTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistics"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }
}