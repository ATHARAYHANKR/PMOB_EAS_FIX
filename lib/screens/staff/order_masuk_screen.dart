import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import 'verifikasi_berat_screen.dart';

class OrderMasukScreen extends StatefulWidget {
  const OrderMasukScreen({super.key});

  @override
  State<OrderMasukScreen> createState() => _OrderMasukScreenState();
}

class _OrderMasukScreenState extends State<OrderMasukScreen> {
  // 0 = Ambil, 1 = Timbang
  int _tabIndex = 0;

  List<OrderModel> get _displayedOrders {
    if (_tabIndex == 0) {
      return OrderRepository.byStatus(OrderStatus.masuk);
    } else {
      return OrderRepository.byStatus(OrderStatus.perluTimbang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                'Order Masuk',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Tab Selector ──────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTabSelector(),
            ),
            const SizedBox(height: 16),

            // ── Order List ────────────────────────────────
            Expanded(
              child: _displayedOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _displayedOrders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) =>
                          _buildOrderCard(_displayedOrders[i]),
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
    return Row(
      children: [
        Expanded(child: _tabButton('Ambil', 0)),
        Expanded(child: _tabButton('Timbang', 1)),
      ],
    );
  }

  Widget _tabButton(String label, int idx) {
    final isActive = _tabIndex == idx;
    final isLeft = idx == 0;

    return GestureDetector(
      onTap: () => setState(() => _tabIndex = idx),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : Colors.white,
          borderRadius: BorderRadius.horizontal(
            left: isLeft ? const Radius.circular(8) : Radius.zero,
            right: !isLeft ? const Radius.circular(8) : Radius.zero,
          ),
          border: Border.all(
            color: isActive ? AppColors.primaryLight : const Color(0xFFDDDDDD),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF888888),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  ORDER CARD
  // ──────────────────────────────────────────────────────────
  Widget _buildOrderCard(OrderModel order) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.id,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.customerName} - ${order.phone}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.serviceType,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr, ${order.pickupSlot}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildActionButton(order),
        ],
      ),
    );
  }

  Widget _buildActionButton(OrderModel order) {
    final isAmbil = _tabIndex == 0;
    return ElevatedButton(
      onPressed: () => _handleAction(order),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        isAmbil ? 'Ambil Order' : 'Timbang',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.white,
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

    return Center(
      child: Text(
        msg,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textGrey,
        ),
      ),
    );
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
                      onPressed: () {
                        setState(() => OrderRepository.updateStatus(
                            order, OrderStatus.diproses));
                        Navigator.pop(context);
                        _showSnack('Order ${order.id} berhasil diambil');
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
