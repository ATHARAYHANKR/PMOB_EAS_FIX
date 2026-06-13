import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  static const Color _purple = Color(0xFFBB2BCD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── App Bar ───────────────────────────────
              _buildAppBar(),
              const SizedBox(height: 20),

              // ── Greeting + Avatar ─────────────────────
              _buildGreeting(),
              const SizedBox(height: 20),

              // ── Stat Cards 2x2 ─────────────────────────
              _buildStatGrid(),
              const SizedBox(height: 20),

              // ── Order Terbaru ──────────────────────────
              _buildSectionCard(
                title: 'Order Terbaru',
                actionLabel: 'Lihat semua',
                onAction: () {},
                child: Column(
                  children: _buildRecentOrders(),
                ),
              ),
              const SizedBox(height: 16),

              // ── Daftar Staff ───────────────────────────
              _buildSectionCard(
                title: 'Daftar Staff',
                actionLabel: 'Kelola',
                onAction: () {},
                child: Column(
                  children: _buildStaffList(),
                ),
              ),
              const SizedBox(height: 20),

              // ── Menu Cepat ─────────────────────────────
              Text('Menu Cepat',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 12),
              _buildQuickMenu(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Row(
      children: [
        const Icon(Icons.menu_rounded, size: 26, color: Colors.black87),
        const Spacer(),
        Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: _purple, size: 22),
            const SizedBox(width: 6),
            Text('CleanGo',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _purple,
                )),
          ],
        ),
        const Spacer(),
        Stack(
          children: [
            const Icon(Icons.notifications_outlined,
                size: 26, color: Colors.black87),
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
    );
  }

  // ── Greeting + Avatar ────────────────────────────────────────
  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Halo,',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.black54,
                  )),
              Text('Asa Owner!',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  )),
              const SizedBox(height: 2),
              Text('Selamat datang di dashboard',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black45,
                  )),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: _purple,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('A',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              )),
        ),
      ],
    );
  }

  // ── Stat Grid 2x2 ──────────────────────────────────────────
  Widget _buildStatGrid() {
    final totalOrder = OrderRepository.all.length;
    final aktif = OrderRepository.all
        .where((o) => o.status != OrderStatus.selesai)
        .length;
    final selesai = OrderRepository.countByStatus(OrderStatus.selesai);

    final stats = [
      _StatItem(
        icon: Icons.inventory_2_rounded,
        iconBg: const Color(0xFFFFF3E0),
        iconColor: const Color(0xFFFF8C00),
        label: 'Total Order',
        value: '$totalOrder',
        valueColor: Colors.black87,
      ),
      _StatItem(
        icon: Icons.sync_rounded,
        iconBg: const Color(0xFFE3F2FD),
        iconColor: const Color(0xFF1565C0),
        label: 'Aktif',
        value: '$aktif',
        valueColor: const Color(0xFF1565C0),
      ),
      _StatItem(
        icon: Icons.check_circle_rounded,
        iconBg: const Color(0xFFE8F5E9),
        iconColor: const Color(0xFF2E7D32),
        label: 'Selesai',
        value: '$selesai',
        valueColor: const Color(0xFF2E7D32),
      ),
      _StatItem(
        icon: Icons.monetization_on_rounded,
        iconBg: const Color(0xFFFFF8E1),
        iconColor: const Color(0xFFF9A825),
        label: 'Total Omzet',
        value: 'Rp 24.000',
        valueColor: _purple,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
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
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.black45,
              )),
          const SizedBox(height: 2),
          Text(item.value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: item.valueColor,
              )),
        ],
      ),
    );
  }

  // ── Generic Section Card ────────────────────────────────────
  Widget _buildSectionCard({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              GestureDetector(
                onTap: onAction,
                child: Text(actionLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: _purple,
                      fontWeight: FontWeight.w600,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  // ── Recent Orders ────────────────────────────────────────────
  List<Widget> _buildRecentOrders() {
    final recents = OrderRepository.all.take(2).toList();
    return recents
        .map((o) => _buildOrderRow(o))
        .toList();
  }

  Widget _buildOrderRow(OrderModel order) {
    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    switch (order.status) {
      case OrderStatus.diproses:
        badgeBg = const Color(0xFFEDD6FF);
        badgeFg = const Color(0xFF6A1F9F);
        badgeLabel = 'Dijemput';
        break;
      case OrderStatus.selesai:
        badgeBg = const Color(0xFFE8F5E9);
        badgeFg = const Color(0xFF2E7D32);
        badgeLabel = 'Selesai';
        break;
      case OrderStatus.perluTimbang:
        badgeBg = const Color(0xFFFFF9C4);
        badgeFg = const Color(0xFF795548);
        badgeLabel = 'Disetrika';
        break;
      case OrderStatus.konfirmasiBayar:
        badgeBg = const Color(0xFFE3F2FD);
        badgeFg = const Color(0xFF1565C0);
        badgeLabel = 'Dikirim';
        break;
      default:
        badgeBg = const Color(0xFFFFF3E0);
        badgeFg = const Color(0xFFFF8C00);
        badgeLabel = 'Masuk';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 2),
                Text('${order.customerName} Cust',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black45,
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badgeLabel,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badgeFg,
                )),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 18, color: Colors.black26),
        ],
      ),
    );
  }

  // ── Staff List ───────────────────────────────────────────────
  List<Widget> _buildStaffList() {
    final staffs = [
      _StaffItem(name: 'Karimah Staff', role: 'staff', active: true),
    ];

    return staffs.map((s) {
      return Container(
        margin: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(s.name.substring(0, 1),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2E7D32),
                  )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.name,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                  Text(s.role,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black45,
                      )),
                ],
              ),
            ),
            if (s.active)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Aktif',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2E7D32),
                    )),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: Colors.black26),
          ],
        ),
      );
    }).toList();
  }

  // ── Menu Cepat 2x3 ─────────────────────────────────────────
  Widget _buildQuickMenu(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.list_alt_rounded,
        label: 'Semua Order',
        bg: const Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
      _MenuItem(
        icon: Icons.sell_rounded,
        label: 'Katalog Harga',
        bg: const Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
      _MenuItem(
        icon: Icons.room_service_rounded,
        label: 'Jenis Layanan',
        bg: const Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
      _MenuItem(
        icon: Icons.groups_rounded,
        label: 'Manajemen Staff',
        bg: const Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
      _MenuItem(
        icon: Icons.description_rounded,
        label: 'Invoice',
        bg: const Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
      _MenuItem(
        icon: Icons.bar_chart_rounded,
        label: 'Laporan',
        bg: const Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
    ];

    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.95,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return GestureDetector(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.bg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, color: item.iconColor, size: 20),
                ),
                const SizedBox(height: 8),
                Text(item.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatItem {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  const _StatItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
  });
}

class _StaffItem {
  final String name;
  final String role;
  final bool active;
  const _StaffItem({
    required this.name,
    required this.role,
    required this.active,
  });
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color bg;
  final Color iconColor;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.bg,
    required this.iconColor,
  });
}
