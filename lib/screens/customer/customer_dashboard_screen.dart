import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'booking_laundry_screen.dart';
import 'detail_order_screen.dart';

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              const SizedBox(height: 20),
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildStatRow(),
              const SizedBox(height: 20),
              _buildBookingBaruButton(context),
              const SizedBox(height: 20),
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
                          color: _blue,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamOrdersForCurrentCustomer(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Gagal memuat order: ${snap.error}',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = snap.data ?? [];
                  var recents = all
                      .where((o) => o.status == OrderStatus.selesai)
                      .take(2)
                      .toList();
                  if (recents.isEmpty) {
                    recents = all.take(2).toList();
                  }
                  return Column(
                    children: recents
                        .map((o) => _buildOrderCard(context, o))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildPromoBanner(),
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
        // menu icon removed per request; keep title centered
        Expanded(
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.checkroom_rounded, color: _blue, size: 22),
                const SizedBox(width: 6),
                Text('CleanGo',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _blue,
                    )),
              ],
            ),
          ),
        ),
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
              Row(
                children: [
                  Text('${_displayName()}!',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      )),
                  const SizedBox(width: 6),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 2),
              Text('Selamat datang kembali di CleanGo',
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
            color: _blue,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(_displayInitial(),
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              )),
        ),
      ],
    );
  }

  // ── Stat Row 3 cards ────────────────────────────────────────
  Widget _buildStatRow() {
    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService.streamOrdersForCurrentCustomer(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDEDED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFF5C2C2)),
            ),
            child: Text(
              'Gagal memuat statistik: ${snap.error}',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          );
        }
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final all = snap.data ?? [];
        final aktif = all.where((o) => o.status != OrderStatus.selesai).length;
        final selesai =
            all.where((o) => o.status == OrderStatus.selesai).length;

        final stats = [
          _StatItem(
            icon: Icons.local_shipping_rounded,
            iconBg: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFF8C00),
            label: 'Order Aktif',
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
          const _StatItem(
            icon: Icons.monetization_on_rounded,
            iconBg: Color(0xFFFFF8E1),
            iconColor: Color(0xFFF9A825),
            label: 'Total Bayar',
            value: 'Rp 95.000',
            valueColor: _blue,
          ),
        ];

        return Row(
          children: stats.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
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
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(item.icon, color: item.iconColor, size: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(item.label,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.black45,
                        )),
                    const SizedBox(height: 4),
                    Text(item.value,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: item.valueColor,
                        )),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // ── Booking Baru Button ─────────────────────────────────────
  Widget _buildBookingBaruButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BookingLaundryScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _blue.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Booking Baru',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                )),
          ],
        ),
      ),
    );
  }

  // ── Recent Orders ────────────────────────────────────────────

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final dateStr =
        DateFormat('d MMM yyyy HH:mm', 'id').format(order.pickupDate);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.local_laundry_service_outlined,
                    color: Colors.black45, size: 20),
              ),
              const SizedBox(width: 12),
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
                    Text(order.serviceType,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        )),
                  ],
                ),
              ),
              Text(dateStr,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black45,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.circle, size: 8, color: Color(0xFF2E7D32)),
              const SizedBox(width: 6),
              Text('Selesai',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  )),
              const SizedBox(width: 14),
              Text('Lunas',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2E7D32),
                  )),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailOrderScreen(order: order)),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: _blue, width: 1.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Detail',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Promo Banner ─────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEFD),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kebersihan Maksimal, Hidup Lebih Nyaman',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _blue,
                    )),
                const SizedBox(height: 4),
                Text('Percayakan cucian Anda kepada kami.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.shopping_basket_rounded, color: _blue, size: 32),
          const SizedBox(width: 4),
          const Text('✨', style: TextStyle(fontSize: 18)),
        ],
      ),
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
