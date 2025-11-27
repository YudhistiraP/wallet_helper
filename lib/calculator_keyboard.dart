import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculatorKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;

  const CalculatorKeyboard({
    super.key,
    required this.onKeyTap,
  });

  @override
  Widget build(BuildContext context) {
    Color orangeAccent = const Color(0xFFFFA588);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          _buildKeyRow(['C', 'x', '%', '÷'], orangeAccent),
          _buildKeyRow(['7', '8', '9', 'x'], orangeAccent),
          _buildKeyRow(['4', '5', '6', '-'], orangeAccent),
          _buildKeyRow(['1', '2', '3', '+'], orangeAccent),
          _buildKeyRow(['.', '0', 'DEL', '='], orangeAccent),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: keys.map((key) {
          Color btnColor = Colors.white;
          if (['÷', 'x', '-', '+', '='].contains(key)) btnColor = accentColor;
          if (['C', 'DEL', '%'].contains(key)) btnColor = const Color(0xFFD6D6D6);

          Widget content;
          if (key == 'DEL') {
            content = const Icon(Icons.backspace_outlined, size: 20);
          } else {
            content = Text(
              key,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: (key == '=') ? Colors.white : Colors.black,
              ),
            );
          }

          return SizedBox(
            width: 75,
            height: 55,
            child: ElevatedButton(
              onPressed: () => onKeyTap(key),
              style: ElevatedButton.styleFrom(
                backgroundColor: btnColor,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.zero,
              ),
              child: content,
            ),
          );
        }).toList(),
      ),
    );
  }
}
