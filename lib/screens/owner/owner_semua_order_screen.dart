import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_theme.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

/// Halaman daftar seluruh order milik owner, terhubung langsung
/// dengan koleksi `orders` di Firestore (lewat FirestoreService).
class OwnerSemuaOrderScreen extends StatefulWidget {
  const OwnerSemuaOrderScreen({super.key});

  @override
  State<OwnerSemuaOrderScreen> createState() => _OwnerSemuaOrderScreenState();
}

class _OwnerSemuaOrderScreenState extends State<OwnerSemuaOrderScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  OrderStatus? _filter;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
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
                        fontSize: 13, color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var orders = snapshot.data!;
            if (_filter != null) {
              orders = orders.where((o) => o.status == _filter).toList();
            }
            if (_query.isNotEmpty) {
              final q = _query.toLowerCase();
              orders = orders
                  .where((o) =>
                      o.id.toLowerCase().contains(q) ||
                      o.customerName.toLowerCase().contains(q))
                  .toList();
            }

            return Column(
              children: [
                _buildAppBar(),
                _buildSearch(),
                const SizedBox(height: 10),
                _buildFilterChips(),
                const SizedBox(height: 8),
                Expanded(
                  child: orders.isEmpty
                      ? const StaffEmptyState(
                          icon: Icons.inventory_2_outlined,
                          message: 'Tidak ada order ditemukan',
                        )
                      : ListView.separated(
                          padding:
                              const EdgeInsets.fromLTRB(20, 4, 20, 24),
                          itemCount: orders.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) => _orderCard(orders[i]),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          Text('Semua Order',
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _query = v),
          style: GoogleFonts.inter(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Cari ID order atau nama customer',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.black38),
            prefixIcon:
                const Icon(Icons.search, color: Colors.black38, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final statuses = <OrderStatus?>[null, ...OrderModel.workflowStatuses, OrderStatus.dibatalkan];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final status = statuses[i];
          final isActive = _filter == status;
          final label = status == null ? 'Semua' : status.statusLabel;
          return GestureDetector(
            onTap: () => setState(() => _filter = status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? _purple : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? _purple : const Color(0xFFDDDDDD),
                  width: 1.2,
                ),
              ),
              child: Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF888888),
                  )),
            ),
          );
        },
      ),
    );
  }

  Widget _orderCard(OrderModel order) {
    final dateStr = DateFormat('d MMM yyyy', 'id').format(order.pickupDate);
    return StaffCard(
      child: Row(
        children: [
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
                const SizedBox(height: 4),
                Text(order.customerName,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 2),
                Text('${order.serviceType} • $dateStr',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.black45)),
                if (order.totalHarga != null) ...[
                  const SizedBox(height: 4),
                  Text(
                      'Rp ${_formatHarga(order.totalHarga!.toInt())}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _purple,
                      )),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(status: order.status),
        ],
      ),
    );
  }

  String _formatHarga(int h) {
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
