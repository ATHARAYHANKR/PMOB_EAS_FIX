import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'lanjut_proses_screen.dart';

class KelolaOrderScreen extends StatefulWidget {
  const KelolaOrderScreen({super.key});

  @override
  State<KelolaOrderScreen> createState() => _KelolaOrderScreenState();
}

// Filter yang ditampilkan di chip
enum _FilterTab { semua, diambil, timbang, cuci, pembayaran, selesai }

class _KelolaOrderScreenState extends State<KelolaOrderScreen> {
  _FilterTab _activeFilter = _FilterTab.semua;

  // Mapping filter → status order, dijalankan di atas data Firestore
  List<OrderModel> _applyFilter(List<OrderModel> all) {
    switch (_activeFilter) {
      case _FilterTab.semua:
        // Tampilkan semua kecuali "masuk" (belum diambil)
        return all.where((o) => o.status != OrderStatus.masuk).toList();
      case _FilterTab.diambil:
        return all.where((o) => o.status == OrderStatus.diproses).toList();
      case _FilterTab.timbang:
        return all.where((o) => o.status == OrderStatus.perluTimbang).toList();
      case _FilterTab.cuci:
        return all.where((o) => o.status == OrderStatus.konfirmasi).toList();
      case _FilterTab.pembayaran:
        return all
            .where((o) => o.status == OrderStatus.konfirmasiBayar)
            .toList();
      case _FilterTab.selesai:
        return all.where((o) => o.status == OrderStatus.selesai).toList();
    }
  }

  // ── Empty state message per filter ─────────────────────────
  String get _emptyMessage {
    switch (_activeFilter) {
      case _FilterTab.selesai:
        return 'Belum ada pesenan yang selesai';
      case _FilterTab.diambil:
        return 'Tidak ada order yang sedang diambil';
      case _FilterTab.timbang:
        return 'Tidak ada order yang perlu ditimbang';
      case _FilterTab.cuci:
        return 'Tidak ada order yang sedang dicuci & disetrika';
      case _FilterTab.pembayaran:
        return 'Tidak ada order yang menunggu konfirmasi bayar';
      default:
        return 'Tidak ada order';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────────
            const StaffPageHeader(
              title: 'Kelola Order',
              subtitle: 'Pantau dan kelola seluruh pesanan',
            ),

            // ── Filter chips ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _chip('Semua', _FilterTab.semua),
                    _chip('Diambil', _FilterTab.diambil),
                    _chip('Timbang', _FilterTab.timbang),
                    _chip('Dicuci & Disetrika', _FilterTab.cuci),
                    _chip('Pembayaran', _FilterTab.pembayaran),
                    _chip('Selesai', _FilterTab.selesai),
                  ],
                ),
              ),
            ),

            // ── List ──────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamAllOrders(),
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

                  final filtered = _applyFilter(snapshot.data!);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildCard(filtered[i]),
                  );
                },
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive ? AppColors.primary : const Color(0xFFE0E0E0),
              width: 1.2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);
    final timeStr = order.pickupSlot.split(' ').first;

    final beratLabel = order.beratKg != null
        ? '${order.beratKg!.toStringAsFixed(order.beratKg! % 1 == 0 ? 0 : 1)} kg'
        : null;
    final hargaStr = order.totalHarga != null
        ? NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0)
            .format(order.totalHarga)
        : null;

    // Apakah bisa dilanjut proses (bukan selesai / konfirmasi bayar)
    final bisa = order.status == OrderStatus.diproses ||
        order.status == OrderStatus.perluTimbang ||
        order.status == OrderStatus.konfirmasi ||
        order.status == OrderStatus.dijemput;

    return StaffCard(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          _infoRow(
            Icons.local_laundry_service_outlined,
            beratLabel != null
                ? '${order.serviceType} • $beratLabel'
                : order.serviceType,
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.event_outlined, '$dateStr • $timeStr'),

          if (hargaStr != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 15, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  hargaStr,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          if (bisa) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Lihat detail & lanjutkan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.arrow_forward_rounded,
                    size: 14, color: AppColors.primary),
              ],
            ),
          ],
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

  // ── Empty State ───────────────────────────────────────────
  Widget _buildEmptyState() {
    return StaffEmptyState(
      icon: Icons.list_alt_rounded,
      message: _emptyMessage,
    );
  }
}
