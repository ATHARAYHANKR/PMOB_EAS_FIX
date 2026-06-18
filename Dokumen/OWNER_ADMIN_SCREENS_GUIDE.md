# 📚 PART 6: OWNER MANAGEMENT & ADMINISTRATION SCREENS

**Coverage**: Owner add/edit/report features  
**Status**: Complete  
**Last Updated**: 2026-06-18

---

## 📑 TABLE OF CONTENTS

1. [Tambah Katalog](#tambah-katalog)
2. [Owner Laporan](#owner-laporan)
3. [Owner Semua Order](#owner-semua-order)
4. [Owner Profil](#owner-profil)

---

## ➕ TAMBAH KATALOG

### tambah_katalog_screen.dart

**Lokasi**: `/lib/screens/owner/tambah_katalog_screen.dart`  
**Fungsi**: Add new service catalog dengan validation & success dialog  
**Pattern**: Form with dropdowns, numeric input, Firebase save

#### State & Initialization
```dart
class _TambahKatalogScreenState extends State<TambahKatalogScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  // Input controllers
  final _namaCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  // Dropdown values
  String? _satuan = 'Kg';           # Default unit
  String? _estimasi;                # Processing time
  bool _statusAktif = true;         # Active by default
  bool _isLoading = false;

  // Dropdown options
  final List<String> _satuanOptions = ['Kg', 'Pcs', 'Lusin'];
  final List<String> _estimasiOptions = [
    '1 hari',
    '2 hari',
    '3 hari',
    '4 hari',
    '5 hari'
  ];

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }
}
```

#### Form Validation & Save
```dart
Future<void> _onTambah() async {
  // Validation 1: Check nama
  if (_namaCtrl.text.trim().isEmpty) {
    _showError('Nama layanan tidak boleh kosong');
    return;
  }

  // Validation 2: Parse & check harga
  final harga = int.tryParse(
    _hargaCtrl.text
      .replaceAll('.', '')
      .replaceAll('Rp', '')
      .trim()
  );
  if (harga == null || harga <= 0) {
    _showError('Harga tidak valid');
    return;
  }

  // Validation 3: Check estimasi selection
  if (_estimasi == null) {
    _showError('Pilih estimasi pengerjaan');
    return;
  }

  // All validation passed, save to Firebase
  setState(() => _isLoading = true);

  try {
    // Call FirestoreService to add to katalog collection
    await FirestoreService.addKatalog({
      'nama': _namaCtrl.text.trim(),
      'satuan': _satuan ?? 'Kg',
      'harga': harga,
      'estimasi': _estimasi,
      'deskripsi': _deskripsiCtrl.text.trim(),
      'aktif': _statusAktif,
    });

    if (mounted) {
      _showSuksesDialog();  # Show success dialog
    }
  } catch (e) {
    if (mounted) {
      _showError('Gagal menyimpan: $e');
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

#### Form Fields
```dart
Widget _buildNameField() {
  return _formField(
    label: 'Nama Layanan',
    controller: _namaCtrl,
    hint: 'Contoh: Cuci Kering Regular',
    required: true,
  );
}

Widget _buildPriceField() {
  return _formField(
    label: 'Harga',
    controller: _hargaCtrl,
    hint: 'Rp 7.000',
    keyboardType: TextInputType.number,
    required: true,
    onChanged: (val) {
      // Format input with currency
      if (val.isNotEmpty) {
        final cleaned = val.replaceAll(RegExp(r'[^\d]'), '');
        if (cleaned.isNotEmpty) {
          final formatted = _formatCurrency(
            int.parse(cleaned)
          );
          _hargaCtrl.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(
              offset: formatted.length
            ),
          );
        }
      }
    },
  );
}

Widget _buildUnitDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel('Satuan', required: true),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: _satuan,
          isExpanded: true,
          underline: const SizedBox(),  # Remove default underline
          items: _satuanOptions
              .map((s) => DropdownMenuItem(
                value: s,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(s, style: GoogleFonts.inter(fontSize: 13)),
                ),
              ))
              .toList(),
          onChanged: (val) => setState(() => _satuan = val),
        ),
      ),
    ],
  );
}

