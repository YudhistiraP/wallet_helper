import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  // Base URL (IDR sebagai patokan)
  final String apiUrl = "https://api.exchangerate-api.com/v4/latest/IDR";

  // Mengambil semua rate yang dibutuhkan sekaligus
  Future<Map<String, double>> getAllRates() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'];

        // Kembalikan Map berisi rate mata uang yang kita dukung
        return {
          'IDR': 1.0,
          'USD': (rates['USD'] as num).toDouble(),
          'GBP': (rates['GBP'] as num).toDouble(),
          'EUR': (rates['EUR'] as num).toDouble(),
          'JPY': (rates['JPY'] as num).toDouble(),
        };
      } else {
        throw Exception("Gagal load rate");
      }
    } catch (e) {
      print("Error API: $e");
      // Fallback rates jika offline/error (Estimasi kasar agar app tidak crash)
      return {
        'IDR': 1.0,
        'USD': 0.000064,
        'GBP': 0.000051,
        'EUR': 0.000059,
        'JPY': 0.0096,
      };
    }
  }
}