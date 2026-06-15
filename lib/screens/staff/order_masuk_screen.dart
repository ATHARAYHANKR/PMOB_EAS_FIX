import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'verifikasi_berat_screen.dart';

class OrderMasukScreen extends StatefulWidget {
  const OrderMasukScreen({super.key});

  @override
  State<OrderMasukScreen> createState() => _OrderMasukScreenState();
}

class _OrderMasukScreenState extends State<OrderMasukScreen> {
  // 0 = Ambil, 1 = Timbang
  int _tabIndex = 0;

  OrderStatus get _activeStatus =>
      _tabIndex == 0 ? OrderStatus.masuk : OrderStatus.perluTimbang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ─────────────────────────────────────
            StaffPageHeader(
              title: 'Order Masuk',
              subtitle: _tabIndex == 0
                  ? 'Order yang menunggu untuk diambil'
                  : 'Order yang menunggu ditimbang',
            ),

            // ── Tab Selector ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTabSelector(),
            ),
            const SizedBox(height: 16),

            // ── Order List ────────────────────────────────
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamOrdersByStatus(_activeStatus),
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

                  if (orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) => _buildOrderCard(orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  TAB SELECTOR  (Ambil / Timbang)
  // ──────────────────────────────────────────────────────────
  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _tabButton('Ambil', 0, Icons.move_to_inbox_rounded)),
          const SizedBox(width: 4),
          Expanded(child: _tabButton('Timbang', 1, Icons.balance_rounded)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, int idx, IconData icon) {
    final isActive = _tabIndex == idx;

    return GestureDetector(
      onTap: () => setState(() => _tabIndex = idx),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textGrey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? AppColors.primary : AppColors.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  ORDER CARD
  // ──────────────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);
    final beratLabel = order.beratKg != null
        ? '${order.beratKg!.toStringAsFixed(order.beratKg! % 1 == 0 ? 0 : 1)} kg'
        : null;

    return StaffCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ID + status badge
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const Divider(height: 18),

          _infoRow(Icons.person_outline_rounded,
              '${order.customerName} • ${order.phone}'),
          const SizedBox(height: 6),
          _infoRow(Icons.local_laundry_service_outlined, order.serviceType),
          const SizedBox(height: 6),
          _infoRow(Icons.event_outlined, '$dateStr • ${order.pickupSlot}'),
          if (beratLabel != null) ...[
            const SizedBox(height: 6),
            _infoRow(Icons.scale_outlined, 'Estimasi berat: $beratLabel'),
          ],
          const SizedBox(height: 14),

          // Action button full width
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(order),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textGrey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textGrey,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(OrderModel order) {
    final isAmbil = _tabIndex == 0;
    return ElevatedButton.icon(
      onPressed: () => _handleAction(order),
      icon: Icon(
        isAmbil ? Icons.move_to_inbox_rounded : Icons.balance_rounded,
        size: 18,
      ),
      label: Text(
        isAmbil ? 'Ambil Order' : 'Timbang Order',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  EMPTY STATE
  // ──────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    final msg = _tabIndex == 0
        ? 'Tidak ada orderan yang perlu diambil'
        : 'Tidak ada orderan yang perlu ditimbang';
    final icon =
        _tabIndex == 0 ? Icons.move_to_inbox_rounded : Icons.balance_rounded;

    return StaffEmptyState(icon: icon, message: msg);
  }

  // ──────────────────────────────────────────────────────────
  //  ACTION HANDLERS
  // ──────────────────────────────────────────────────────────
  void _handleAction(OrderModel order) {
    if (_tabIndex == 0) {
      _showAmbilDialog(order);
    } else {
      // Navigasi ke halaman Verifikasi Berat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifikasiBeratScreen(
            order: order,
            onKonfirmasi: () => setState(() {}),
          ),
        ),
      ).then((_) => setState(() {})); // refresh list setelah kembali
    }
  }

  // ── Dialog "Yakin Ambil Sekarang?" ─────────────────────────
  void _showAmbilDialog(OrderModel order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Yakin Ambil Sekarang?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),
              const Text('🤔', style: TextStyle(fontSize: 68)),
              const SizedBox(height: 18),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                        text: 'Pastikan nomor orderan yang kamu\nambil '),
                    TextSpan(
                      text: order.id,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(
                            color: Color(0xFFCCCCCC), width: 1.2),
                      ),
                      child: Text(
                        'Kembali',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await FirestoreService.updateStatus(
                              order.id, OrderStatus.diproses);
                          if (!mounted) return;
                          _showSnack('Order ${order.id} berhasil diambil');
                        } catch (e) {
                          if (!mounted) return;
                          _showSnack('Gagal memperbarui status: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Ambil',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