Widget _buildEstimasiDropdown() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabel('Estimasi Pengerjaan', required: true),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<String>(
          value: _estimasi,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Pilih waktu pengerjaan',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black38,
              ),
            ),
          ),
          underline: const SizedBox(),
          items: _estimasiOptions
              .map((e) => DropdownMenuItem(
                value: e,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    e,
                    style: GoogleFonts.inter(fontSize: 13),
                  ),
                ),
              ))
              .toList(),
          onChanged: (val) => setState(() => _estimasi = val),
        ),
      ),
    ],
  );
}

Widget _buildDescriptionField() {
  return _formField(
    label: 'Deskripsi',
    controller: _deskripsiCtrl,
    hint: 'Deskripsi singkat tentang layanan ini',
    maxLines: 3,
  );
}

Widget _buildStatusToggle() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Status',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Switch(
        value: _statusAktif,
        onChanged: (val) => setState(() => _statusAktif = val),
        activeColor: _purple,
      ),
    ],
  );
}
```

#### Success Dialog
```dart
void _showSuksesDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,  # Must close dialog explicitly
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkmark icon
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: _purple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Success text
            Text(
              'Katalog berhasil\nditambahkan!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Data katalog baru telah disimpan!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black45,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);  # Close dialog
                  Navigator.pop(context);  # Go back to Kelola
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Lihat Katalog',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

**Key Points**:
- Full form validation (empty, numeric, selection)
- Currency formatting for price input
- Dropdown for unit & estimation
- Status toggle switch
- Success dialog with double navigation

---

## 📊 OWNER LAPORAN

### owner_laporan_screen.dart

**Lokasi**: `/lib/screens/owner/owner_laporan_screen.dart`  
**Fungsi**: Monthly reports dengan revenue, order stats  
**Pattern**: Month selector, dummy data map, stat cards

#### State & Month Selection
```dart
class _OwnerLaporanScreenState extends State<OwnerLaporanScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  // Available months
  final List<String> _bulanOptions = [
    'Januari 2026', 'Februari 2026', 'Maret 2026',
    'April 2026', 'Mei 2026', 'Juni 2026',
    'Juli 2026', 'Agustus 2026', 'September 2026',
    'Oktober 2026', 'November 2026', 'Desember 2026',
  ];
  
  String _selectedBulan = 'Juni 2026';  # Default selected

  // Monthly data (dummy/placeholder)
  final Map<String, _LaporanData> _dataMap = {
    'Januari 2026': const _LaporanData(
      pendapatan: 3200000,
      totalOrder: 88,
      selesai: 70,
      dijemput: 12,
      dibatalkan: 6,
    ),
    'Februari 2026': const _LaporanData(
      pendapatan: 2800000,
      totalOrder: 76,
      selesai: 60,
      dijemput: 10,
      dibatalkan: 6,
    ),
    // ... more months
    'Juni 2026': const _LaporanData(
      pendapatan: 4500000,
      totalOrder: 120,
      selesai: 95,
      dijemput: 20,
      dibatalkan: 5,
    ),
  };

  // Get current month data
  _LaporanData get _current =>
      _dataMap[_selectedBulan] ??
      const _LaporanData(
        pendapatan: 0,
        totalOrder: 0,
        selesai: 0,
        dijemput: 0,
        dibatalkan: 0,
      );
}
```

#### Build with Month Picker
```dart
@override
Widget build(BuildContext context) {
  final data = _current;  # Get current month data

  return Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Title ─────────────────────────────────
            Center(
              child: Text(
                'Laporan',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // ── Month Picker ──────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: _showMonthPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(8),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedBulan,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // ── Summary Section ───────────────────────
            Text(
              'Ringkasan',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 12),

            // ── Total Revenue Card ─────────────────────
            _buildRevenueCard(data),
            
            const SizedBox(height: 16),

            // ── Order Stats Grid ──────────────────────
            _buildStatsGrid(data),
          ],
        ),
      ),
    ),
  );
}

void _showMonthPicker() {
  showModalBottomSheet(
    context: context,
    builder: (_) => Column(
      mainAxisSize: MainAxisSize.min,
      children: _bulanOptions
          .map((bulan) => ListTile(
            title: Text(bulan),
            onTap: () {
              setState(() => _selectedBulan = bulan);
              Navigator.pop(context);
            },
          ))
          .toList(),
    ),
  );
}
```

#### Data Display Widgets
```dart
Widget _buildRevenueCard(_LaporanData data) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF9C27B0),  # Purple
          Color(0xFFBB2BCD),  # Lighter purple
        ],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(20),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Pendapatan',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rp${_formatCurrency(data.pendapatan)}',
          style: GoogleFonts.inter(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}

Widget _buildStatsGrid(_LaporanData data) {
  final stats = [
    ('Total Order', data.totalOrder.toString()),
    ('Selesai', data.selesai.toString()),
    ('Dijemput', data.dijemput.toString()),
    ('Dibatalkan', data.dibatalkan.toString()),
  ];

  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 1.3,
    children: stats
        .map((stat) => _StatCardSmall(
          title: stat.$1,
          value: stat.$2,
        ))
        .toList(),
  );
}

class _StatCardSmall extends StatelessWidget {
  const _StatCardSmall({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.black45,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for monthly reports
class _LaporanData {
  final int pendapatan;      # Total revenue
  final int totalOrder;      # Total orders
  final int selesai;         # Completed
  final int dijemput;        # Pickup pending
  final int dibatalkan;      # Cancelled

  const _LaporanData({
    required this.pendapatan,
    required this.totalOrder,
    required this.selesai,
    required this.dijemput,
    required this.dibatalkan,
  });
}
```

**Key Points**:
- Month selector with bottom sheet picker
- Monthly data stored in map (dummy data for now)
- Gradient revenue card
- 2x2 stat grid
- Data model class for type safety

---

## 📋 OWNER SEMUA ORDER

### owner_semua_order_screen.dart

**Lokasi**: `/lib/screens/owner/owner_semua_order_screen.dart`  
**Fungsi**: View all orders with search & filter  
**Pattern**: StreamBuilder, search filter, status chips

#### State & Filtering
```dart
class _OwnerSemuaOrderScreenState extends State<OwnerSemuaOrderScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  OrderStatus? _filter;               # Active status filter
  final _searchCtrl = TextEditingController();
  String _query = '';                 # Search query

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }
}
```

#### Build with StreamBuilder
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    body: SafeArea(
      child: StreamBuilder<List<OrderModel>>(
        // Stream all orders
        stream: FirestoreService.streamAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var orders = snapshot.data!;

          // Apply status filter
          if (_filter != null) {
            orders = orders
                .where((o) => o.status == _filter)
                .toList();
          }

          // Apply search filter
          if (_query.isNotEmpty) {
            final q = _query.toLowerCase();
            orders = orders
                .where((o) =>
                    o.id.toLowerCase().contains(q) ||
                    o.customerName
                        .toLowerCase()
                        .contains(q))
                .toList();
          }

          return Column(
            children: [
              _buildAppBar(),
              _buildSearch(),
              const SizedBox(height: 10),
              _buildFilterChips(),
              const SizedBox(height: 8),
              
              // Orders list
              Expanded(
                child: orders.isEmpty
                    ? const StaffEmptyState(
                        icon: Icons.inventory_2_outlined,
                        message: 'Tidak ada order ditemukan',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          20, 4, 20, 24
                        ),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _orderCard(orders[i]),
                      ),
              ),
            ],
          );
        },
      ),
    ),
  );
}
```

#### Search & Filter UI
```dart
Widget _buildSearch() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _query = v),
        style: GoogleFonts.inter(fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Cari ID order atau nama customer',
          hintStyle: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.black38,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.black38,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 11,
          ),
        ),
      ),
    ),
  );
}

