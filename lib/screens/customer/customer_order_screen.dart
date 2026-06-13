import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';

class CustomerOrderScreen extends StatelessWidget {
  const CustomerOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = OrderRepository.all;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text('Order Saya',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildOrderCard(orders[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final dateStr = DateFormat('d MMM yyyy', 'id').format(order.pickupDate);

    Color badgeBg;
    Color badgeFg;
    String badgeLabel;

    switch (order.status) {
      case OrderStatus.diproses:
        badgeBg = const Color(0xFFE3F2FD);
        badgeFg = const Color(0xFF1565C0);
        badgeLabel = 'Diproses';
        break;
      case OrderStatus.selesai:
        badgeBg = const Color(0xFFE8F5E9);
        badgeFg = const Color(0xFF2E7D32);
        badgeLabel = 'Selesai';
        break;
      case OrderStatus.perluTimbang:
        badgeBg = const Color(0xFFFFF9C4);
        badgeFg = const Color(0xFF795548);
        badgeLabel = 'Perlu Timbang';
        break;
      case OrderStatus.konfirmasiBayar:
        badgeBg = const Color(0xFFEDD6FF);
        badgeFg = const Color(0xFF6A1F9F);
        badgeLabel = 'Konfirmasi Bayar';
        break;
      default:
        badgeBg = const Color(0xFFFFF3E0);
        badgeFg = const Color(0xFFFF8C00);
        badgeLabel = 'Order Masuk';
    }

    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.local_laundry_service_outlined,
                color: Colors.black45, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.id,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 2),
                Text(order.serviceType,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black45,
                    )),
                Text(dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black45,
                    )),
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
    );
  }
}
