import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class KonfirmasiBayarScreen extends StatefulWidget {
  const KonfirmasiBayarScreen({super.key});

  @override
  State<KonfirmasiBayarScreen> createState() => _KonfirmasiBayarScreenState();
}

class _KonfirmasiBayarScreenState extends State<KonfirmasiBayarScreen> {
  int _sectionIndex = 0;

  String _formatDate(DateTime dt) => DateFormat('d MMMM yyyy', 'id').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ───────────────────────────────────
            const StaffPageHeader(
              title: 'Konfirmasi Bayar',
              subtitle: 'Order yang menunggu konfirmasi pembayaran',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _buildSectionTabs(),
            ),

            // ── List / Empty / Loading / Error ───────────
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamOrdersByStatus(
                    OrderStatus.konfirmasiBayar),
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

                  final orders = (snapshot.data ?? [])
                      .where((order) =>
                          _sectionIndex == 0 ? !order.isPaid : order.isPaid)
                      .toList();

                  if (orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildCard(orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Card ─────────────────────────────────────────────────
  Widget _buildSectionTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _sectionButton('Menunggu', 0)),
          const SizedBox(width: 4),
          Expanded(child: _sectionButton('Konfirmasi', 1)),
        ],
      ),
    );
  }

  Widget _sectionButton(String label, int index) {
    final isActive = _sectionIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _sectionIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 42,
        alignment: Alignment.center,
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
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isActive ? AppColors.primary : AppColors.textGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(OrderModel order) {
    final dateStr = _formatDate(order.pickupDate);
    final hargaStr = order.totalHarga != null
        ? NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
            .format(order.totalHarga)
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
              const StatusBadge(status: OrderStatus.konfirmasiBayar),
            ],
          ),
          const Divider(height: 18),

          _infoRow(Icons.person_outline_rounded,
              '${order.customerName} • ${order.phone}'),
          const SizedBox(height: 6),
          _infoRow(Icons.local_laundry_service_outlined, order.serviceType),
          const SizedBox(height: 6),
          _infoRow(Icons.event_outlined, '$dateStr • ${order.pickupSlot}'),

          if (hargaStr != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text(
                    'Total Pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF6A1F9F),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    hargaStr,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6A1F9F),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
          if (order.isPaid)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showKonfirmasiDialog(order),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                label: Text(
                  'Konfirmasi Lunas',
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
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Menunggu customer melakukan pembayaran',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9A6A00),
                ),
              ),
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

  // ── Empty state ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return StaffEmptyState(
      icon: Icons.payments_outlined,
      message: _sectionIndex == 0
          ? 'Tidak ada tagihan yang menunggu pembayaran'
          : 'Tidak ada pembayaran yang perlu dikonfirmasi',
    );
  }

  // ── Dialog "Yakin Konfirmasi Sekarang?" ───────────────────
  void _showKonfirmasiDialog(OrderModel order) {
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
              // Judul
              Text(
                'Yakin Konfirmasi Sekarang?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),

              // Emoji 🤔
              const Text('🤔', style: TextStyle(fontSize: 68)),
              const SizedBox(height: 18),

              // Keterangan
              Text(
                'Pastikan pembayaran sudah masuk',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol
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
                              order.id, OrderStatus.dicuci);
                          if (!mounted) return;
                          _showSnack('${order.id} berhasil dikonfirmasi lunas');
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
                        'Konfirmasi Bayar',
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
