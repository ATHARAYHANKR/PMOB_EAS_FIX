import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'detail_order_screen.dart';

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
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final activeOrders = (snap.data ?? [])
                .where((o) => o.status != OrderStatus.selesai)
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
      case OrderStatus.diproses:
        return 'Dijemput & Diproses';
      case OrderStatus.perluTimbang:
        return 'Penimbangan';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Pembayaran';
      case OrderStatus.selesai:
        return 'Selesai & Dikirim';
      default:
        return 'Order Diterima';
    }
  }
}
