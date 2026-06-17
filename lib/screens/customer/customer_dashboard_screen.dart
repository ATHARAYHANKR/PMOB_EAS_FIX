import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'booking_laundry_screen.dart';
import 'customer_order_screen.dart';
import 'detail_order_screen.dart';

/// Palette dasbor customer - ditata ulang agar terasa lebih "produk"
/// (warna konsisten dengan brand CleanGo, tapi dengan hierarki yang
/// lebih jelas: hero gelap untuk status, surface terang untuk daftar).
class _DashColors {
  static const ink = Color(0xFF14213D); // hero / teks utama
  static const primary = Color(0xFF3B5BDB); // brand blue
  static const primarySoft = Color(0xFFE7ECFB);
  static const surface = Color(0xFFF6F7FB);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFEAEDF3);
  static const textMuted = Color(0xFF6B7280);
  static const success = Color(0xFF1F9D55);
  static const successSoft = Color(0xFFE3F6EA);
  static const amber = Color(0xFFC8821B);
  static const amberSoft = Color(0xFFFBF0DD);
  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFFBE7E5);
  static const neutral = Color(0xFF5B6472);
  static const neutralSoft = Color(0xFFEDEDF2);
}

class CustomerDashboardScreen extends StatelessWidget {
  const CustomerDashboardScreen({super.key});

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

  ({Color bg, Color fg, String label}) _statusStyle(OrderStatus status) {
    switch (status) {
      case OrderStatus.masuk:
        return (
          bg: _DashColors.neutralSoft,
          fg: _DashColors.neutral,
          label: status.stepTitle
        );
      case OrderStatus.dicuci:
        return (
          bg: _DashColors.primarySoft,
          fg: _DashColors.primary,
          label: 'Dicuci'
        );
      case OrderStatus.disetrika:
        return (
          bg: _DashColors.primarySoft,
          fg: _DashColors.primary,
          label: 'Disetrika'
        );
      case OrderStatus.dikirim:
        return (
          bg: _DashColors.neutralSoft,
          fg: _DashColors.primary,
          label: 'Dikirim'
        );
      case OrderStatus.dijemput:
        return (
          bg: _DashColors.primarySoft,
          fg: _DashColors.primary,
          label: 'Dijemput'
        );
      case OrderStatus.perluTimbang:
        return (
          bg: _DashColors.primarySoft,
          fg: _DashColors.primary,
          label: 'Perlu Timbang'
        );
      case OrderStatus.konfirmasiBayar:
        return (
          bg: _DashColors.amberSoft,
          fg: _DashColors.amber,
          label: 'Menunggu Pembayaran'
        );
      case OrderStatus.selesai:
        return (
          bg: _DashColors.successSoft,
          fg: _DashColors.success,
          label: 'Selesai'
        );
      case OrderStatus.dibatalkan:
        return (
          bg: _DashColors.dangerSoft,
          fg: _DashColors.danger,
          label: 'Dibatalkan'
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _DashColors.surface,
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: FirestoreService.streamOrdersForCurrentCustomer(),
          builder: (context, snap) {
            if (snap.hasError) {
              return _ErrorState(message: '${snap.error}');
            }
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = snap.data ?? [];
            final aktif = all
                .where((o) =>
                    o.status != OrderStatus.selesai &&
                    o.status != OrderStatus.dibatalkan)
                .toList();
            final selesaiCount =
                all.where((o) => o.status == OrderStatus.selesai).length;
            final totalBayar = all
                .where((o) => o.status == OrderStatus.selesai)
                .fold<double>(0, (sum, o) => sum + (o.totalHarga ?? 0));

            // Order yang menjadi sorotan: order aktif paling baru,
            // atau kalau tidak ada, order terakhir apa pun.
            final spotlight = aktif.isNotEmpty
                ? aktif.first
                : (all.isNotEmpty ? all.first : null);

            final recent = all.take(3).toList();

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildAppBar(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: _buildHero(context, spotlight, aktif.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child:
                        _buildStatRow(aktif.length, selesaiCount, totalBayar),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildBookingBaruButton(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _buildSectionHeader(context),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: recent.isEmpty
                        ? _buildEmptyOrders()
                        : Column(
                            children: recent
                                .map((o) => _buildOrderCard(context, o))
                                .toList(),
                          ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: _buildPromoBanner(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── App Bar ────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _DashColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.checkroom_rounded,
              color: Colors.white, size: 19),
        ),
        const SizedBox(width: 10),
        Text('CleanGo',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _DashColors.ink,
              letterSpacing: -0.3,
            )),
        const Spacer(),
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: _DashColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _DashColors.border),
          ),
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_outlined,
                  size: 19, color: _DashColors.ink),
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _DashColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(color: _DashColors.card, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Hero: greeting + status spotlight ───────────────────────
  Widget _buildHero(
      BuildContext context, OrderModel? spotlight, int aktifCount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _DashColors.ink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Halo, ${_displayName()}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      aktifCount > 0
                          ? 'Kamu punya $aktifCount cucian dalam proses'
                          : 'Semua cucianmu sudah selesai',
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: Colors.white.withAlpha(160),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withAlpha(40)),
                ),
                alignment: Alignment.center,
                child: Text(_displayInitial(),
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (spotlight != null)
            _buildSpotlightCard(context, spotlight)
          else
            _buildHeroEmptyCard(),
        ],
      ),
    );
  }

