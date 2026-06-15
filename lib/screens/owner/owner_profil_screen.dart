import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';

class OwnerProfilScreen extends StatelessWidget {
  const OwnerProfilScreen({super.key});

  static const Color _purple = Color(0xFFBB2BCD);
  static const Color _purpleLight = Color(0xFFF3E5F5);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textGrey = Color(0xFF9E9E9E);

  String _displayName() {
    final user = FirestoreService.currentUser;
    final name = user?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) return name;
    return 'Pemilik CleanGo';
  }

  String _displayPhone() {
    final user = FirestoreService.currentUser;
    final phone = user?['phone']?.toString().trim();
    return (phone != null && phone.isNotEmpty) ? phone : '+62 821 9876 5432';
  }

  String _displayEmail() {
    final user = FirestoreService.currentUser;
    final email = user?['email']?.toString().trim();
    return (email != null && email.isNotEmpty) ? email : 'owner@cleango.id';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header / Avatar ──────────────────────────────
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _purpleLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: _purple, width: 2.5),
                      ),
                      child: const Icon(Icons.person_rounded,
                          size: 48, color: _purple),
                    ),
                    const SizedBox(height: 12),
                    Text(_displayName(),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        )),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: _purpleLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('Owner',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _purple,
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Informasi Akun ───────────────────────────────
              _section(
                title: 'Informasi Akun',
                items: [
                  _InfoItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Nama',
                      value: _displayName()),
                  _InfoItem(
                      icon: Icons.phone_outlined,
                      label: 'Telepon',
                      value: _displayPhone()),
                  _InfoItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _displayEmail()),
                  const _InfoItem(
                      icon: Icons.storefront_outlined,
                      label: 'Nama Usaha',
                      value: 'CleanGo Laundry'),
                  const _InfoItem(
                      icon: Icons.badge_outlined,
                      label: 'Role',
                      value: 'Owner / Pemilik'),
                ],
              ),
              const SizedBox(height: 12),

              // ── Pengaturan ───────────────────────────────────
              _sectionAction(
                title: 'Pengaturan',
                tiles: [
                  _ActionTile(
                    icon: Icons.lock_outline_rounded,
                    label: 'Ganti Password',
                    color: _purple,
                    onTap: () => _showComingSoon(context, 'Ganti Password'),
                  ),
                  _ActionTile(
                    icon: Icons.notifications_none_rounded,
                    label: 'Notifikasi',
                    color: _purple,
                    onTap: () => _showComingSoon(context, 'Notifikasi'),
                  ),
                  _ActionTile(
                    icon: Icons.help_outline_rounded,
                    label: 'Bantuan',
                    color: _purple,
                    onTap: () => _showComingSoon(context, 'Bantuan'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Keluar ───────────────────────────────────────
              _sectionAction(
                title: 'Akun',
                tiles: [
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    label: 'Keluar',
                    color: Colors.red,
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // App version
              Text('CleanGo v1.0.0',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: Colors.black26)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section({required String title, required List<_InfoItem> items}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                    letterSpacing: 0.5)),
          ),
          ...items.asMap().entries.map((e) => Column(
                children: [
                  _buildInfoTile(e.value),
                  if (e.key < items.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                ],
              )),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _sectionAction({
    required String title,
    required List<_ActionTile> tiles,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _textGrey,
                    letterSpacing: 0.5)),
          ),
          ...tiles.asMap().entries.map((e) => Column(
                children: [
                  _buildActionTile(e.value),
                  if (e.key < tiles.length - 1)
                    const Divider(height: 1, indent: 56, endIndent: 16),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildInfoTile(_InfoItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _purpleLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: _purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: _textGrey)),
                Text(item.value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(_ActionTile tile) {
    return ListTile(
      onTap: tile.onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tile.color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(tile.icon, size: 18, color: tile.color),
      ),
      title: Text(tile.label,
          style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: tile.color)),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 20, color: Colors.grey.shade400),
    );
  }

  void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Fitur "$label" akan segera tersedia',
          style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: _purple,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar',
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w700)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              FirestoreService.currentUser = null;
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Keluar',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(
      {required this.icon, required this.label, required this.value});
}

class _ActionTile {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionTile(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}
