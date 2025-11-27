import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FontService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  /// Ambil ukuran font user dari Firestore
  static Future<String> getFontSize() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('user')
          .get();

      return doc['fontSize'] ?? "Medium";
    } catch (e) {
      print("FontService error: $e");
      return "Medium";
    }
  }


  /// Simpan ukuran font ke Firestore
  static Future<void> saveFontSize(String size) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection("users").doc(user.uid).set({
      "fontSize": size,
    }, SetOptions(merge: true));
  }
}
