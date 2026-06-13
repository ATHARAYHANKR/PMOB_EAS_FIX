import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class VerifikasiBeratScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onKonfirmasi;

  const VerifikasiBeratScreen({
    super.key,
    required this.order,
    this.onKonfirmasi,
  });

  @override
  State<VerifikasiBeratScreen> createState() => _VerifikasiBeratScreenState();
}

class _VerifikasiBeratScreenState extends State<VerifikasiBeratScreen> {
  final TextEditingController _beratController = TextEditingController();

  @override
  void dispose() {
    _beratController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) => DateFormat('d MMMM yyyy', 'id').format(dt);

  // ── Header card: ORD + tanggal + status badge ──────────────
  Widget _buildOrderHeader() {
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
                  widget.order.id,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatDate(widget.order.pickupDate)} - ${widget.order.pickupSlot.split(' ').first}',
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
              color: const Color(0xFFD9C2F0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Dikirim',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6A1F9F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Detail card: Customer / Layanan / Jemput / Harga ───────
  Widget _buildDetailCard() {
    final rows = [
      ('Customer', widget.order.customerName),
      ('Layanan', widget.order.serviceType),
      (
        'Jemput',
        '${_formatDate(widget.order.pickupDate)}, ${widget.order.pickupSlot.split(' ').first}'
      ),
      ('Harga Satuan', 'Rp7.000'),
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

  // ── Berat input ────────────────────────────────────────────
  Widget _buildBeratInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berat (kg)',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _beratController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Contoh: 3.5',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFBBBBBB),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
          style: GoogleFonts.inter(fontSize: 14, color: AppColors.textDark),
        ),
      ],
    );
  }

  // ── Simpan button ──────────────────────────────────────────
  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onSimpan,
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
          'Simpan & Kirim Tagihan ke Customer',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _onSimpan() {
    final kg = double.tryParse(_beratController.text);
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Masukkan berat yang valid',
            style: GoogleFonts.inter(fontSize: 13)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    // Simpan berat & update status
    OrderRepository.updateWeightAndConfirm(widget.order, kg);
    widget.onKonfirmasi?.call();

    // Tampilkan dialog sukses
    _showBerhasilDialog();
  }

  // ── Dialog "Berhasil Konfirmasi!" ──────────────────────────
  void _showBerhasilDialog() {
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
                'Berhasil Konfirmasi!',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),

              // Emoji 👌
              const Text('👌', style: TextStyle(fontSize: 72)),
              const SizedBox(height: 18),

              // Keterangan
              Text(
                'Tunggu customer melakukan\npembayaran untuk lanjut memproses\npesanan mereka',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // tutup dialog
                    Navigator.pop(context); // kembali ke OrderMasuk
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Kembali',
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
                    'VERIFIKASI BERAT',
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

            // ── Body ──────────────────────────────────────
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
                    _buildBeratInput(),
                    const SizedBox(height: 24),
                    _buildSimpanButton(),
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
