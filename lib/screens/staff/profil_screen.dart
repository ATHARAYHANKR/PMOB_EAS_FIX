import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/login_screen.dart';
import '../../app_theme.dart';

class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.primaryLight.withAlpha(38),
                        child: const Icon(Icons.person_rounded,
                            size: 46, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Karimah Staff',
                        style: GoogleFonts.inter(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(46),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.badge_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('Staff Laundry',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info section
              _section(
                title: 'Informasi Akun',
                items: [
                  const _InfoItem(
                      icon: Icons.person_outline_rounded,
                      label: 'Username',
                      value: 'karimah_staff'),
                  const _InfoItem(
                      icon: Icons.phone_outlined,
                      label: 'Telepon',
                      value: '+62 812 3456 7890'),
                  const _InfoItem(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: 'karimah@cleango.id'),
                  const _InfoItem(
                      icon: Icons.badge_outlined,
                      label: 'Role',
                      value: 'Staff Laundry'),
                ],
              ),
              const SizedBox(height: 12),

              // Action section
              _actionSection(context),
              const SizedBox(height: 24),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(title,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey)),
          ),
          ...items.asMap().entries.map((e) {
            return Column(
              children: [
                _buildInfoTile(e.value),
                if (e.key < items.length - 1)
                  const Divider(height: 1, indent: 56, endIndent: 16),
              ],
            );
          }),
          const SizedBox(height: 4),
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
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppColors.textGrey)),
                Text(item.value,
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          _actionTile(
            icon: Icons.lock_outline_rounded,
            label: 'Ganti Password',
            color: AppColors.primary,
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          _actionTile(
            icon: Icons.logout_rounded,
            label: 'Keluar',
            color: Colors.red,
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
      title: Text(label,
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w600, color: color)),
      trailing: Icon(Icons.chevron_right_rounded,
          size: 20, color: Colors.grey.shade400),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal',
                style: GoogleFonts.inter(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () {
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
                    color: Colors.white, fontWeight: FontWeight.w600)),
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
