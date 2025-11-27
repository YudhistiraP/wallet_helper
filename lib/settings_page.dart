import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login_page.dart'; // Import Login Page untuk navigasi setelah logout
import 'wallet_pages/wallet_page.dart'; // Import Wallet Page
import 'statistic_pages/statistics_page.dart'; // Import Statistics Page
import 'service/font_service.dart';
import 'main.dart'; // untuk akses globalFontSize & getFontSize (jika diperlukan)


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // State untuk Bottom Nav (Index 3 adalah Settings)
  int _bottomNavIndex = 3;

  // Fungsi Logout
  Future<void> _logout() async {
    // 1. Tampilkan Dialog Konfirmasi
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to logout?", style: GoogleFonts.poppins()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: GoogleFonts.poppins(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Logout", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 2. Proses Logout Firebase
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // 3. Kembali ke Halaman Login (Hapus semua route sebelumnya)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
      );
    }
  }

  // Logika Navigasi Bottom Bar
  void _onBottomNavTap(int index) {
    if (index == 3) return; // Sedang di halaman ini

    if (index == 0) {
      // Kembali ke Home (Pop sampai awal)
      Navigator.popUntil(context, (route) => route.isFirst);
    } else if (index == 1) {
      // Navigasi ke Wallet
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WalletPage()),
      ).then((_) => setState(() => _bottomNavIndex = 3));
    } else if (index == 2) {
      // Ke Statistics
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const StatisticsPage()),
      ).then((_) => setState(() => _bottomNavIndex = 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    Color yellowColor = const Color(0xFFFFF78A);
    Color peachColor = const Color(0xFFF6A987);

    // Ambil User Data dari Firebase (Opsional)
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? "Ripia";
    final String email = user?.email ?? "user@example.com";

    return Scaffold(
      backgroundColor: yellowColor,

      // AppBar Transparan
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Settings",
          style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // --- 1. BAGIAN PROFIL (ATAS) ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                // Avatar dengan Icon Edit
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                        // Jika ada gambar: backgroundImage: NetworkImage(user.photoURL!),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  displayName,
                  style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                Text(
                  email,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          // --- 2. MENU LIST (BAWAH) ---
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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // GRUP: GENERAL
                    _buildSectionHeader("General"),
                    _buildMenuItem(Icons.text_fields, "Font Size", globalFontSize, onTap: _openFontDialog),
                    _buildMenuItem(Icons.location_on, "Bank Location", "730m"),
                    _buildMenuItem(Icons.account_balance_wallet, "My Wallet", "Connect your wallet"),

                    const SizedBox(height: 20),

                    // GRUP: ACCOUNT
                    _buildSectionHeader("Account"),
                    _buildMenuItem(Icons.person_outline, "My Account", ""),
                    _buildMenuItem(Icons.notifications_outlined, "Notification", ""),
                    _buildMenuItem(Icons.lock_outline, "Privacy", ""),
                    _buildMenuItem(Icons.info_outline, "About", ""),

                    const SizedBox(height: 30),

                    // TOMBOL LOGOUT
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Log Out",
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"), // Icon filled untuk active state
        ],
      ),
    );
  }

  // Widget Helper: Judul Section (General, Account)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  /// Widget Helper: Item Menu (Kotak Putih)
Widget _buildMenuItem(
  IconData icon,
  String title,
  String subtitle, {
  VoidCallback? onTap, // ← DITAMBAHKAN
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 5,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF78A).withOpacity(0.5), // Kuning transparan
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: subtitle.isNotEmpty
          ? Text(subtitle, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),

      onTap: onTap ?? () {}, // ← DITAMBAHKAN, aktifkan klik
    ),
  );
}


  void _openFontDialog() async {
  String? selected = await showMenu(
    context: context,
    position: const RelativeRect.fromLTRB(200, 200, 10, 10),
    items: const [
      PopupMenuItem(value: "Small", child: Text("Small")),
      PopupMenuItem(value: "Medium", child: Text("Medium")),
      PopupMenuItem(value: "Large", child: Text("Large")),
    ],
  );

  if (selected != null) {
    await FontService.saveFontSize(selected);

    setState(() {
      globalFontSize = selected;
    });

    // Refresh UI
    (context as Element).markNeedsBuild();
  }
}

}
