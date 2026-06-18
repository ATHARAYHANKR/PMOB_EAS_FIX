import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'detail_order_screen.dart';
import 'edit_order_screen.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _filterIndex = 0;
  int _selesaiSub = 0; // 0 = Diterima, 1 = Dibatalkan

  // Tab: Semua | Konfirmasi | Dijemput | Diproses | Selesai
  static const _filters = [
    'Semua',
    'Konfirmasi',
    'Dijemput',
    'Diproses',
    'Selesai'
  ];
  static const Color _blue = Color(0xFF3B5BDB);

  List<OrderModel> _applyFilter(List<OrderModel> all) {
    switch (_filterIndex) {
      case 1: // Konfirmasi: order masuk, bisa diedit/dibatalkan
        return all.where((o) => o.status == OrderStatus.masuk).toList();
      case 2: // Dijemput: dijemput + perluTimbang (tidak termasuk Menunggu Pembayaran)
        return all
            .where((o) =>
                o.status == OrderStatus.dijemput ||
                o.status == OrderStatus.perluTimbang)
            .toList();
      case 3: // Diproses: sedang dicuci / disetrika / dikirim
        return all
            .where((o) =>
                o.status == OrderStatus.dicuci ||
                o.status == OrderStatus.disetrika ||
                o.status == OrderStatus.dikirim)
            .toList();
      case 4: // Selesai: diterima atau dibatalkan (sub-tab)
        if (_selesaiSub == 0) {
          return all.where((o) => o.status == OrderStatus.selesai).toList();
        } else {
          return all.where((o) => o.status == OrderStatus.dibatalkan).toList();
        }
      default: // Semua (kecuali Menunggu Pembayaran)
        return all
            .where((o) => o.status != OrderStatus.konfirmasiBayar || o.isPaid)
            .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text('Riwayat Order',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
            ),
            _buildFilterRow(),
            if (_filterIndex == 4) _buildSelesaiSubTabs(),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamOrdersForCurrentCustomer(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Gagal memuat data order: ${snap.error}',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final orders = _applyFilter(snap.data ?? []);
                  if (orders.isEmpty) {
                    return Center(
                      child: Text('Belum ada order',
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.black45)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildOrderCard(context, orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter chip row ───────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _filterIndex == i;
          return GestureDetector(
            onTap: () => setState(() {
              _filterIndex = i;
              _selesaiSub = 0;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _blue : const Color(0xFFEDEDF2),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(_filters[i],
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black54,
                  )),
            ),
          );
        },
      ),
    );
  }

  // ── Sub-tab Selesai: Diterima / Dibatalkan ───────────────────────────────
  Widget _buildSelesaiSubTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _buildSubTab('Diterima', 0),
          const SizedBox(width: 24),
          _buildSubTab('Dibatalkan', 1),
        ],
      ),
    );
  }

  Widget _buildSubTab(String label, int index) {
    final selected = _selesaiSub == index;
    return GestureDetector(
      onTap: () => setState(() => _selesaiSub = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? const Color(0xFF1A1A2E) : Colors.black26,
              )),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: label.length * 7.0 + 4,
            color: selected ? const Color(0xFF1A1A2E) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ── Order card ────────────────────────────────────────────────────────────
  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);

    // Badge warna sesuai status
    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    switch (order.status) {
      case OrderStatus.masuk:
        badgeBg = const Color(0xFFEBEBEB);
        badgeFg = const Color(0xFF616161);
        badgeLabel = 'Menunggu Konfirmasi';
        break;
      case OrderStatus.dijemput:
        badgeBg = const Color(0xFFD6F0F7);
        badgeFg = const Color(0xFF1E88A8);
        badgeLabel = 'Dijemput';
        break;
      case OrderStatus.perluTimbang:
        badgeBg = const Color(0xFFFFE0B2);
        badgeFg = const Color(0xFFE65100);
        badgeLabel = 'Perlu Timbang';
        break;
      case OrderStatus.konfirmasiBayar:
        badgeBg = const Color(0xFFB2DFDB);
        badgeFg = const Color(0xFF00695C);
        badgeLabel =
            order.isPaid ? 'Menunggu Konfirmasi Bayar' : 'Menunggu Pembayaran';
        break;
      case OrderStatus.dicuci:
        badgeBg = const Color(0xFFD9F7E3);
        badgeFg = const Color(0xFF1E7E34);
        badgeLabel = 'Dicuci';
        break;
      case OrderStatus.disetrika:
        badgeBg = const Color(0xFFD1C4E9);
        badgeFg = const Color(0xFF512DA8);
        badgeLabel = 'Disetrika';
        break;
      case OrderStatus.dikirim:
        badgeBg = const Color(0xFFE3F2FD);
        badgeFg = const Color(0xFF1565C0);
        badgeLabel = 'Dikirim';
        break;
      case OrderStatus.selesai:
        badgeBg = const Color(0xFFD9F7E3);
        badgeFg = const Color(0xFF2E7D32);
        badgeLabel = 'Diterima';
        break;
      case OrderStatus.dibatalkan:
        badgeBg = const Color(0xFFFBD9DC);
        badgeFg = const Color(0xFFC0392B);
        badgeLabel = 'Dibatalkan';
        break;
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailOrderScreen(order: order)),
      ),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order.id,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        order.beratKg != null
                            ? '${order.serviceType} · ${order.beratKg!.toStringAsFixed(0)} kg'
                            : order.serviceType,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: Colors.black54),
                      ),
                      if (order.totalHarga != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            'Rp${NumberFormat('#,###', 'id').format(order.totalHarga)}',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(dateStr,
                            style: GoogleFonts.inter(
                                fontSize: 12, color: Colors.black45)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            // ── Tombol Edit & Batalkan khusus tab Konfirmasi ──────────────
            if (_filterIndex == 1 && order.status == OrderStatus.masuk) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditOrderScreen(order: order)),
                        );
                        setState(() {});
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDF2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('Edit',
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Batalkan order?'),
                            content: const Text(
                                'Yakin ingin membatalkan order ini?'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Kembali')),
                              TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Batalkan',
                                      style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (ok == true) {
                          try {
                            await FirestoreService.cancelOrder(order.id);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Order dibatalkan')));
                            setState(() {});
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gagal batalkan: $e')));
                          }
                        }
                      },
                      child: Container(
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE05D5D),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text('Batalkan',
                            style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
