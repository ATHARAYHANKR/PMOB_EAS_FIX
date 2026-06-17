import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../customer/detail_order_screen.dart';

class StaffHistoryScreen extends StatelessWidget {
  const StaffHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('History Staff',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700))),
      body: SafeArea(
        child: StreamBuilder<List<OrderModel>>(
          stream: FirestoreService.streamAllOrders(),
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(child: Text('Error: ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final list = (snap.data ?? [])
                .where((o) => o.status == OrderStatus.selesai)
                .toList();
            if (list.isEmpty) {
              return Center(
                  child: Text('Belum ada riwayat order',
                      style: GoogleFonts.inter(color: Colors.black45)));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final o = list[i];
                return ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  title: Text(o.id,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  subtitle: Text('${o.customerName} • ${o.serviceType}',
                      style: GoogleFonts.inter()),
                  trailing: Text(o.statusLabel, style: GoogleFonts.inter()),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => DetailOrderScreen(order: o))),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
