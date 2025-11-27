import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'wallet_balance_card.dart';
import 'currency_service.dart';
import '../statistic_pages/statistics_page.dart';
import '../settings_page.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  // Firestore refs
  late String _uid;
  late DocumentReference _walletDoc;

  // Visibility toggle only (balance values come from Firestore)
  bool _isBalanceHidden = false;

  // Currency state
  String _selectedCurrencyCode = 'IDR';
  double _currentExchangeRate = 1.0;
  Map<String, double> _exchangeRates = {};
  bool _isLoadingRates = true;

  int _currentIndex = 1;

  // Supported currencies
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
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _walletDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_uid)
        .collection('meta')
        .doc('wallet');

    _initWalletIfNeeded();
    _fetchExchangeRates();
  }

  Future<void> _initWalletIfNeeded() async {
    final snap = await _walletDoc.get();
    if (!snap.exists) {
      await _walletDoc.set({
        'balance': 0,
        'income': 0,
        'expenses': 0,
        'currency': 'IDR',
        'updated': Timestamp.now(),
      });
    }
  }

  // Fetch exchange rates once
  void _fetchExchangeRates() async {
    final rates = await CurrencyService().getAllRates();
    if (mounted) {
      setState(() {
        _exchangeRates = rates;
        _isLoadingRates = false;
      });
    }
  }

  // Change currency & persist
  void _changeCurrency(String code) async {
    setState(() {
      _selectedCurrencyCode = code;
      _currentExchangeRate = _exchangeRates[code] ?? 1.0;
    });

    await _walletDoc.update({
      'currency': code,
      'updated': Timestamp.now(),
    });
  }

  void _toggleVisibility() {
    setState(() => _isBalanceHidden = !_isBalanceHidden);
  }

  void _onNavBarTap(int index) {
    if (index == 1) return;

    if (index == 0) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsPage()))
          .then((_) => setState(() => _currentIndex = 1));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()))
          .then((_) => setState(() => _currentIndex = 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    String activeSymbol =
    _currencies.firstWhere((c) => c['code'] == _selectedCurrencyCode)['symbol']!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFF99),

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
            // === WALLET CARD FROM FIRESTORE ===
            StreamBuilder<DocumentSnapshot>(
              stream: _walletDoc.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  );
                }

                final d = snapshot.data!;
                final balance = (d['balance'] ?? 0).toDouble();
                final income = (d['income'] ?? 0).toDouble();
                final expenses = (d['expenses'] ?? 0).toDouble();
                final savedCurrency = d['currency'] ?? 'IDR';

                if (_selectedCurrencyCode != savedCurrency) {
                  _selectedCurrencyCode = savedCurrency;
                  _currentExchangeRate = _exchangeRates[savedCurrency] ?? 1.0;
                }

                final data = WalletData(
                  totalBalance: balance,
                  income: income,
                  expenses: expenses,
                  isBalanceHidden: _isBalanceHidden,
                );

                return WalletBalanceCard(
                  data: data,
                  onToggleVisibility: _toggleVisibility,
                  currencyCode: _selectedCurrencyCode,
                  currencySymbol: activeSymbol,
                  exchangeRate: _currentExchangeRate,
                );
              },
            ),

            // === CURRENCY LIST ===
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6A987),
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
                          color: Colors.white,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
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
                          separatorBuilder: (ctx, i) =>
                          const Divider(indent: 70),
                          itemBuilder: (context, index) {
                            final item = _currencies[index];
                            final bool isSelected =
                                item['code'] == _selectedCurrencyCode;

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
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                item['name']!,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.grey),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle,
                                  color: Colors.green)
                                  : const Icon(Icons.circle_outlined,
                                  color: Colors.grey),
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
        selectedLabelStyle:
        GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: "Wallet"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Statistics"),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
    );
  }
}