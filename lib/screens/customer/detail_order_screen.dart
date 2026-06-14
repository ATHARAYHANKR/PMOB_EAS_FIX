import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'edit_order_screen.dart';

class DetailOrderScreen extends StatefulWidget {
  const DetailOrderScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<DetailOrderScreen> createState() => _DetailOrderScreenState();
}

class _DetailOrderScreenState extends State<DetailOrderScreen> {
  OrderModel get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);

    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    final steps = order.computedSteps;
    final progress =
        order.status == OrderStatus.dibatalkan ? 0.0 : order.workflowProgress;
    final doneSteps = steps.where((step) => step.done).length;

    switch (order.status) {
      case OrderStatus.masuk:
        badgeBg = const Color(0xFFEDEDF2);
        badgeFg = const Color(0xFF555555);
        badgeLabel = 'Menunggu';
        break;
      case OrderStatus.konfirmasi:
        badgeBg = const Color(0xFFEDEDF2);
        badgeFg = const Color(0xFF555555);
        badgeLabel = 'Dicuci & Disetrika';
        break;
      case OrderStatus.dijemput:
        badgeBg = const Color(0xFFD6F0F7);
        badgeFg = const Color(0xFF1E88A8);
        badgeLabel = 'Dijemput';
        break;
      case OrderStatus.diproses:
        badgeBg = const Color(0xFFFFF3C4);
        badgeFg = const Color(0xFF8A6D1B);
        badgeLabel = 'Diambil';
        break;
      case OrderStatus.perluTimbang:
        badgeBg = const Color(0xFFEEF6FF);
        badgeFg = const Color(0xFF1565C0);
        badgeLabel = 'Perlu Timbang';
        break;
      case OrderStatus.konfirmasiBayar:
        badgeBg = const Color(0xFFFFF3C4);
        badgeFg = const Color(0xFF8A6D1B);
        badgeLabel = 'Konfirmasi Bayar';
        break;
      case OrderStatus.selesai:
        badgeBg = const Color(0xFFD9F7E3);
        badgeFg = const Color(0xFF2E7D32);
        badgeLabel = 'Selesai';
        break;
      case OrderStatus.dibatalkan:
        badgeBg = const Color(0xFFFBD9DC);
        badgeFg = const Color(0xFFC0392B);
        badgeLabel = 'Dibatalkan';
        break;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text('Detail Order',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            )),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(order.id,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Colors.black87,
                              )),
                          const SizedBox(height: 4),
                          Text(
                              '$dateStr - ${order.pickupSlot.split('-')[0].trim()}',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.black54,
                              )),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
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
              ),
              const SizedBox(height: 14),
              if (order.status != OrderStatus.dibatalkan) ...[
                Text('Progress Pesanan',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEDEDF2),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3B5BDB)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${(progress * 100).round()}% selesai',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        )),
                    Text('$doneSteps/${steps.length} tahap',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black54,
                        )),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // Info card
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  children: order.status == OrderStatus.dibatalkan
                      ? [
                          _infoRow('Layanan', order.serviceType),
                          _infoRow('Jemput', '$dateStr, ${order.pickupSlot}'),
                          _infoRow('Catatan', order.catatan, isLast: true),
                        ]
                      : [
                          _infoRow('Customer', order.customerName),
                          _infoRow('Alamat', order.address),
                          _infoRow('Layanan', order.serviceType),
                          if (order.beratKg != null)
                            _infoRow('Berat',
                                '${order.beratKg!.toStringAsFixed(0)}kg'),
                          if (order.totalHarga != null)
                            _infoRow('Total Harga',
                                'Rp${NumberFormat('#,###', 'id').format(order.totalHarga)}',
                                bold: true),
                          _infoRow('Jemput', '$dateStr, ${order.pickupSlot}'),
                          _infoRow('Catatan', order.catatan, isLast: true),
                        ],
                ),
              ),

              if (order.status == OrderStatus.konfirmasi) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => EditOrderScreen(order: order)),
                          );
                          setState(() {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD23F),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Edit',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _showBatalkanDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE05D5D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Batalkan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            )),
                      ),
                    ),
                  ],
                ),
              ],

              if (order.status != OrderStatus.dibatalkan) ...[
                const SizedBox(height: 22),
                Text('Status Order',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 12),
                ...List.generate(steps.length, (i) {
                  final step = steps[i];
                  final isLast = i == steps.length - 1;
                  return _buildStepRow(step, isLast);
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value,
      {bool isLast = false, bool bold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
              )),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  color: Colors.black87,
                )),
          ),
        ],
      ),
    );
  }

  // Mapping title -> emoji icon as seen in screenshots
  String _iconFor(String title) {
    switch (title) {
      case 'Menunggu Konfirmasi':
      case 'Berhasil Konfirmasi':
        return '⏳';
      case 'Dijemput':
        return '🛵';
      case 'Konfirmasi Pembayaran':
        return '💳';
      case 'Dicuci':
      case 'Dicuci & Disetrika':
        return '🧺';
      case 'Timbang':
        return '⚖️';
      case 'Disetrika':
        return '✨';
      case 'Dikirim':
        return '📦';
      case 'Selesai':
        return '✅';
      default:
        return '•';
    }
  }

  Widget _buildStepRow(StatusStep step, bool isLast) {
    const activeColor = Color(0xFF3B5BDB);
    final doneCircleColor = step.title == 'Selesai' && step.done
        ? const Color(0xFF2E7D32)
        : activeColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: step.done ? doneCircleColor : const Color(0xFFF1F1F5),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(_iconFor(step.title),
                    style: const TextStyle(fontSize: 14)),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 36,
                  color: step.done ? activeColor : const Color(0xFFE0E0E6),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: step.done ? Colors.black87 : Colors.black45,
                      )),
                  if (step.date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(step.date!,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.black45,
                          )),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBatalkanDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Yakin batalkan order ini?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 16),
              const Icon(Icons.delete_outline_rounded,
                  size: 64, color: Color(0xFF8B4040)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFF2E7D32), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text('Kembali',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2E7D32),
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context); // close dialog

                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          await FirestoreService.cancelOrder(order.id);
                          if (!mounted) return;
                          Navigator.pop(context); // close loading
                          Navigator.pop(context); // close detail screen
                        } catch (e) {
                          if (!mounted) return;
                          Navigator.pop(context); // close loading
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Gagal membatalkan order: $e',
                                style: GoogleFonts.inter(fontSize: 13)),
                            backgroundColor: Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            margin: const EdgeInsets.all(16),
                          ));
                        }
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0392B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('Batalkan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
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
}
