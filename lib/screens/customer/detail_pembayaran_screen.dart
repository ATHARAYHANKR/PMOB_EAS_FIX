import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'customer_main_screen.dart';

class DetailPembayaranScreen extends StatefulWidget {
  const DetailPembayaranScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<DetailPembayaranScreen> createState() => _DetailPembayaranScreenState();
}

class _DetailPembayaranScreenState extends State<DetailPembayaranScreen> {
  static const Color _blue = Color(0xFF3B5BDB);

  final _catatanCtrl = TextEditingController();

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final berat = order.beratKg ?? 0;
    final total = (order.totalHarga ?? berat * 7000).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title bar ─────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 20, color: Colors.black87),
                    ),
                  ),
                  Text('Detail Pembayaran',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // ── Order info card ───────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                  children: [
                    _infoRow('Order', order.id, bold: true),
                    const SizedBox(height: 8),
                    _infoRow('Layanan', order.serviceType),
                    const SizedBox(height: 8),
                    _infoRow('Berat', '${berat.toStringAsFixed(0)}kg'),
                    const SizedBox(height: 10),
                    const Divider(color: Color(0xFFEEEEEE)),
                    const SizedBox(height: 10),
                    _infoRow('Total', 'Rp${_formatHarga(total)}', bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── QRIS card ─────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
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
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Scan QRIS',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              )),
                        ),
                        const Icon(Icons.file_download_outlined,
                            size: 20, color: Colors.black45),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Rp${_formatHarga(total)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 16),
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(188, 188),
                          painter: _QrPlaceholderPainter(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _blue,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          Text('CleanGo',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text('Silakan lakukan pembayaran sesuai nominal di atas.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Catatan ───────────────────────────────────
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                ),
                child: TextField(
                  controller: _catatanCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Catatan (opsional)',
                    hintStyle:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black38),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap:
                    order.status == OrderStatus.konfirmasiBayar && !order.isPaid
                        ? () => _onBayar(order)
                        : null,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: order.status == OrderStatus.konfirmasiBayar &&
                            !order.isPaid
                        ? _blue
                        : Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    order.status == OrderStatus.konfirmasiBayar && !order.isPaid
                        ? 'Bayar'
                        : 'Sudah Dibayar',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold ? Colors.black87 : Colors.black54,
            )),
        Text(value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: Colors.black87,
            )),
      ],
    );
  }

  void _onBayar(OrderModel order) async {
    // Setelah customer membayar, staff masih perlu konfirmasi pembayaran masuk.
    try {
      await FirestoreService.markCustomerPaid(order.id);
      order.isPaid = true;
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal memproses pembayaran: $e',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _buildSuccessDialog(order),
    );
  }

  Widget _buildSuccessDialog(OrderModel order) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Terima Kasih!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                )),
            const SizedBox(height: 12),
            const Text('🙏', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Pembayaran berhasil. Tunggu staff mengonfirmasi pembayaran anda',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                if (!mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerMainScreen(initialIndex: 1),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('Kembali',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ],
        ),
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

// ── Simple QR-like placeholder pattern ────────────────────────────
class _QrPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1A1A2E);
    final cell = size.width / 21;

    // Deterministic pseudo-random pattern based on cell index
    bool isDark(int x, int y) {
      final seed = (x * 31 + y * 17 + x * y * 7) % 5;
      return seed == 0 || seed == 1;
    }

    for (int y = 0; y < 21; y++) {
      for (int x = 0; x < 21; x++) {
        // Skip corners reserved for finder patterns
        final inTopLeft = x < 7 && y < 7;
        final inTopRight = x > 13 && y < 7;
        final inBottomLeft = x < 7 && y > 13;
        if (!inTopLeft && !inTopRight && !inBottomLeft && isDark(x, y)) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            paint,
          );
        }
      }
    }

    // Finder patterns (corners)
    _drawFinder(canvas, paint, cell, 0, 0);
    _drawFinder(canvas, paint, cell, 14, 0);
    _drawFinder(canvas, paint, cell, 0, 14);
  }

  void _drawFinder(Canvas canvas, Paint paint, double cell, int gx, int gy) {
    canvas.drawRect(
      Rect.fromLTWH(gx * cell, gy * cell, cell * 7, cell * 7),
      paint,
    );
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(
      Rect.fromLTWH((gx + 1) * cell, (gy + 1) * cell, cell * 5, cell * 5),
      whitePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH((gx + 2) * cell, (gy + 2) * cell, cell * 3, cell * 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
