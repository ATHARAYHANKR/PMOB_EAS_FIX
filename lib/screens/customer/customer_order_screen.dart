import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'detail_order_screen.dart';

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});

  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}

class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _filterIndex = 0; // 0 Semua,1 Dijemput,2 Timbang,3 Lunas,4 Selesai
  int _selesaiSub = 0; // 0 Diterima, 1 Dibatalkan

  static const _filters = ['Semua', 'Dijemput', 'Timbang', 'Lunas', 'Selesai'];
  static const Color _blue = Color(0xFF3B5BDB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Column(
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
                  final all = snap.data ?? [];
                  List<OrderModel> orders = all;
                  switch (_filterIndex) {
                    case 1:
                      orders = all
                          .where((o) => o.status == OrderStatus.dijemput)
                          .toList();
                      break;
                    case 2:
                      orders = all
                          .where((o) => o.status == OrderStatus.perluTimbang)
                          .toList();
                      break;
                    case 3:
                      orders = all
                          .where((o) => o.status == OrderStatus.dicuci)
                          .toList();
                      break;
                    case 4:
                      orders = all
                          .where((o) => o.status == OrderStatus.disetrika)
                          .toList();
                      break;
                    case 5:
                      if (_selesaiSub == 0) {
                        orders = all
                            .where((o) => o.status == OrderStatus.selesai)
                            .toList();
                      } else {
                        orders = all
                            .where((o) => o.status == OrderStatus.dibatalkan)
                            .toList();
                      }
                      break;
                    default:
                      orders = all;
                  }

                  if (orders.isEmpty) {
                    return Center(
                      child: Text('Belum ada order',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black45,
                          )),
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

  Widget _buildSelesaiSubTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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

  Widget _buildOrderCard(BuildContext context, OrderModel order) {
    final dateStr = DateFormat('d MMMM yyyy', 'id').format(order.pickupDate);

    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    switch (order.status) {
      case OrderStatus.masuk:
        badgeBg = const Color(0xFFEBEBEB);
        badgeFg = const Color(0xFF616161);
        badgeLabel = 'Masuk';
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
        badgeLabel = 'Konfirmasi Bayar';
        break;
      case OrderStatus.dikirim:
        badgeBg = const Color(0xFFE3F2FD);
        badgeFg = const Color(0xFF1565C0);
        badgeLabel = 'Dikirim';
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailOrderScreen(order: order)),
        );
      },
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
        child: Row(
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
                  const SizedBox(height: 6),
                  Text(
                    order.beratKg != null
                        ? '${order.serviceType} - ${order.beratKg!.toStringAsFixed(0)}kg'
                        : order.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: order.totalHarga != null
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: order.totalHarga != null
                          ? Colors.black87
                          : Colors.black54,
                    ),
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
                          fontSize: 12,
                          color: Colors.black45,
                        )),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }
}