Widget _buildFilterChips() {
  // Build status chips for filtering
  return SizedBox(
    height: 36,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      scrollDirection: Axis.horizontal,
      itemCount: _filterOptions.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        final status = _filterOptions[i];
        final isActive = _filter == status;
        
        return FilterChip(
          label: Text(
            status?.label ?? 'Semua',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.black54,
            ),
          ),
          selected: isActive,
          onSelected: (selected) {
            setState(() => _filter = selected ? status : null);
          },
          backgroundColor: Colors.white,
          selectedColor: _purple,
          side: BorderSide(
            color: isActive
                ? _purple
                : const Color(0xFFEEEEEE),
          ),
        );
      },
    ),
  );
}
```

**Key Points**:
- Real-time streaming from Firestore
- Dual filtering (status + search)
- Search by ID or customer name
- Filter chips for status selection
- Empty state message

---

## 👤 OWNER PROFIL

### owner_profil_screen.dart

**Lokasi**: `/lib/screens/owner/owner_profil_screen.dart`  
**Fungsi**: Owner account information & settings  
**Pattern**: Info sections, action tiles, logout

#### Build with Header
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8F8),
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header / Avatar ────────────────────────
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                children: [
                  // Avatar with border
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _purple,
                        width: 2.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 48,
                      color: _purple,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Title
                  Text(
                    'Pemilik CleanGo',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _purpleLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Owner',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _purple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // ── Info Section ───────────────────────────
            _section(
              title: 'Informasi Akun',
              items: const [
                _InfoItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Nama',
                  value: 'Pemilik CleanGo',
                ),
                _InfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: '+62 821 9876 5432',
                ),
                _InfoItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'owner@cleango.id',
                ),
                _InfoItem(
                  icon: Icons.storefront_outlined,
                  label: 'Nama Usaha',
                  value: 'CleanGo Laundry',
                ),
                _InfoItem(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: 'Owner / Pemilik',
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // ── Settings Section ────────────────────────
            _sectionAction(
              title: 'Pengaturan',
              tiles: [
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'Ganti Password',
                  color: _purple,
                  onTap: () {},
                ),
                _ActionTile(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notifikasi',
                  color: _purple,
                  onTap: () {},
                ),
                _ActionTile(
                  icon: Icons.help_outline_rounded,
                  label: 'Bantuan',
                  color: _purple,
                  onTap: () {},
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // ── Account Section ─────────────────────────
            _sectionAction(
              title: 'Akun',
              tiles: [
                _ActionTile(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  color: Colors.red,
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),
            
            const SizedBox(height: 24),

            // Version info
            Text(
              'CleanGo v1.0.0',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: Colors.black26,
              ),
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void _confirmLogout(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Konfirmasi Keluar'),
      content: const Text(
        'Apakah Anda yakin ingin keluar dari akun ini?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginScreen(),
              ),
              (route) => false,
            );
          },
          child: const Text(
            'Keluar',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
```

#### Info & Action Sections
```dart
Widget _section({
  required String title,
  required List<_InfoItem> items,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(8),
          blurRadius: 8,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textGrey,
            ),
          ),
        ),
        ...items.asMap().entries.map((e) {
          return Column(
            children: [
              _buildInfoTile(e.value),
              if (e.key < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }),
      ],
    ),
  );
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _ActionTile {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
```

**Key Points**:
- Large avatar with border
- Info section with dividers
- Action tiles with icons
- Logout confirmation dialog
- Version display

---

## 🎨 HELPER FUNCTIONS

```dart
String _formatCurrency(int amount) {
  return amount
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

Widget _buildLabel(String label, {bool required = false}) {
  return Row(
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      if (required)
        const Text(
          ' *',
          style: TextStyle(color: Colors.red),
        ),
    ],
  );
}
```

---

**Document Version**: 6.0  
**Total Screens**: 4 detailed implementations  
**Code Examples**: 60+  
**Last Updated**: 2026-06-18