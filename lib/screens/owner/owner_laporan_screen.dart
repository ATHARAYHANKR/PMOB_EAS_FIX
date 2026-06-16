import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerLaporanScreen extends StatefulWidget {
  const OwnerLaporanScreen({super.key});

  @override
  State<OwnerLaporanScreen> createState() => _OwnerLaporanScreenState();
}

class _OwnerLaporanScreenState extends State<OwnerLaporanScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  // Daftar bulan tersedia
  final List<String> _bulanOptions = [
    'Januari 2026',
    'Februari 2026',
    'Maret 2026',
    'April 2026',
    'Mei 2026',
    'Juni 2026',
    'Juli 2026',
    'Agustus 2026',
    'September 2026',
    'Oktober 2026',
    'November 2026',
    'Desember 2026',
  ];
  String _selectedBulan = 'Juni 2026';

  // Data ringkasan per bulan (dummy)
  final Map<String, _LaporanData> _dataMap = {
    'Januari 2026': const _LaporanData(
        pendapatan: 3200000,
        totalOrder: 88,
        selesai: 70,
        dijemput: 12,
        dibatalkan: 6),
    'Februari 2026': const _LaporanData(
        pendapatan: 2800000,
        totalOrder: 76,
        selesai: 60,
        dijemput: 10,
        dibatalkan: 6),
    'Maret 2026': const _LaporanData(
        pendapatan: 3700000,
        totalOrder: 95,
        selesai: 78,
        dijemput: 11,
        dibatalkan: 6),
    'April 2026': const _LaporanData(
        pendapatan: 4100000,
        totalOrder: 110,
        selesai: 89,
        dijemput: 14,
        dibatalkan: 7),
    'Mei 2026': const _LaporanData(
        pendapatan: 3900000,
        totalOrder: 102,
        selesai: 84,
        dijemput: 12,
        dibatalkan: 6),
    'Juni 2026': const _LaporanData(
        pendapatan: 4500000,
        totalOrder: 120,
        selesai: 95,
        dijemput: 20,
        dibatalkan: 5),
    'Juli 2026': const _LaporanData(
        pendapatan: 0, totalOrder: 0, selesai: 0, dijemput: 0, dibatalkan: 0),
  };

  _LaporanData get _current =>
      _dataMap[_selectedBulan] ??
      const _LaporanData(
          pendapatan: 0, totalOrder: 0, selesai: 0, dijemput: 0, dibatalkan: 0);

  @override
  Widget build(BuildContext context) {
    final data = _current;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  onTap: _showMonthPicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: const Color(0xFFEEEEEE), width: 1),
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
                        Text(_selectedBulan,
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
                    Text('Rp. ${_formatHarga(data.pendapatan)}',
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
                      value: '${data.totalOrder}',
                      sub: 'Semua waktu',
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
                      value: '${data.selesai}',
                      sub: data.totalOrder > 0
                          ? '${(data.selesai / data.totalOrder * 100).toStringAsFixed(1)}% dari total'
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
                      label: 'Order Dijemput',
                      value: '${data.dijemput}',
                      sub: data.totalOrder > 0
                          ? '${(data.dijemput / data.totalOrder * 100).toStringAsFixed(1)}% dari total'
                          : '0% dari total',
                      subColor: Colors.black45,
                      valueColor: const Color(0xFFE65100),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      icon: Icons.cancel_outlined,
                      iconBg: const Color(0xFFFEEEEE),
                      iconColor: Colors.redAccent,
                      label: 'Order Dibatalkan',
                      value: '${data.dibatalkan}',
                      sub: data.totalOrder > 0
                          ? '${(data.dibatalkan / data.totalOrder * 100).toStringAsFixed(1)}% dari total'
                          : '0% dari total',
                      subColor: Colors.black45,
                      valueColor: Colors.redAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Grafik Placeholder ─────────────────────────────
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
                    Text('Pendapatan per Minggu',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 12),
                    _buildSimpleBarChart(data),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Simple bar chart (manual) ─────────────────────────────────
  Widget _buildSimpleBarChart(_LaporanData data) {
    // Dummy weekly data derived from total
    final base = data.totalOrder > 0 ? (data.totalOrder / 4).round() : 0;
    final weeks = [
      (label: 'Minggu 1', val: (base * 0.8).round()),
      (label: 'Minggu 2', val: (base * 1.1).round()),
      (label: 'Minggu 3', val: (base * 0.9).round()),
      (label: 'Minggu 4', val: (base * 1.2).round()),
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

  void _showMonthPicker() {
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
                  itemCount: _bulanOptions.length,
                  itemBuilder: (_, index) {
                    final b = _bulanOptions[index];
                    return ListTile(
                      title: Text(b,
                          style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: b == _selectedBulan
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: b == _selectedBulan
                                  ? const Color(0xFFBB2BCD)
                                  : Colors.black87)),
                      trailing: b == _selectedBulan
                          ? const Icon(Icons.check_rounded,
                              color: Color(0xFFBB2BCD))
                          : null,
                      onTap: () {
                        setState(() => _selectedBulan = b);
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

class _LaporanData {
  final int pendapatan;
  final int totalOrder;
  final int selesai;
  final int dijemput;
  final int dibatalkan;
  const _LaporanData({
    required this.pendapatan,
    required this.totalOrder,
    required this.selesai,
    required this.dijemput,
    required this.dibatalkan,
  });
}
