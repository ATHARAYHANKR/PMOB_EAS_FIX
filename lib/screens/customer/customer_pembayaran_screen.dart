import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'detail_pembayaran_screen.dart';

class CustomerPembayaranScreen extends StatelessWidget {
  const CustomerPembayaranScreen({super.key});

  static const Color _blue = Color(0xFF3B5BDB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bayar',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 14),

              const SizedBox(height: 16),

              // ── Tagihan list (dari Firestore) ─────────────
              StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamOrdersForCurrentCustomer(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Gagal memuat data pembayaran: ${snap.error}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final tagihan = (snap.data ?? [])
                      .where((o) =>
                          o.status == OrderStatus.konfirmasiBayar &&
                          !o.isPaid)
                      .toList();
                  if (tagihan.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: Text('Tidak ada tagihan saat ini',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: Colors.black38)),
                      ),
                    );
                  }
                  return Column(
                      children: tagihan
                          .map((o) => _buildTagihanCard(context, o))
                          .toList());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagihanCard(BuildContext context, OrderModel order) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);
    final berat = order.beratKg ?? 0;
    final total = (order.totalHarga ?? berat * 7000).round();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
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
                Text('${order.serviceType} - ${berat.toStringAsFixed(0)}kg',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    )),
                const SizedBox(height: 2),
                Text('Rp${_formatHarga(total)}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 2),
                Text(dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.black45,
                    )),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailPembayaranScreen(order: order),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
              decoration: BoxDecoration(
                color: _blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Bayar',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  String _formatHarga(int h) {
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
