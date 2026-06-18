import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class LanjutProsesScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onUpdated;

  const LanjutProsesScreen({
    super.key,
    required this.order,
    this.onUpdated,
  });

  @override
  State<LanjutProsesScreen> createState() => _LanjutProsesScreenState();
}

class _LanjutProsesScreenState extends State<LanjutProsesScreen> {
  OrderModel get order => widget.order;
  VoidCallback? get onUpdated => widget.onUpdated;

  String _formatDate(DateTime dt) => DateFormat('d MMMM yyyy', 'id').format(dt);

  // ── Warna & label badge berdasarkan status ─────────────────
  _BadgeStyle _badgeStyle() {
    switch (order.status) {
      case OrderStatus.dijemput:
        return const _BadgeStyle(
          bg: Color(0xFFD6EEFF),
          fg: Color(0xFF1565C0),
          label: 'Dijemput',
        );
      case OrderStatus.perluTimbang:
        return const _BadgeStyle(
          bg: Color(0xFFFFF9C4),
          fg: Color(0xFF795548),
          label: 'Timbang',
        );
      case OrderStatus.dicuci:
        return const _BadgeStyle(
          bg: Color(0xFFB2DFDB),
          fg: Color(0xFF00695C),
          label: 'Dicuci',
        );
      case OrderStatus.disetrika:
        return const _BadgeStyle(
          bg: Color(0xFFD6F5F0),
          fg: Color(0xFF00897B),
          label: 'Disetrika',
        );
      case OrderStatus.dikirim:
        return const _BadgeStyle(
          bg: Color(0xFFE3F2FD),
          fg: Color(0xFF1565C0),
          label: 'Kirim',
        );
      case OrderStatus.konfirmasiBayar:
        return const _BadgeStyle(
          bg: Color(0xFFEDD6FF),
          fg: Color(0xFF6A1F9F),
          label: 'Konfirmasi Bayar',
        );
      default:
        return _BadgeStyle(
          bg: const Color(0xFFE8F5E9),
          fg: AppColors.primary,
          label: order.statusLabel,
        );
    }
  }

  // ── Teks keterangan & label tombol ─────────────────────────
  String get _keterangan {
    if (order.isFinalized) {
      return 'Order telah selesai atau dibatalkan.';
    }
    switch (order.status) {
      case OrderStatus.masuk:
        return 'Terima order untuk memulai proses laundry.';
      case OrderStatus.dijemput:
        return 'Order sudah dijemput, lanjutkan ke penimbangan.';
      case OrderStatus.perluTimbang:
        return 'Lanjutkan ke proses penimbangan untuk mengirim tagihan ke customer.';
      case OrderStatus.dicuci:
        return 'Order sedang dicuci. Lanjutkan ke proses setrika setelah selesai.';
      case OrderStatus.disetrika:
        return 'Order sudah disetrika. Lanjutkan ke proses pengiriman.';
      case OrderStatus.dikirim:
        return 'Order sedang dikirim. Tandai selesai setelah diterima customer.';
      case OrderStatus.konfirmasiBayar:
        return 'Menunggu customer melakukan pembayaran sebelum dilanjutkan.';
      default:
        return 'Lanjutkan proses pesanan ini.';
    }
  }

  String get _buttonLabel {
    if (order.isFinalized) return 'Tidak Dapat Dilanjutkan';
    switch (order.status) {
      case OrderStatus.masuk:
        return 'Terima Order';
      case OrderStatus.dijemput:
        return 'Timbang Order';
      case OrderStatus.perluTimbang:
        return 'Kirim Tagihan';
      case OrderStatus.dicuci:
        return 'Lanjut Setrika';
      case OrderStatus.disetrika:
        return 'Kirim Order';
      case OrderStatus.dikirim:
        return 'Tandai Selesai';
      case OrderStatus.konfirmasiBayar:
        return 'Menunggu Pembayaran';
      default:
        return 'Lanjut Proses';
    }
  }

  OrderStatus? get _nextStatus => order.nextStatus;

  bool get _canContinue => _nextStatus != null && !order.isFinalized;

  // ──────────────────────────────────────────────────────────

  Widget _buildOrderHeader() {
    final badge = _badgeStyle();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(order.pickupDate)} - ${order.pickupSlot.split(' ').first}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: badge.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: badge.fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    final rows = [
      ('Customer', order.customerName),
      ('Layanan', order.serviceType),
      (
        'Jemput',
        '${_formatDate(order.pickupDate)}, ${order.pickupSlot.split(' ').first}'
      ),
      ('Catatan', '-'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        children: rows.map((r) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(r.$1,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    )),
                Text(r.$2,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    )),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showKonfirmasiDialog(BuildContext context) {
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
                'Konfirmasi Perubahan Status',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),
              const Text('🚚', style: TextStyle(fontSize: 68)),
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
                    const TextSpan(text: 'Update order '),
                    TextSpan(
                      text: order.id,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: ' ke status '),
                    TextSpan(
                      text: _nextStatus?.stepTitle ?? 'selesai',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LinearProgressIndicator(
                value: order.workflowProgress,
                minHeight: 8,
                backgroundColor: const Color(0xFFEDEDF2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 18),
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
                      onPressed: _canContinue
                          ? () async {
                              if (order.nextStatus != null) {
                                final updatedStatus = order.nextStatus!;
                                final navigator = Navigator.of(context);
                                final messenger = ScaffoldMessenger.of(context);
                                Navigator.pop(context); // tutup dialog
                                try {
                                  await FirestoreService.advanceStatus(order);
                                  onUpdated?.call();
                                  if (!mounted) return;
                                  navigator.pop(); // kembali
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Order ${order.id} berhasil dipindah ke ${updatedStatus.stepTitle}',
                                        style: GoogleFonts.inter(fontSize: 13),
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Gagal memperbarui status: $e',
                                        style: GoogleFonts.inter(fontSize: 13),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canContinue
                            ? AppColors.primary
                            : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _buttonLabel,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'LANJUT PROSES',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    const SizedBox(height: 12),
                    _buildDetailCard(),
                    const SizedBox(height: 20),

                    // Keterangan
                    Text(
                      _keterangan,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol aksi
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showKonfirmasiDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _buttonLabel,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeStyle {
  final Color bg;
  final Color fg;
  final String label;
  const _BadgeStyle({required this.bg, required this.fg, required this.label});
}
