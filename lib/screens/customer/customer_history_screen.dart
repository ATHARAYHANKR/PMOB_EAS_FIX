import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'detail_order_screen.dart';
import 'edit_order_screen.dart';

class CustomerHistoryScreen extends StatefulWidget {
  const CustomerHistoryScreen({super.key});

  @override
  State<CustomerHistoryScreen> createState() => _CustomerHistoryScreenState();
}

class _CustomerHistoryScreenState extends State<CustomerHistoryScreen> {
  int _selectedIndex = 0;

  static const List<String> _tabs = [
    'Semua',
    'Konfirmasi',
    'Dijemput',
    'Diproses',
    'Selesai',
  ];

  bool _matchesFilter(OrderModel o, int idx) {
    switch (idx) {
      case 0: // Semua
        return true;
      case 1: // Konfirmasi: order masuk (bisa diedit / dibatalkan)
        return o.status == OrderStatus.masuk;
      case 2: // Dijemput
        return o.status == OrderStatus.dijemput;
      case 3: // Diproses: dicuci, disetrika, dikirim
        return o.status == OrderStatus.dicuci ||
            o.status == OrderStatus.disetrika ||
            o.status == OrderStatus.dikirim;
      case 4: // Selesai
        return o.status == OrderStatus.selesai;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Order',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_tabs.length, (i) {
                  final selected = i == _selectedIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = i),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color:
                              selected ? const Color(0xFF3B5BDB) : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected
                                  ? Colors.transparent
                                  : const Color(0xFFE0E0E0)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _tabs[i],
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: selected ? Colors.white : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                stream: FirestoreService.streamOrdersForCurrentCustomer(),
                builder: (context, snap) {
                  if (snap.hasError) {
                    return Center(child: Text('Error: ${snap.error}'));
                  }
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final all = (snap.data ?? []);
                  final list = all
                      .where((o) => _matchesFilter(o, _selectedIndex))
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
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          title: Text(o.id,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w700)),
                          subtitle:
                              Text(o.serviceType, style: GoogleFonts.inter()),
                          trailing: _selectedIndex == 1 &&
                                  o.status == OrderStatus.masuk
                              ? SizedBox(
                                  width: 160,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditOrderScreen(
                                                          order: o)),
                                            );
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEDEDF2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text('Edit',
                                                style: GoogleFonts.inter(
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            final ok = await showDialog<bool>(
                                                context: context,
                                                builder: (_) => AlertDialog(
                                                      title: const Text(
                                                          'Batalkan order?'),
                                                      content: const Text(
                                                          'Yakin ingin membatalkan order ini?'),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    false),
                                                            child: const Text(
                                                                'Batal')),
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                    context,
                                                                    true),
                                                            child: const Text(
                                                                'Batalkan')),
                                                      ],
                                                    ));
                                            if (ok == true) {
                                              try {
                                                await FirestoreService
                                                    .cancelOrder(o.id);
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(const SnackBar(
                                                        content: Text(
                                                            'Order dibatalkan')));
                                                setState(() {});
                                              } catch (e) {
                                                if (!mounted) return;
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Gagal batalkan: $e')));
                                              }
                                            }
                                          },
                                          child: Container(
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE05D5D),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                )
                              : Text(o.statusLabel, style: GoogleFonts.inter()),
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => DetailOrderScreen(order: o))),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