  Widget _buildSpotlightCard(BuildContext context, OrderModel order) {
    final style = _statusStyle(order.status);
    final isDone = order.status == OrderStatus.selesai;
    final isCancelled = order.status == OrderStatus.dibatalkan;
    final progress = isCancelled ? 0.0 : order.workflowProgress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(order.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(style.label,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: style.fg,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
              '${order.id} \u00b7 ${DateFormat('d MMM yyyy', 'id').format(order.pickupDate)}',
              style: GoogleFonts.inter(
                fontSize: 11.5,
                color: Colors.white.withAlpha(150),
              )),
          const SizedBox(height: 12),
          if (!isCancelled)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: isDone ? 1.0 : progress,
                minHeight: 6,
                backgroundColor: Colors.white.withAlpha(24),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDone
                      ? _DashColors.success
                      : _DashColors.primary.withAlpha(220),
                ),
              ),
            ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => DetailOrderScreen(order: order)),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Lihat detail',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                const Icon(Icons.arrow_forward_rounded,
                    color: Colors.white, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroEmptyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_laundry_service_outlined,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Belum ada order. Yuk, buat booking pertamamu!',
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: Colors.white.withAlpha(200),
                )),
          ),
        ],
      ),
    );
  }

  // ── Stat Row ─────────────────────────────────────────────────
  Widget _buildStatRow(int aktif, int selesai, double totalBayar) {
    final stats = [
      (
        icon: Icons.local_shipping_outlined,
        iconColor: _DashColors.primary,
        iconBg: _DashColors.primarySoft,
        label: 'Order aktif',
        value: '$aktif',
      ),
      (
        icon: Icons.check_circle_outline_rounded,
        iconColor: _DashColors.success,
        iconBg: _DashColors.successSoft,
        label: 'Selesai',
        value: '$selesai',
      ),
      (
        icon: Icons.payments_outlined,
        iconColor: _DashColors.amber,
        iconBg: _DashColors.amberSoft,
        label: 'Total bayar',
        value: 'Rp ${_formatRupiah(totalBayar)}',
      ),
    ];

    return Row(
      children: stats.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < stats.length - 1 ? 10 : 0),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: _DashColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _DashColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Icon(item.icon, color: item.iconColor, size: 15),
                ),
                const SizedBox(height: 10),
                Text(item.value,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _DashColors.ink,
                    )),
                const SizedBox(height: 2),
                Text(item.label,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: _DashColors.textMuted,
                    )),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _formatRupiah(double value) {
    final intVal = value.round();
    final s = intVal.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
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
          color: _DashColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Booking baru',
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

  // ── Section Header ───────────────────────────────────────────
  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Order terbaru',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _DashColors.ink,
            )),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomerOrderScreen()),
            );
          },
          child: Text('Lihat semua',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: _DashColors.primary,
                fontWeight: FontWeight.w600,
              )),
        ),
      ],
    );
  }

  Widget _buildEmptyOrders() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: _DashColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DashColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined,
              size: 28, color: _DashColors.textMuted),
          const SizedBox(height: 8),
          Text('Belum ada riwayat order',
              style: GoogleFonts.inter(
                fontSize: 12.5,
                color: _DashColors.textMuted,
              )),
        ],
      ),
    );
  }

  // ── Order Card ───────────────────────────────────────────────
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final dateStr = DateFormat('d MMM yyyy', 'id').format(order.pickupDate);
    final style = _statusStyle(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _DashColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _DashColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _DashColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_laundry_service_outlined,
                color: _DashColors.neutral, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: _DashColors.ink,
                    )),
                const SizedBox(height: 2),
                Text('${order.id} \u00b7 $dateStr',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: _DashColors.textMuted,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(style.label,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: style.fg,
                    )),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DetailOrderScreen(order: order)),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Detail',
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: _DashColors.primary,
                        )),
                    const SizedBox(width: 2),
                    const Icon(Icons.chevron_right_rounded,
                        size: 14, color: _DashColors.primary),
                  ],
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
        color: _DashColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_florist_outlined,
                color: _DashColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kebersihan maksimal, hidup lebih nyaman',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _DashColors.ink,
                    )),
                const SizedBox(height: 2),
                Text('Percayakan cucianmu kepada kami.',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: _DashColors.textMuted,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: _DashColors.danger, size: 32),
            const SizedBox(height: 8),
            Text(
              'Gagal memuat data: $message',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _DashColors.danger,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
