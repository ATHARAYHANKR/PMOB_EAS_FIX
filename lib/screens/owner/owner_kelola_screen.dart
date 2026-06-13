import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_katalog_screen.dart';

// ── Model sederhana untuk katalog ─────────────────────────────
class KatalogItem {
  String nama;
  String satuan;
  int harga;
  String estimasi;
  String deskripsi;
  bool aktif;

  KatalogItem({
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    this.aktif = true,
  });
}

// Dummy repository global
class KatalogRepository {
  static final List<KatalogItem> items = [
    KatalogItem(
        nama: 'Cuci Kering',
        satuan: 'Kg',
        harga: 7000,
        estimasi: '2 hari',
        deskripsi: 'Cuci Kering'),
    KatalogItem(
        nama: 'Cuci Kering',
        satuan: 'Kg',
        harga: 7000,
        estimasi: '2 hari',
        deskripsi: 'Cuci Kering'),
    KatalogItem(
        nama: 'Cuci Kering',
        satuan: 'Kg',
        harga: 7000,
        estimasi: '2 hari',
        deskripsi: 'Cuci Kering'),
    KatalogItem(
        nama: 'Cuci Kering',
        satuan: 'Kg',
        harga: 7000,
        estimasi: '2 hari',
        deskripsi: 'Cuci Kering'),
  ];
}

class OwnerKelolaScreen extends StatefulWidget {
  const OwnerKelolaScreen({super.key});

  @override
  State<OwnerKelolaScreen> createState() => _OwnerKelolaScreenState();
}

enum _KelolaTab { katalog, layanan, staff }

class _OwnerKelolaScreenState extends State<OwnerKelolaScreen> {
  _KelolaTab _tab = _KelolaTab.katalog;
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const Color _purple = Color(0xFFBB2BCD);

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
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Title ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Text('Kelola',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
            ),

            // ── Tab Chips ────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _tabChip('Katalog', _KelolaTab.katalog),
                  const SizedBox(width: 8),
                  _tabChip('Layanan', _KelolaTab.layanan),
                  const SizedBox(width: 8),
                  _tabChip('Staff', _KelolaTab.staff),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── Search + Tambah ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: const Color(0xFFEEEEEE), width: 1),
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
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TambahKatalogScreen()),
                      );
                      setState(() {});
                    },
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: _purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text('+ Tambah',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── List ─────────────────────────────────────
            Expanded(
              child: _tab == _KelolaTab.katalog
                  ? _buildKatalogList()
                  : _buildComingSoon(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabChip(String label, _KelolaTab tab) {
    final isActive = _tab == tab;
    return GestureDetector(
      onTap: () => setState(() => _tab = tab),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : const Color(0xFF888888),
            )),
      ),
    );
  }

  Widget _buildKatalogList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Text('Tidak ada katalog ditemukan',
            style: GoogleFonts.inter(
                fontSize: 13, color: Colors.black38)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildKatalogCard(_filtered[i]),
    );
  }

  Widget _buildKatalogCard(KatalogItem item) {
    return Container(
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
          // Placeholder image
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEEEE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.nama,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: item.aktif
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFEEEEE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.aktif ? 'Aktif' : 'Nonaktif',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: item.aktif
                                  ? const Color(0xFF2E7D32)
                                  : Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                      'Rp${_formatHarga(item.harga)}/${item.satuan.toLowerCase()}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black45)),
                  Text('Estimasi ${item.estimasi}',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: Colors.black45)),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {},
                        child: Text('Lihat detail',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _purple,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon() {
    return Center(
      child: Text('Fitur segera hadir',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
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
