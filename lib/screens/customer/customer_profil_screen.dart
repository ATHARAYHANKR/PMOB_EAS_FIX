import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import 'customer_history_screen.dart';
import 'edit_customer_profile_screen.dart';

class CustomerProfilScreen extends StatelessWidget {
  const CustomerProfilScreen({super.key});

  static const Color _blue = Color(0xFF3B5BDB);

  String _displayName() {
    final user = FirestoreService.currentUser;
    final name = user?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    final email = user?['email']?.toString().trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Pengguna';
  }

  String _displayPhone() {
    final user = FirestoreService.currentUser;
    final phone = user?['phone']?.toString().trim();
    return (phone != null && phone.isNotEmpty) ? phone : 'Tidak ada nomor';
  }

  String _displayAddress() {
    final user = FirestoreService.currentUser;
    final address = user?['address']?.toString().trim();
    return (address != null && address.isNotEmpty)
        ? address
        : 'Tidak ada alamat';
  }

  String _displayInitial() {
    final name = _displayName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profil Saya',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 20),

              // ── Profile card ───────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: _blue,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(_displayInitial(),
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          )),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_displayName(),
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              )),
                          Text(_displayPhone(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.black45,
                              )),
                          const SizedBox(height: 6),
                          Text(_displayAddress(),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: Colors.black38,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildMenuItem(
                  context, Icons.location_on_outlined, 'Alamat Saya'),
              _buildMenuItem(context, Icons.history_rounded, 'Riwayat Order'),
              _buildMenuItem(
                  context, Icons.notifications_outlined, 'Notifikasi'),
              _buildMenuItem(context, Icons.help_outline_rounded, 'Bantuan'),
              _buildMenuItem(context, Icons.settings_outlined, 'Pengaturan'),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded,
                          size: 18, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Text('Keluar',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.redAccent,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _blue),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (label == 'Riwayat Order') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const CustomerHistoryScreen()));
                  return;
                }
                if (label == 'Alamat Saya') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditCustomerProfileScreen()));
                  return;
                }
              },
              child: Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  )),
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: Colors.black26),
        ],
      ),
    );
  }
}
