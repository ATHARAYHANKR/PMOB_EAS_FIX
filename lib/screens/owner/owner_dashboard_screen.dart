import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';

class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({super.key});

  static const Color _purple = Color(0xFFBB2BCD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting ──────────────────────────────
              Text('Halo, Asa',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 2),
              Text('Selamat datang kembali di CleanGo',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black45,
                  )),
              const SizedBox(height: 18),

              // ── Ringkasan card ─────────────────────────
              _buildRingkasanCard(),
              const SizedBox(height: 24),

              // ── Quick Action ───────────────────────────
              Text('Quick Action',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // ── Order Terbaru ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Terbaru',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Lihat semua',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _purple,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._buildRecentOrders(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Ringkasan hari ini card ───────────────────────────────
  Widget _buildRingkasanCard() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCC44DD), Color(0xFFDD77EE), Color(0xFFEEAAFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFBB2BCD).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Ringkasan Hari ini',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withAlpha(210),
                fontWeight: FontWeight.w500,
              )),
          Text('Rp. 4.500.000',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              )),
        ],
      ),
    );
  }

  // ── Quick Actions ─────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      const _QAItem(
        icon: Icons.menu_book_rounded,
        label: 'Kelola Katalog',
        subtitle: 'Kelola Layanan\nLaundry',
        bg: Color(0xFFF3E5F5),
        iconColor: _purple,
      ),
      const _QAItem(
        icon: Icons.person_rounded,
        label: 'Kelola Staff',
        subtitle: 'Kelola data staff &\nizin akses',
        bg: Color(0xFFE8F5E9),
        iconColor: Color(0xFF2E7D32),
      ),
      const _QAItem(
        icon: Icons.bar_chart_rounded,
        label: 'Laporan',
        subtitle: 'Lihat laporan &\nstatistik bisnis',
        bg: Color(0xFFFFF3E0),
        iconColor: Color(0xFFFF8C00),
      ),
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: EdgeInsets.only(
                right: actions.indexOf(a) < actions.length - 1 ? 10 : 0,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: a.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.icon, color: a.iconColor, size: 22),
                  ),
                  const SizedBox(height: 10),
                  Text(a.label,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 4),
                  Text(a.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.black45,
                        height: 1.4,
                      )),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 11, color: Colors.black38),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Recent Orders ─────────────────────────────────────────
  List<Widget> _buildRecentOrders() {
    final recents = OrderRepository.all.take(2).toList();
    return recents.map((o) => _buildOrderCard(o)).toList();
  }

  Widget _buildOrderCard(OrderModel order) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);

    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    switch (order.status) {
      case OrderStatus.diproses:
        badgeBg = const Color(0xFFE3F2FD);
        badgeFg = const Color(0xFF1565C0);
        badgeLabel = 'Diproses';
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
        badgeBg = const Color(0xFFEDD6FF);
        badgeFg = const Color(0xFF6A1F9F);
        badgeLabel = 'Dikirim';
        break;
      default:
        badgeBg = const Color(0xFFFFF3E0);
        badgeFg = const Color(0xFFFF8C00);
        badgeLabel = 'Masuk';
    }

    final beratStr = order.beratKg != null
        ? ' - ${order.beratKg!.toStringAsFixed(0)}kg'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          // Ikon laundry
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_laundry_service_outlined,
                color: Colors.black45, size: 22),
          ),
          const SizedBox(width: 12),
          // Info
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
                Text('${order.serviceType}$beratStr',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black45,
                    )),
                Text(dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black45,
                    )),
              ],
            ),
          ),
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
        ],
      ),
    );
  }
}

class _QAItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color bg;
  final Color iconColor;
  const _QAItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.bg,
    required this.iconColor,
  });
}
