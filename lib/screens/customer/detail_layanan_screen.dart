import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/katalog_model.dart';
import '../owner/owner_kelola_screen.dart';
import 'booking_laundry_screen.dart';

class DetailLayananScreen extends StatelessWidget {
  const DetailLayananScreen({super.key, required this.item});

  final KatalogItem item;

  static const Color _blue = Color(0xFF3B5BDB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title bar ─────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 20, color: Colors.black87),
                    ),
                  ),
                  Text('Detail Layanan',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      )),
                ],
              ),
              const SizedBox(height: 16),

              // ── Image placeholder ─────────────────────────
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),

              // ── Name + price ───────────────────────────────
              Text(item.nama,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 4),
              Text('Rp${_formatHarga(item.harga)}/${item.satuan.toLowerCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _blue,
                  )),
              const SizedBox(height: 2),
              Text('Estimasi ${item.estimasi}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black45,
                  )),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 14),

              // ── Deskripsi ─────────────────────────────────
              Text('Deskripsi',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 6),
              Text(
                item.deskripsi.isNotEmpty
                    ? 'Layanan ${item.deskripsi.toLowerCase()} menggunakan deterjen berkualitas serta proses yang higienis untuk hasil maksimal.'
                    : 'Layanan cuci menggunakan deterjen berkualitas serta proses yang higienis untuk hasil maksimal.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              // ── Keunggulan ─────────────────────────────────
              Text('Keunggulan',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 10),
              ..._buildKeunggulan([
                'Bersih & higenis',
                'Wangi tahan lama',
                'Free layanan antar jemput',
              ]),
              const SizedBox(height: 28),

              // ── Booking button ───────────────────────────
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingLaundryScreen(
                        selectedItem: KatalogModel(
                          id: item.nama,
                          nama: item.nama,
                          satuan: item.satuan,
                          harga: item.harga,
                          estimasi: item.estimasi,
                          deskripsi: item.deskripsi,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text('Booking Sekarang',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildKeunggulan(List<String> items) {
    return items
        .map((label) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.black87,
                      )),
                ],
              ),
            ))
        .toList();
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
