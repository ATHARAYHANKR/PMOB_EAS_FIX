import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/order_model.dart';

class AppColors {
  static const primary = Color(0xFF2E7D32); // dark green
  static const primaryLight = Color(0xFF4CAF50); // medium green
  static const bgPage = Color(0xFFF5F6FA);
  static const bgCard = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF1A1A2E);
  static const textGrey = Color(0xFF9E9E9E);
  static const orange = Color(0xFFFF8C42);
  static const blue = Color(0xFF1E88E5);
  static const statusGreen = Color(0xFF43A047);
  static const statusBlue = Color(0xFF1E88E5);
  static const statusOrange = Color(0xFFFB8C00);
}

/// Konfigurasi warna badge status, dipusatkan di sini agar konsisten
/// di semua halaman staff (Dashboard, Order Masuk, Kelola Order,
/// Konfirmasi Bayar, dsb).
class StatusBadgeConfig {
  final Color bg;
  final Color fg;
  final IconData icon;
  const StatusBadgeConfig(
      {required this.bg, required this.fg, required this.icon});

  static StatusBadgeConfig of(OrderStatus status) {
    switch (status) {
      case OrderStatus.masuk:
        return const StatusBadgeConfig(
          bg: Color(0xFFFFF3E0),
          fg: AppColors.orange,
          icon: Icons.inventory_2_rounded,
        );
      case OrderStatus.dijemput:
        return const StatusBadgeConfig(
          bg: Color(0xFFD6EEFF),
          fg: Color(0xFF1565C0),
          icon: Icons.delivery_dining_rounded,
        );
      case OrderStatus.perluTimbang:
        return const StatusBadgeConfig(
          bg: Color(0xFFFFF9C4),
          fg: Color(0xFF795548),
          icon: Icons.balance_rounded,
        );
      case OrderStatus.dicuci:
        return const StatusBadgeConfig(
          bg: Color(0xFFB2DFDB),
          fg: Color(0xFF00695C),
          icon: Icons.local_laundry_service_rounded,
        );
      case OrderStatus.disetrika:
        return const StatusBadgeConfig(
          bg: Color(0xFFD6F5F0),
          fg: Color(0xFF00897B),
          icon: Icons.dry_cleaning_rounded,
        );
      case OrderStatus.dikirim:
        return const StatusBadgeConfig(
          bg: Color(0xFFE3F2FD),
          fg: Color(0xFF1565C0),
          icon: Icons.local_shipping_rounded,
        );
      case OrderStatus.konfirmasiBayar:
        return const StatusBadgeConfig(
          bg: Color(0xFFEDD6FF),
          fg: Color(0xFF6A1F9F),
          icon: Icons.payments_rounded,
        );
      case OrderStatus.selesai:
        return const StatusBadgeConfig(
          bg: Color(0xFFE8F5E9),
          fg: AppColors.primary,
          icon: Icons.check_circle_rounded,
        );
      case OrderStatus.dibatalkan:
        return const StatusBadgeConfig(
          bg: Color(0xFFFFEBEE),
          fg: Color(0xFFC62828),
          icon: Icons.cancel_rounded,
        );
    }
  }
}

/// Chip kecil untuk menampilkan status order, dipakai di seluruh
/// halaman staff agar warna & ikon status selalu konsisten.
class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final String? labelOverride;
  const StatusBadge({super.key, required this.status, this.labelOverride});

  @override
  Widget build(BuildContext context) {
    final cfg = StatusBadgeConfig.of(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: 13, color: cfg.fg),
          const SizedBox(width: 4),
          Text(
            labelOverride ?? status.statusLabel,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cfg.fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header halaman staff yang konsisten: judul besar + subjudul opsional,
/// dengan padding seragam di seluruh halaman staff.
class StaffPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const StaffPageHeader(
      {super.key, required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Kartu kosong (empty state) yang konsisten untuk seluruh halaman staff.
class StaffEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const StaffEmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F2F5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFFBDBDBD)),
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card putih dengan shadow & border konsisten, dipakai sebagai
/// pembungkus untuk order card di seluruh halaman staff.
class StaffCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  const StaffCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: card,
    );
  }
}
