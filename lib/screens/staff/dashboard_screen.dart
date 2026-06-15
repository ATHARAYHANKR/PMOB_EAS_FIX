import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  final void Function(int index) onNavigate;
  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: FirestoreService.streamAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.redAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final orders = snapshot.data!;

            return CustomScrollView(
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
                    child: _buildStatGrid(orders),
                  ),
                ),
                // ── Aktivitas Terbaru ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildAktivitasTerbaru(context, orders),
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
            );
          },
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
          // Logo
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
          const Spacer(),
          // Shortcut ke Profil Saya
          GestureDetector(
            onTap: () => onNavigate(4),
            child: const Icon(Icons.person_outline_rounded,
                size: 26, color: AppColors.textDark),
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
  Widget _buildStatGrid(List<OrderModel> orders) {
    int countByStatus(OrderStatus s) =>
        orders.where((o) => o.status == s).length;

    final stats = [
      _StatItem(
        label: 'Order Masuk',
        count: countByStatus(OrderStatus.masuk),
        icon: Icons.inventory_2_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: AppColors.orange,
      ),
      _StatItem(
        label: 'Diambil',
        count: countByStatus(OrderStatus.diproses),
        icon: Icons.sync_rounded,
        iconBg: const Color(0xFFE3F2FD),
        iconColor: AppColors.blue,
      ),
      _StatItem(
        label: 'Perlu Timbang',
        count: countByStatus(OrderStatus.perluTimbang),
        icon: Icons.balance_outlined,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: AppColors.orange,
      ),
      _StatItem(
        label: 'Konfirmasi Bayar',
        count: countByStatus(OrderStatus.konfirmasiBayar),
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
  Widget _buildAktivitasTerbaru(BuildContext context, List<OrderModel> orders) {
    final recent = orders.take(3).toList();

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
              onTap: () => onNavigate(2),
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
          child: recent.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Belum ada aktivitas order',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                )
              : Column(
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
            child: const Icon(Icons.receipt_long_rounded,
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
          StatusBadge(status: order.status),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  MENU CEPAT  3×2
  // ──────────────────────────────────────────────────────────
  Widget _buildMenuCepat(BuildContext context) {
    final menus = [
      const _MenuItem(
          icon: Icons.inventory_2_rounded,
          label: 'Order Masuk',
          color: AppColors.orange,
          bg: Color(0xFFFFF3E0),
          targetIndex: 1),
      const _MenuItem(
          icon: Icons.list_alt_rounded,
          label: 'Kelola Order',
          color: AppColors.blue,
          bg: Color(0xFFE3F2FD),
          targetIndex: 2),
      const _MenuItem(
          icon: Icons.credit_card_rounded,
          label: 'Konfirmasi Bayar',
          color: Color(0xFF6A1F9F),
          bg: Color(0xFFF3E5F5),
          targetIndex: 3),
      const _MenuItem(
          icon: Icons.history_rounded,
          label: 'History Selesai',
          color: AppColors.primary,
          bg: Color(0xFFE8F5E9),
          targetIndex: 2),
      const _MenuItem(
          icon: Icons.person_rounded,
          label: 'Profil Saya',
          color: AppColors.primary,
          bg: Color(0xFFE8F5E9),
          targetIndex: 4),
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
      onTap: () => onNavigate(m.targetIndex),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: m.bg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(m.icon, color: m.color, size: 26),
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
  final int targetIndex;
  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg,
      required this.targetIndex});
}
