import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tambah_katalog_screen.dart';
import 'tambah_layanan_screen.dart';
import 'tambah_staff_screen.dart';

// ── Model & Repository: Katalog ────────────────────────────────
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

class KatalogRepository {
  static final List<KatalogItem> items = [
    KatalogItem(
        nama: 'Cuci Kering',
        satuan: 'Kg',
        harga: 7000,
        estimasi: '2 hari',
        deskripsi: 'Cuci Kering'),
    KatalogItem(
        nama: 'Cuci Basah',
        satuan: 'Kg',
        harga: 6000,
        estimasi: '1 hari',
        deskripsi: 'Cuci Basah'),
    KatalogItem(
        nama: 'Setrika',
        satuan: 'Kg',
        harga: 5000,
        estimasi: '1 hari',
        deskripsi: 'Setrika saja'),
    KatalogItem(
        nama: 'Cuci + Setrika',
        satuan: 'Kg',
        harga: 10000,
        estimasi: '3 hari',
        deskripsi: 'Cuci dan Setrika'),
  ];
}

// ── Model & Repository: Layanan ────────────────────────────────
class LayananItem {
  String nama;
  String satuan;
  int harga;
  String estimasi;
  String deskripsi;
  bool aktif;

  LayananItem({
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    this.aktif = true,
  });
}

class LayananRepository {
  static final List<LayananItem> items = [
    LayananItem(
        nama: 'Express Wash',
        satuan: 'Kg',
        harga: 12000,
        estimasi: '1 hari',
        deskripsi: 'Cuci Express'),
    LayananItem(
        nama: 'Premium Dry Clean',
        satuan: 'Pcs',
        harga: 25000,
        estimasi: '3 hari',
        deskripsi: 'Dry Cleaning Premium'),
  ];
}

// ── Model & Repository: Staff ──────────────────────────────────
class StaffItem {
  String nama;
  String telepon;
  String email;
  bool aktif;

  StaffItem({
    required this.nama,
    required this.telepon,
    required this.email,
    this.aktif = true,
  });
}

class StaffRepository {
  static final List<StaffItem> items = [
    StaffItem(
        nama: 'Andi',
        telepon: '0812 3456 7890',
        email: 'andi@gmail.com',
        aktif: true),
    StaffItem(
        nama: 'Budi',
        telepon: '0813 4567 8901',
        email: 'budi@gmail.com',
        aktif: true),
    StaffItem(
        nama: 'Citra',
        telepon: '0814 5678 9012',
        email: 'citra@gmail.com',
        aktif: false),
    StaffItem(
        nama: 'Dina',
        telepon: '0815 6789 0123',
        email: 'dina@gmail.com',
        aktif: true),
  ];
}

// ── Main Screen ────────────────────────────────────────────────
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

  // ── Filtered lists ──────────────────────────────────────────
  List<KatalogItem> get _filteredKatalog {
    if (_query.isEmpty) return KatalogRepository.items;
    return KatalogRepository.items
        .where((k) => k.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<LayananItem> get _filteredLayanan {
    if (_query.isEmpty) return LayananRepository.items;
    return LayananRepository.items
        .where((l) => l.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<StaffItem> get _filteredStaff {
    if (_query.isEmpty) return StaffRepository.items;
    return StaffRepository.items
        .where((s) => s.nama.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  // ── Search hint per tab ─────────────────────────────────────
  String get _searchHint {
    switch (_tab) {
      case _KelolaTab.katalog:
        return 'Cari katalog';
      case _KelolaTab.layanan:
        return 'Cari layanan';
      case _KelolaTab.staff:
        return 'Cari staff';
    }
  }

  // ── Navigate to correct "Tambah" screen ─────────────────────
  void _onTambah() async {
    Widget screen;
    switch (_tab) {
      case _KelolaTab.katalog:
        screen = const TambahKatalogScreen();
        break;
      case _KelolaTab.layanan:
        screen = const TambahLayananScreen();
        break;
      case _KelolaTab.staff:
        screen = const TambahStaffScreen();
        break;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Column(
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              child: Text('Kelola',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  )),
            ),

            // Tab Chips
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

            // Search + Tambah
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
                          hintText: _searchHint,
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
                    onTap: _onTambah,
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

            // List
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tab) {
      case _KelolaTab.katalog:
        return _buildKatalogList();
      case _KelolaTab.layanan:
        return _buildLayananList();
      case _KelolaTab.staff:
        return _buildStaffList();
    }
  }

  Widget _tabChip(String label, _KelolaTab tab) {
    final isActive = _tab == tab;
    return GestureDetector(
      onTap: () => setState(() {
        _tab = tab;
        _query = '';
        _searchCtrl.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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

  // ── Katalog List ────────────────────────────────────────────
  Widget _buildKatalogList() {
    final list = _filteredKatalog;
    if (list.isEmpty) {
      return Center(
        child: Text('Tidak ada katalog ditemukan',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildKatalogCard(list[i]),
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
            child: const Icon(Icons.local_laundry_service_outlined,
                color: Color(0xFFBBBBBB), size: 36),
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
                        child: _statusBadge(item.aktif),
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
                      child: Text('Lihat detail',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _purple,
                            fontWeight: FontWeight.w600,
                          )),
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

  // ── Layanan List ────────────────────────────────────────────
  Widget _buildLayananList() {
    final list = _filteredLayanan;
    if (list.isEmpty) {
      return Center(
        child: Text('Tidak ada layanan ditemukan',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildLayananCard(list[i]),
    );
  }

  Widget _buildLayananCard(LayananItem item) {
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
          Container(
            width: 90,
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E5F5),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
            child: const Icon(Icons.dry_cleaning_outlined,
                color: Color(0xFFBB2BCD), size: 36),
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
                        child: _statusBadge(item.aktif),
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
                      child: Text('Lihat detail',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: _purple,
                            fontWeight: FontWeight.w600,
                          )),
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

  // ── Staff List ──────────────────────────────────────────────
  Widget _buildStaffList() {
    final list = _filteredStaff;
    if (list.isEmpty) {
      return Center(
        child: Text('Tidak ada staff ditemukan',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.black38)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildStaffCard(list[i]),
    );
  }

  Widget _buildStaffCard(StaffItem item) {
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
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(26),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset(
                'assets/images/bg_login.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFBBBBBB),
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
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
                    _statusBadge(item.aktif),
                  ],
                ),
                const SizedBox(height: 2),
                Text('Staff',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.black45)),
                Text(item.telepon,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.black45)),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('Lihat detail',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: _purple,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────
  Widget _statusBadge(bool aktif) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: aktif
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFEEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        aktif ? 'Aktif' : 'Nonaktif',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: aktif ? const Color(0xFF2E7D32) : Colors.redAccent,
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
