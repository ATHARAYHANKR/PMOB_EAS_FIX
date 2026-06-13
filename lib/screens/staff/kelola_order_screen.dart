import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import 'lanjut_proses_screen.dart';

class KelolaOrderScreen extends StatefulWidget {
  const KelolaOrderScreen({super.key});

  @override
  State<KelolaOrderScreen> createState() => _KelolaOrderScreenState();
}

// Filter yang ditampilkan di chip
enum _FilterTab { semua, cuci, setrika, kirim, selesai }

class _KelolaOrderScreenState extends State<KelolaOrderScreen> {
  _FilterTab _activeFilter = _FilterTab.semua;

  // Mapping filter → status order
  List<OrderModel> get _filtered {
    switch (_activeFilter) {
      case _FilterTab.semua:
        // Tampilkan semua kecuali "masuk" (belum diambil)
        return OrderRepository.all
            .where((o) => o.status != OrderStatus.masuk)
            .toList();
      case _FilterTab.cuci:
        return OrderRepository.byStatus(OrderStatus.diproses);
      case _FilterTab.setrika:
        return OrderRepository.byStatus(OrderStatus.perluTimbang);
      case _FilterTab.kirim:
        return OrderRepository.byStatus(OrderStatus.konfirmasiBayar);
      case _FilterTab.selesai:
        return OrderRepository.byStatus(OrderStatus.selesai);
    }
  }

  // ── Badge style per status ─────────────────────────────────
  _BadgeConfig _badgeFor(OrderStatus status) {
    switch (status) {
      case OrderStatus.diproses:
        return _BadgeConfig(
          label: 'Dicuci',
          bg: const Color(0xFFD6EEFF),
          fg: const Color(0xFF1565C0),
        );
      case OrderStatus.perluTimbang:
        return _BadgeConfig(
          label: 'Disetrika',
          bg: const Color(0xFFFFF9C4),
          fg: const Color(0xFF795548),
        );
      case OrderStatus.konfirmasiBayar:
        return _BadgeConfig(
          label: 'Dikirim',
          bg: const Color(0xFFEDD6FF),
          fg: const Color(0xFF6A1F9F),
        );
      case OrderStatus.selesai:
        return _BadgeConfig(
          label: 'Selesai',
          bg: const Color(0xFFE8F5E9),
          fg: AppColors.primary,
        );
      default:
        return _BadgeConfig(
          label: 'Order Masuk',
          bg: const Color(0xFFFFF3E0),
          fg: AppColors.orange,
        );
    }
  }

  // ── Empty state message per filter ─────────────────────────
  String get _emptyMessage {
    switch (_activeFilter) {
      case _FilterTab.selesai:
        return 'Belum ada pesenan yang selesai';
      case _FilterTab.cuci:
        return 'Tidak ada order yang sedang dicuci';
      case _FilterTab.setrika:
        return 'Tidak ada order yang sedang disetrika';
      case _FilterTab.kirim:
        return 'Tidak ada order yang sedang dikirim';
      default:
        return 'Tidak ada order';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Text(
                'Kelola Order',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),

            // ── Filter chips ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('Semua', _FilterTab.semua),
                    _chip('Cuci', _FilterTab.cuci),
                    _chip('Setrika', _FilterTab.setrika),
                    _chip('Kirim', _FilterTab.kirim),
                    _chip('Selesai', _FilterTab.selesai),
                  ],
                ),
              ),
            ),

            // ── List ──────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) => _buildCard(_filtered[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Chip ──────────────────────────────────────────────────
  Widget _chip(String label, _FilterTab tab) {
    final isActive = _activeFilter == tab;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _activeFilter = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.primary
                  : const Color(0xFFDDDDDD),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }

  // ── Order Card ────────────────────────────────────────────
  Widget _buildCard(OrderModel order) {
    final dateStr =
        DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);
    final timeStr = order.pickupSlot.split(' ').first;
    final badge = _badgeFor(order.status);

    // Label berat jika ada
    final beratLabel = order.beratKg != null
        ? ' - ${order.beratKg!.toStringAsFixed(0)}kg'
        : '';

    // Apakah bisa dilanjut proses (bukan selesai / konfirmasi bayar)
    final bisa = order.status == OrderStatus.diproses ||
        order.status == OrderStatus.perluTimbang;

    return GestureDetector(
      onTap: bisa
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LanjutProsesScreen(
                    order: order,
                    onUpdated: () => setState(() {}),
                  ),
                ),
              ).then((_) => setState(() {}));
            }
          : null,
      child: Container(
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
                    '${order.serviceType}$beratLabel',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$dateStr, $timeStr',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        _emptyMessage,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

class _BadgeConfig {
  final String label;
  final Color bg;
  final Color fg;
  const _BadgeConfig(
      {required this.label, required this.bg, required this.fg});
}
