import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import 'tambah_katalog_screen.dart';
import 'tambah_layanan_screen.dart';
import 'tambah_staff_screen.dart';

// ── Display models (dibangun dari data Firestore) ──────────────
class KatalogItem {
  final String id;
  final String nama;
  final String satuan;
  final int harga;
  final String estimasi;
  final String deskripsi;
  final bool aktif;

  KatalogItem({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    this.aktif = true,
  });

  factory KatalogItem.fromMap(Map<String, dynamic> map) {
    return KatalogItem(
      id: map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? 'Tanpa nama',
      satuan: map['satuan']?.toString() ?? 'Kg',
      harga: int.tryParse(map['harga']?.toString() ?? '') ?? 0,
      estimasi: map['estimasi']?.toString() ?? '-',
      deskripsi: map['deskripsi']?.toString() ?? '-',
      aktif: map['aktif'] == true ||
          map['aktif']?.toString().toLowerCase() == 'true',
    );
  }
}

class LayananItem {
  final String id;
  final String nama;
  final String satuan;
  final int harga;
  final String estimasi;
  final String deskripsi;
  final bool aktif;

  LayananItem({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    this.aktif = true,
  });

  factory LayananItem.fromMap(Map<String, dynamic> map) {
    return LayananItem(
      id: map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? 'Tanpa nama',
      satuan: map['satuan']?.toString() ?? 'Kg',
      harga: int.tryParse(map['harga']?.toString() ?? '') ?? 0,
      estimasi: map['estimasi']?.toString() ?? '-',
      deskripsi: map['deskripsi']?.toString() ?? '-',
      aktif: map['aktif'] == true ||
          map['aktif']?.toString().toLowerCase() == 'true',
    );
  }
}

class StaffItem {
  final String id;
  final String nama;
  final String telepon;
  final String email;
  final bool aktif;

  StaffItem({
    required this.id,
    required this.nama,
    required this.telepon,
    required this.email,
    this.aktif = true,
  });

  factory StaffItem.fromMap(Map<String, dynamic> map) {
    return StaffItem(
      id: map['id']?.toString() ?? '',
      nama: map['nama']?.toString() ?? 'Tanpa nama',
      telepon: map['telepon']?.toString() ?? '-',
      email: map['email']?.toString() ?? '-',
      aktif: map['aktif'] == true ||
          map['aktif']?.toString().toLowerCase() == 'true',
    );
  }
}

// ── Main Screen ────────────────────────────────────────────────
enum KelolaTab { katalog, layanan, staff }

class OwnerKelolaScreen extends StatefulWidget {
  const OwnerKelolaScreen({
    super.key,
    this.initialTab = KelolaTab.katalog,
    this.tabNotifier,
  });

  final KelolaTab initialTab;

  /// Opsional: jika diberikan, perubahan nilai pada notifier ini akan
  /// mengganti tab aktif secara otomatis (digunakan oleh OwnerMainScreen
  /// untuk navigasi dari dashboard / menu cepat).
  final ValueNotifier<KelolaTab>? tabNotifier;

  @override
  State<OwnerKelolaScreen> createState() => _OwnerKelolaScreenState();
}

class _OwnerKelolaScreenState extends State<OwnerKelolaScreen> {
  late KelolaTab _tab;
  final _searchCtrl = TextEditingController();
  String _query = '';

  static const Color _purple = Color(0xFFBB2BCD);

  @override
  void initState() {
    super.initState();
    _tab = widget.tabNotifier?.value ?? widget.initialTab;
    widget.tabNotifier?.addListener(_onExternalTabChange);
  }

  void _onExternalTabChange() {
    final next = widget.tabNotifier?.value;
    if (next != null && next != _tab) {
      setState(() {
        _tab = next;
        _query = '';
        _searchCtrl.clear();
      });
    }
  }

  @override
  void dispose() {
    widget.tabNotifier?.removeListener(_onExternalTabChange);
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Search hint per tab ─────────────────────────────────────
  String get _searchHint {
    switch (_tab) {
      case KelolaTab.katalog:
        return 'Cari katalog';
      case KelolaTab.layanan:
        return 'Cari layanan';
      case KelolaTab.staff:
        return 'Cari staff';
    }
  }

  // ── Navigate to correct "Tambah" screen ─────────────────────
  void _onTambah() async {
    Widget screen;
    switch (_tab) {
      case KelolaTab.katalog:
        screen = const TambahKatalogScreen();
        break;
      case KelolaTab.layanan:
        screen = const TambahLayananScreen();
        break;
      case KelolaTab.staff:
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
                  _tabChip('Katalog', KelolaTab.katalog),
                  const SizedBox(width: 8),
                  _tabChip('Layanan', KelolaTab.layanan),
                  const SizedBox(width: 8),
                  _tabChip('Staff', KelolaTab.staff),
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
      case KelolaTab.katalog:
        return _buildKatalogTab();
      case KelolaTab.layanan:
        return _buildLayananTab();
      case KelolaTab.staff:
        return _buildStaffTab();
    }
  }

  Widget _tabChip(String label, KelolaTab tab) {
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

  // ── Katalog Tab (Firestore) ──────────────────────────────────
  Widget _buildKatalogTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.streamKatalogRaw(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState('Gagal memuat katalog: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data!.map(KatalogItem.fromMap).toList();
        if (_query.isNotEmpty) {
          list = list
              .where((k) => k.nama.toLowerCase().contains(_query.toLowerCase()))
              .toList();
        }
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
      },
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
                      Expanded(
                        child: Text(item.nama,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            )),
                      ),
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

  // ── Layanan Tab (Firestore) ───────────────────────────────────
  Widget _buildLayananTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.streamLayananRaw(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState('Gagal memuat layanan: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data!.map(LayananItem.fromMap).toList();
        if (_query.isNotEmpty) {
          list = list
              .where((l) => l.nama.toLowerCase().contains(_query.toLowerCase()))
              .toList();
        }
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
      },
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
                      Expanded(
                        child: Text(item.nama,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            )),
                      ),
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

  // ── Staff Tab (Firestore) ──────────────────────────────────────
  Widget _buildStaffTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirestoreService.streamStaffRaw(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _errorState('Gagal memuat staff: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var list = snapshot.data!.map(StaffItem.fromMap).toList();
        if (_query.isNotEmpty) {
          list = list
              .where((s) => s.nama.toLowerCase().contains(_query.toLowerCase()))
              .toList();
        }
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
      },
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
            alignment: Alignment.center,
            child: Text(
              item.nama.isNotEmpty ? item.nama.substring(0, 1).toUpperCase() : '?',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF999999),
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
                    Expanded(
                      child: Text(item.nama,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          )),
                    ),
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
  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.redAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

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
