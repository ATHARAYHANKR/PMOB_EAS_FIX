import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class OwnerLaporanScreen extends StatefulWidget {
  const OwnerLaporanScreen({super.key});

  @override
  State<OwnerLaporanScreen> createState() => _OwnerLaporanScreenState();
}

class _OwnerLaporanScreenState extends State<OwnerLaporanScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  /// Bulan yang sedang dipilih, dalam format key 'yyyy-MM'.
  String? _selectedMonthKey;

  String _monthLabel(String key) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return DateFormat('MMMM yyyy', 'id').format(DateTime(year, month));
  }

  String _monthKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
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

            final orders = snapshot.data!;

            // Kumpulkan semua bulan yang punya data order, urut terbaru dulu.
            final monthKeys = <String>{};
            for (final o in orders) {
              monthKeys.add(_monthKey(o.pickupDate));
            }
            final now = DateTime.now();
            monthKeys.add(_monthKey(now));
            final sortedKeys = monthKeys.toList()
              ..sort((a, b) => b.compareTo(a));

            _selectedMonthKey ??= sortedKeys.first;
            if (!sortedKeys.contains(_selectedMonthKey)) {
              _selectedMonthKey = sortedKeys.first;
            }

            final monthOrders = orders
                .where((o) => _monthKey(o.pickupDate) == _selectedMonthKey)
                .toList();

            final pendapatan = monthOrders
                .where((o) => o.status == OrderStatus.selesai)
                .fold<double>(0, (sum, o) => sum + (o.totalHarga ?? 0))
                .toInt();
            final totalOrder = monthOrders.length;
            final selesai = monthOrders
                .where((o) => o.status == OrderStatus.selesai)
                .length;
            final dibatalkan = monthOrders
                .where((o) => o.status == OrderStatus.dibatalkan)
                .length;
            final diproses = totalOrder - selesai - dibatalkan;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title ─────────────────────────────────────────
                  Center(
                    child: Text('Laporan',
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        )),
                  ),
                  const SizedBox(height: 16),

                  // ── Month Picker ───────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => _showMonthPicker(sortedKeys),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: const Color(0xFFEEEEEE), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(8),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(_monthLabel(_selectedMonthKey!),
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                )),
                            const SizedBox(width: 6),
                            const Icon(Icons.keyboard_arrow_down_rounded,
                                size: 18, color: Colors.black45),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Ringkasan ──────────────────────────────────────
                  Text('Ringkasan',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 12),

                  // ── Total Pendapatan Card ──────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFBB2BCD), Color(0xFFD966E8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withAlpha(60),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Pendapatan',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withAlpha(210),
                            )),
                        const SizedBox(height: 8),
                        Text('Rp. ${_formatHarga(pendapatan)}',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Stat Grid ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.receipt_long_outlined,
                          iconBg: const Color(0xFFEDE7F6),
                          iconColor: const Color(0xFF7B1FA2),
                          label: 'Total Order',
                          value: '$totalOrder',
                          sub: 'Bulan ini',
                          subColor: Colors.black45,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.check_circle_outline_rounded,
                          iconBg: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF2E7D32),
                          label: 'Order Selesai',
                          value: '$selesai',
                          sub: totalOrder > 0
                              ? '${(selesai / totalOrder * 100).toStringAsFixed(1)}% dari total'
                              : '0% dari total',
                          subColor: Colors.black45,
                          valueColor: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.access_time_rounded,
                          iconBg: const Color(0xFFFFF3E0),
                          iconColor: const Color(0xFFE65100),
                          label: 'Order Diproses',
                          value: '$diproses',
                          sub: totalOrder > 0
                              ? '${(diproses / totalOrder * 100).toStringAsFixed(1)}% dari total'
                              : '0% dari total',
                          subColor: Colors.black45,
                          valueColor: const Color(0xFFE65100),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          icon: Icons.cancel_outlined,
                          iconBg: const Color(0xFFFFEBEE),
                          iconColor: const Color(0xFFC62828),
                          label: 'Dibatalkan',
                          value: '$dibatalkan',
                          sub: totalOrder > 0
                              ? '${(dibatalkan / totalOrder * 100).toStringAsFixed(1)}% dari total'
                              : '0% dari total',
                          subColor: Colors.black45,
                          valueColor: const Color(0xFFC62828),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Grafik ─────────────────────────────────────
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
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order per Minggu',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            )),
                        const SizedBox(height: 12),
                        _buildWeeklyBarChart(monthOrders),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Weekly bar chart dihitung dari pickupDate order bulan terpilih ──
  Widget _buildWeeklyBarChart(List<OrderModel> monthOrders) {
    final weekCounts = List<int>.filled(5, 0);
    for (final o in monthOrders) {
      final weekIndex = ((o.pickupDate.day - 1) ~/ 7).clamp(0, 4);
      weekCounts[weekIndex]++;
    }
    // Gabungkan minggu ke-5 (sisa hari) ke minggu ke-4 agar tetap 4 kolom.
    weekCounts[3] += weekCounts[4];

    final weeks = [
      (label: 'Minggu 1', val: weekCounts[0]),
      (label: 'Minggu 2', val: weekCounts[1]),
      (label: 'Minggu 3', val: weekCounts[2]),
      (label: 'Minggu 4', val: weekCounts[3]),
    ];
    final maxVal = weeks.map((w) => w.val).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeks.map((w) {
          final frac = maxVal > 0 ? w.val / maxVal : 0.0;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${w.val}',
                    style:
                        GoogleFonts.inter(fontSize: 10, color: Colors.black45)),
                const SizedBox(height: 4),
                Container(
                  height: 95 * frac + 4,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBB2BCD), Color(0xFFD966E8)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Text(w.label,
                    style:
                        GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
    required String sub,
    required Color subColor,
    Color valueColor = const Color(0xFF7B1FA2),
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        GoogleFonts.inter(fontSize: 11, color: Colors.black45)),
                Text(value,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                    )),
                Text(sub,
                    style: GoogleFonts.inter(fontSize: 10, color: subColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(List<String> monthKeys) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 12),
              Text('Pilih Bulan',
                  style: GoogleFonts.inter(
                      fontSize: 15, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: monthKeys.length,
                  itemBuilder: (_, index) {
                    final key = monthKeys[index];
                    final label = _monthLabel(key);
                    final isSelected = key == _selectedMonthKey;
                    return ListTile(
                      title: Text(label,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isSelected
                                  ? const Color(0xFFBB2BCD)
                                  : Colors.black87)),
                      trailing: isSelected
                          ? const Icon(Icons.check_rounded,
                              color: Color(0xFFBB2BCD))
                          : null,
                      onTap: () {
                        setState(() => _selectedMonthKey = key);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatHarga(int h) {
    if (h == 0) return '0';
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
