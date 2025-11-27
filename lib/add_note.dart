import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'calculator_keyboard.dart';
import 'category_grid.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  bool isExpense = true;
  DateTime selectedDate = DateTime.now();
  String? selectedCategory;
  final TextEditingController noteController = TextEditingController();

  String _display = "0";
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  final List<Map<String, dynamic>> expenseCategories = [
    {'icon': Icons.fastfood, 'name': 'Food', 'color': Colors.redAccent},
    {'icon': Icons.directions_car, 'name': 'Transport', 'color': Colors.blueAccent},
    {'icon': Icons.checkroom, 'name': 'Clothes', 'color': Colors.purple},
    {'icon': Icons.face_retouching_natural, 'name': 'Beauty', 'color': Colors.pink},
    {'icon': Icons.school, 'name': 'Education', 'color': Colors.orange},
    {'icon': Icons.medical_services, 'name': 'Medical', 'color': Colors.green},
    {'icon': Icons.pets, 'name': 'Pets', 'color': Colors.brown},
    {'icon': Icons.child_friendly, 'name': 'Baby', 'color': Colors.teal},
    {'icon': Icons.receipt_long, 'name': 'Tax', 'color': Colors.grey},
    {'icon': Icons.flight, 'name': 'Travel', 'color': Colors.lightBlue},
    {'icon': Icons.people, 'name': 'Social', 'color': Colors.indigo},
    {'icon': Icons.sports_esports, 'name': 'Games', 'color': Colors.deepPurple},
  ];

  final List<Map<String, dynamic>> incomeCategories = [
    {'icon': Icons.account_balance_wallet, 'name': 'Salary', 'color': Colors.green},
    {'icon': Icons.card_giftcard, 'name': 'Bonus', 'color': Colors.orange},
    {'icon': Icons.show_chart, 'name': 'Invest', 'color': Colors.blue},
    {'icon': Icons.storefront, 'name': 'Business', 'color': Colors.purple},
    {'icon': Icons.laptop_mac, 'name': 'Freelance', 'color': Colors.redAccent},
    {'icon': Icons.attach_money, 'name': 'Other', 'color': Colors.grey},
  ];

  void _onKeyTap(String value) {
    setState(() {
      if ("0123456789.".contains(value)) {
        if (_shouldResetDisplay) {
          _display = value;
          _shouldResetDisplay = false;
        } else {
          if (_display == "0" && value != ".") {
            _display = value;
          } else {
            if (value == "." && _display.contains(".")) return;
            _display += value;
          }
        }
      } else if ("+-x÷".contains(value)) {
        if (_firstOperand == null) {
          _firstOperand = double.tryParse(_display.replaceAll('.', '').replaceAll(',', '.'));
          if(_firstOperand == null) _firstOperand = double.tryParse(_display.replaceAll(',', ''));
        } else if (_operator != null && !_shouldResetDisplay) {
          _calculateResult();
        }
        _operator = value;
        _display = "0";
        _shouldResetDisplay = true;
      } else if (value == "=") {
        if (_firstOperand != null && _operator != null) {
          _calculateResult();
          _operator = null;
          _firstOperand = null;
          _shouldResetDisplay = true;
        }
      } else if (value == "C") {
        _display = "0";
        _firstOperand = null;
        _operator = null;
        _shouldResetDisplay = false;
      } else if (value == "DEL") {
        if (_display.length > 1) {
          _display = _display.substring(0, _display.length - 1);
        } else {
          _display = "0";
        }
      }
    });
  }

  void _calculateResult() {
    if (_firstOperand == null || _operator == null) return;

    double secondOperand = double.tryParse(_display.replaceAll(',', '')) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+': result = _firstOperand! + secondOperand; break;
      case '-': result = _firstOperand! - secondOperand; break;
      case 'x': result = _firstOperand! * secondOperand; break;
      case '÷': result = _firstOperand! / secondOperand; break;
    }

    if (result % 1 == 0) {
      _display = result.toInt().toString();
    } else {
      _display = result.toString();
    }
    _firstOperand = result;
  }

  String _getEquationText() {
    if (_firstOperand == null || _operator == null) return "";
    String formattedNum = NumberFormat("#,##0", "id_ID").format(_firstOperand);
    return "$formattedNum $_operator";
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF6A987),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    Color yellowColor = const Color(0xFFFFF78A);
    Color peachColor = const Color(0xFFF6A987);

    Color yellowCalc = const Color(0xFFFFF098);
    Color orangeAccent = const Color(0xFFFFA588);

    List<Map<String, dynamic>> activeCategories = isExpense ? expenseCategories : incomeCategories;

    return Scaffold(
      backgroundColor: yellowColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: peachColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
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
                      child: CategoryGrid(
                        categories: activeCategories,
                        selectedCategory: selectedCategory,
                        onCategorySelected: (categoryName) {
                          setState(() {
                            selectedCategory = categoryName;
                          });
                        },
                      ),
                    ),

                    Container(
                      decoration: BoxDecoration(
                        color: yellowCalc,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.close, size: 28),
                                  onPressed: () => Navigator.pop(context),
                                ),

                                GestureDetector(
                                  onTap: _pickDate,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: orangeAccent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      DateFormat('d MMM').format(selectedDate),
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),

                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: orangeAccent,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 50,
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: TextField(
                                        controller: noteController,
                                        decoration: InputDecoration(
                                          hintText: "Note",
                                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: GoogleFonts.poppins(fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),
                                const Icon(Icons.credit_card, size: 28),
                                const SizedBox(width: 12),

                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _getEquationText(),
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black38,
                                        ),
                                      ),
                                      Text(
                                        NumberFormat("#,##0", "id_ID").format(double.tryParse(_display) ?? 0),
                                        textAlign: TextAlign.right,
                                        style: GoogleFonts.poppins(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          CalculatorKeyboard(
                            onKeyTap: _onKeyTap,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool targetIsExpense) {
    bool isActive = (isExpense == targetIsExpense);
    return GestureDetector(
      onTap: () => setState(() {
        isExpense = targetIsExpense;
        selectedCategory = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2E7D32) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (isActive)
              Icon(
                  targetIsExpense ? Icons.money_off : Icons.attach_money,
                  size: 16,
                  color: const Color(0xFFFFEB3B)
              ),
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