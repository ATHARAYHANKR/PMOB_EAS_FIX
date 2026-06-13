import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../owner/owner_kelola_screen.dart';
import 'detail_layanan_screen.dart';

class KatalogLayananScreen extends StatefulWidget {
  const KatalogLayananScreen({super.key});

  @override
  State<KatalogLayananScreen> createState() => _KatalogLayananScreenState();
}

class _KatalogLayananScreenState extends State<KatalogLayananScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const Color _blue = Color(0xFF3B5BDB);

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<KatalogItem> get _filtered {
    if (_query.isEmpty) return KatalogRepository.items;
    return KatalogRepository.items
        .where((k) => k.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Text('Katalog Layanan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
            ),

            // ── Search + Filter ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: const Color(0xFFEEEEEE), width: 1),
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: GoogleFonts.inter(fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Cari layanan laundry',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 13, color: Colors.black38),
                          prefixIcon: const Icon(Icons.search,
                              color: Colors.black38, size: 20),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: const Color(0xFFEEEEEE), width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.tune_rounded,
                        color: Colors.black54, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Grid ─────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _filtered.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (_, i) => _buildCatalogCard(context, _filtered[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogCard(BuildContext context, KatalogItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailLayananScreen(item: item),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.nama,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 2),
                  Text('Rp${_formatHarga(item.harga)}/${item.satuan.toLowerCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _blue,
                      )),
                  Text('Estimasi ${item.estimasi}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.black45,
                      )),
                ],
              ),
            ),
          ],
        ),
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
