import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'detail_order_screen.dart';
import 'detail_pembayaran_screen.dart';

class CustomerTrackingScreen extends StatelessWidget {
  const CustomerTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: FirestoreService.streamOrdersForCurrentCustomer(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Gagal memuat data tracking: ${snap.error}',
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
            final activeOrders = (snap.data ?? [])
                .where((o) => o.status != OrderStatus.selesai)
                .toList();

            final ordersNeedingPayment = activeOrders
                .where((o) => o.status == OrderStatus.konfirmasiBayar)
                .toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tracking Laundry',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 16),

                  // ── Payment notification banner ────────────────
                  if (ordersNeedingPayment.isNotEmpty)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3C4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFCB3A),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_rounded,
                                  size: 20, color: Color(0xFF8A6D1B)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Ada pembayaran yang diperlukan',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF8A6D1B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    if (ordersNeedingPayment.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailPembayaranScreen(
                                            order: ordersNeedingPayment.first,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8A6D1B),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Bayar Sekarang',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  if (activeOrders.isEmpty)
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
                      child: Center(
                        child: Text('Tidak ada order aktif',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.black45,
                            )),
                      ),
                    )
                  else
                    Column(
                      children: activeOrders.map((order) {
                        final current = _currentStepLabel(order.status);
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetailOrderScreen(order: order),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(order.id,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                            )),
                                        const SizedBox(height: 6),
                                        Text(order.serviceType,
                                            style: GoogleFonts.inter(
                                              fontSize: 12,
                                              color: Colors.black45,
                                            )),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: order.status ==
                                                        OrderStatus.selesai
                                                    ? const Color(0xFF2E7D32)
                                                    : const Color(0xFFFFB300),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(current,
                                                  style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    color: Colors.black87,
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      size: 20, color: Colors.black26),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _currentStepLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.masuk:
        return 'Order Diterima';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.perluTimbang:
        return 'Penimbangan';
      case OrderStatus.dicuci:
        return 'Dicuci';
      case OrderStatus.disetrika:
        return 'Disetrika';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Pembayaran';
      case OrderStatus.selesai:
        return 'Selesai & Dikirim';
      default:
        return 'Order Diterima';
    }
  }
}
