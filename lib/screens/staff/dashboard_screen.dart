import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top App Bar ───────────────────────────────
            SliverToBoxAdapter(child: _buildAppBar(context)),
            // ── Greeting ─────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildGreeting(),
              ),
            ),
            // ── Stat Cards ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: _buildStatGrid(),
              ),
            ),
            // ── Aktivitas Terbaru ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _buildAktivitasTerbaru(context),
              ),
            ),
            // ── Menu Cepat ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: _buildMenuCepat(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  APP BAR
  // ──────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Hamburger
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.menu_rounded,
                size: 26, color: AppColors.textDark),
          ),
          const Spacer(),
          // Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(31),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.dry_cleaning_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'CleanGo',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Notification bell
          Stack(
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 26, color: AppColors.textDark),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  GREETING
  // ──────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Halo,',
            style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w400)),
        Text('Karimah Staff!',
            style: GoogleFonts.inter(
                fontSize: 24,
                color: AppColors.textDark,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Selamat datang kembali di CleanGo',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey)),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────
  //  STAT GRID  2×2
  // ──────────────────────────────────────────────────────────
  Widget _buildStatGrid() {
    final stats = [
      _StatItem(
        label: 'Order Masuk',
        count: OrderRepository.countByStatus(OrderStatus.masuk),
        icon: Icons.inventory_2_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: AppColors.orange,
      ),
      _StatItem(
        label: 'Diproses',
        count: OrderRepository.countByStatus(OrderStatus.diproses),
        icon: Icons.sync_rounded,
        iconBg: const Color(0xFFE3F2FD),
        iconColor: AppColors.blue,
      ),
      _StatItem(
        label: 'Perlu Timbang',
        count: OrderRepository.countByStatus(OrderStatus.perluTimbang),
        icon: Icons.balance_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: AppColors.orange,
      ),
      _StatItem(
        label: 'Konfirmasi Bayar',
        count: OrderRepository.countByStatus(OrderStatus.konfirmasiBayar),
        icon: Icons.credit_card_outlined,
        iconBg: const Color(0xFFE3F2FD),
        iconColor: AppColors.blue,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: stats.map(_buildStatCard).toList(),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${item.count}',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.1,
                  ),
                ),
                Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  AKTIVITAS TERBARU
  // ──────────────────────────────────────────────────────────
  Widget _buildAktivitasTerbaru(BuildContext context) {
    final recent = OrderRepository.all.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terbaru',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Lihat semua',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: recent.asMap().entries.map((entry) {
              final i = entry.key;
              final order = entry.value;
              return Column(
                children: [
                  _buildAktivitasItem(order),
                  if (i < recent.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAktivitasItem(OrderModel order) {
    final dateStr =
        DateFormat('dd MMM yyyy, HH:mm', 'id').format(order.pickupDate);

    Color statusColor;
    Color statusBg;
    switch (order.status) {
      case OrderStatus.diproses:
        statusColor = AppColors.blue;
        statusBg = const Color(0xFFE3F2FD);
        break;
      case OrderStatus.masuk:
        statusColor = AppColors.orange;
        statusBg = const Color(0xFFFFF3E0);
        break;
      case OrderStatus.perluTimbang:
        statusColor = AppColors.orange;
        statusBg = const Color(0xFFFFF3E0);
        break;
      default:
        statusColor = AppColors.primary;
        statusBg = const Color(0xFFE8F5E9);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.sync_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  order.serviceType,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textGrey),
                ),
                Text(
                  dateStr,
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFFB0B0B0)),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  MENU CEPAT  3×2
  // ──────────────────────────────────────────────────────────
  Widget _buildMenuCepat(BuildContext context) {
    final menus = [
      _MenuItem(
          icon: Icons.inventory_2_rounded,
          label: 'Order Masuk',
          color: AppColors.orange,
          bg: const Color(0xFFFFF3E0),
          badge: 0),
      _MenuItem(
          icon: Icons.list_alt_rounded,
          label: 'Kelola Order',
          color: AppColors.blue,
          bg: const Color(0xFFE3F2FD),
          badge: 1),
      _MenuItem(
          icon: Icons.sync_rounded,
          label: 'Update Status',
          color: AppColors.primary,
          bg: const Color(0xFFE8F5E9),
          badge: 0),
      _MenuItem(
          icon: Icons.credit_card_rounded,
          label: 'Konfirmasi Bayar',
          color: AppColors.blue,
          bg: const Color(0xFFE3F2FD),
          badge: 0),
      _MenuItem(
          icon: Icons.history_rounded,
          label: 'History Selesai',
          color: const Color(0xFF7B1FA2),
          bg: const Color(0xFFF3E5F5),
          badge: 0),
      _MenuItem(
          icon: Icons.person_rounded,
          label: 'Profil Saya',
          color: AppColors.primary,
          bg: const Color(0xFFE8F5E9),
          badge: 0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Cepat',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.95,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: menus.map((m) => _buildMenuTile(context, m)).toList(),
        ),
      ],
    );
  }

  Widget _buildMenuTile(BuildContext context, _MenuItem m) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: m.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(m.icon, color: m.color, size: 26),
                ),
                if (m.badge > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${m.badge}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              m.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────
class _StatItem {
  final String label;
  final int count;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  const _StatItem(
      {required this.label,
      required this.count,
      required this.icon,
      required this.iconBg,
      required this.iconColor});
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final int badge;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      required this.badge});
}
