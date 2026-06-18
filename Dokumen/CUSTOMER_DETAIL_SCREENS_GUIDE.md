# 📚 PART 4: CUSTOMER DETAIL & CATALOG SCREENS

**Coverage**: Customer detail views and catalog browsing  
**Status**: Complete  
**Last Updated**: 2026-06-18

---

## 📑 TABLE OF CONTENTS

1. [Customer Main Navigation](#customer-main-navigation)
2. [Catalog Browsing](#catalog-browsing)
3. [Detail Views](#detail-views)
4. [Navigation Patterns](#navigation-patterns)

---

## 🏠 CUSTOMER MAIN NAVIGATION

### 1. customer_main_screen.dart

**Lokasi**: `/lib/screens/customer/customer_main_screen.dart`  
**Fungsi**: Main navigation hub dengan 5 tabs (Dashboard, Order, Booking, Pembayaran, Profil)  
**Pattern**: IndexedStack untuk tab switching

#### State Management
```dart
class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;  # Optional initial tab (default: 0 = Dashboard)

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  late int _currentIndex;     # Current active tab (0-4)
  static const Color _blue = Color(0xFF3B5BDB);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;  # Set initial tab if provided
  }
}
```

#### Tab Navigation with IndexedStack
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    // ── Main body: IndexedStack switches between tabs ──────
    body: IndexedStack(
      index: _currentIndex,                    # Currently visible tab
      children: const [
        CustomerDashboardScreen(),            # Tab 0: Dashboard
        CustomerOrderScreen(),                # Tab 1: Riwayat Order
        CustomerBookingCatalogScreen(),       # Tab 2: Booking Katalog
        CustomerPembayaranScreen(),           # Tab 3: Pembayaran
        CustomerProfilScreen(),               # Tab 4: Profil
      ],
    ),
    
    // ── Bottom navigation ──────────────────────────────────
    bottomNavigationBar: _buildBottomNav(),
  );
}
```

#### Bottom Navigation with Badges
```dart
Widget _buildBottomNav() {
  // Listen to orders real-time untuk badge count
  return StreamBuilder<List<OrderModel>>(
    stream: FirestoreService.streamOrdersForCurrentCustomer(),
    builder: (context, snapOrder) {
      final orders = snapOrder.data ?? [];

      // Count active orders (not selesai/dibatalkan)
      final countOrder = orders
          .where((o) =>
              o.status == OrderStatus.masuk ||
              o.status == OrderStatus.dijemput ||
              o.status == OrderStatus.perluTimbang ||
              o.status == OrderStatus.dicuci ||
              o.status == OrderStatus.disetrika ||
              o.status == OrderStatus.dikirim)
          .length;

      // Count pending payments (konfirmasiBayar & not paid)
      final countBayar = orders
          .where((o) =>
              o.status == OrderStatus.konfirmasiBayar && !o.isPaid)
          .length;

      // Build navbar with badge counts
      return _CustomerNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        countOrder: countOrder,             # Order badge
        countBayar: countBayar,             # Payment badge
        activeColor: _blue,
      );
    },
  );
}

class _CustomerNavBar extends StatelessWidget {
  const _CustomerNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.countOrder,
    required this.countBayar,
    required this.activeColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int countOrder;
  final int countBayar;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),  # Subtle shadow above
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20)  # Rounded top corners
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20)
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,  # Fixed height
          backgroundColor: Colors.white,
          selectedItemColor: activeColor,
          unselectedItemColor: const Color(0xFFB0B0B0),
          elevation: 0,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: [
            // Tab 0: Dashboard (no badge)
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            
            // Tab 1: Order with badge
            BottomNavigationBarItem(
              icon: _badge(Icons.description_outlined, countOrder),
              activeIcon: _badge(
                Icons.description_rounded,
                countOrder,
                active: true
              ),
              label: 'Order',
            ),
            
            // Tab 2: Booking (no badge)
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Booking',
            ),
            
            // Tab 3: Payment with badge
            BottomNavigationBarItem(
              icon: _badge(Icons.credit_card_outlined, countBayar),
              activeIcon: _badge(
                Icons.credit_card_rounded,
                countBayar,
                active: true
              ),
              label: 'Pembayaran',
            ),
            
            // Tab 4: Profile (no badge)
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // Badge widget overlay
  Widget _badge(IconData icon, int count, {bool active = false}) {
    return Stack(
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                count > 9 ? '9+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
```

**Key Points**:
- IndexedStack keeps all 5 screens in memory (fast switching)
- StreamBuilder untuk real-time badge updates
- Badge shows count of active orders & pending payments
- Rounded top corners untuk smooth appearance

---

## 🏪 CATALOG BROWSING

### 2. katalog_layanan_screen.dart

**Lokasi**: `/lib/screens/customer/katalog_layanan_screen.dart`  
**Fungsi**: Browse semua service catalog dengan search & filter  
**Features**: Real-time search, grid view, Firestore streaming

#### State Variables
```dart
class _KatalogLayananScreenState extends State<KatalogLayananScreen> {
  final _searchCtrl = TextEditingController();  # Search input
  String _query = '';                           # Current search query

  static const Color _blue = Color(0xFF3B5BDB);

  /// Convert KatalogModel → KatalogItem untuk kompatibilitas
  KatalogItem _toKatalogItem(KatalogModel m) => KatalogItem(
    id: m.id,
    nama: m.nama,
    satuan: m.satuan,
    harga: m.harga,
    estimasi: m.estimasi,
    deskripsi: m.deskripsi,
    aktif: m.aktif,
  );
}
```

#### Main Build with Search Bar
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    body: SafeArea(
      child: Column(
        children: [
          // ── Title ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Text(
              'Katalog Layanan',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),

          // ── Search + Filter Bar ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Search field
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                        hintText: 'Cari layanan laundry',
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
                ),
                
                const SizedBox(width: 10),
                
                // Filter button
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEEEEEE),
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.tune_rounded,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),

          // ── Grid dari Firestore ────────────────────
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Stream raw katalog data dari Firestore
              stream: FirestoreService.streamKatalogRaw(),
              builder: (context, snap) {
                // Error handling
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Gagal memuat katalog layanan: ${snap.error}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Loading state
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Convert raw data → KatalogModel
                final allItems = (snap.data ?? [])
                    .map((m) =>
                        KatalogModel.fromMap(m['id'] ?? '', m))
                    .where((k) => k.aktif)  # Filter active only
                    .toList();

                // Apply search filter
                final filtered = _query.isEmpty
                    ? allItems
                    : allItems
                        .where((k) => k.nama
                            .toLowerCase()
                            .contains(_query.toLowerCase()))
                        .toList();

                // Empty state
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada layanan ditemukan',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  );
                }

                // Display grid
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,          # 2 columns
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) =>
                      _buildServiceCard(context, filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildServiceCard(
  BuildContext context,
  KatalogModel service,
) {
  return GestureDetector(
    onTap: () {
      // Navigate to detail view
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DetailLayananScreen(item: _toKatalogItem(service)),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder image
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.dry_cleaning,
              size: 40,
              color: Color(0xFF3B5BDB),
            ),
          ),
          
          // Service info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nama,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp${service.harga}/${service.satuan}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B5BDB),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${service.estimasi}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Key Points**:
- Real-time Firestore stream dengan filter aktif
- Search menggunakan `.toLowerCase().contains()` untuk case-insensitive
- GridView 2-column layout
- Tap navigates to detail screen

---

## 🔍 DETAIL VIEWS

### 3. detail_layanan_screen.dart

**Lokasi**: `/lib/screens/customer/detail_layanan_screen.dart`  
**Fungsi**: Full detail view dari satu service dengan booking button  
**Data**: Receives `KatalogItem` as parameter

#### Build Method
```dart
class DetailLayananScreen extends StatelessWidget {
  const DetailLayananScreen({super.key, required this.item});

  final KatalogItem item;  # Service details

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
              // ── Title Bar ──────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    'Detail Layanan',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Image Placeholder ──────────────────────
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(height: 16),

              // ── Service Name + Price ───────────────────
              Text(
                item.nama,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              
              Text(
                'Rp${_formatHarga(item.harga)}/${item.satuan.toLowerCase()}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _blue,
                ),
              ),
              const SizedBox(height: 2),
              
              Text(
                'Estimasi ${item.estimasi}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black45,
                ),
              ),
              const SizedBox(height: 14),
              
              const Divider(color: Color(0xFFEEEEEE)),
              const SizedBox(height: 14),

              // ── Description Section ────────────────────
              Text(
                'Deskripsi',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
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

              // ── Keunggulan Section ──────────────────────
              Text(
                'Keunggulan',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              
              // Benefits list
              ..._buildKeunggulan([
                'Bersih & higenis',
                'Wangi tahan lama',
                'Free layanan antar jemput',
              ]),
              
              const SizedBox(height: 28),

              // ── Booking Button ─────────────────────────
              GestureDetector(
                onTap: () {
                  // Navigate to booking form with selected service
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
                  child: Text(
                    'Booking Sekarang',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

  // ── Build Benefits List ─────────────────────────────────
  List<Widget> _buildKeunggulan(List<String> items) {
    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: _blue,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // ── Format price for display ────────────────────────────
  String _formatHarga(int harga) {
    return harga
        .toString()
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
```

**Key Points**:
- StatelessWidget (no state needed)
- Passes service to BookingLaundryScreen when tapping booking button
- Formatted price display dengan thousand separator
- Benefits list dengan bullet points

---

### 4. customer_booking_catalog_screen.dart

**Lokasi**: `/lib/screens/customer/customer_booking_catalog_screen.dart`  
**Fungsi**: Browse katalog dan filter services untuk booking  
**Features**: Search + filter, grid view, local state management

#### State & Setup
```dart
class _CustomerBookingCatalogScreenState
    extends State<CustomerBookingCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<KatalogModel> _filteredServices = [];  # Filtered list
  List<KatalogModel> _allServices = [];       # All services

  @override
  void initState() {
    super.initState();
    _loadServices();
    // Listen to search changes
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadServices() {
    // Load dari local cache (FirestoreService.getKatalog())
    final services = FirestoreService.getKatalog();
    setState(() {
      _allServices = services;
      _filteredServices = services;
    });
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _allServices;  # Reset to all
      } else {
        // Filter by name or description
        _filteredServices = _allServices
            .where((service) =>
                service.nama.toLowerCase().contains(query) ||
                service.deskripsi.toLowerCase().contains(query))
            .toList();
      }
    });
  }
}
```

#### Build & Search Bar
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Katalog Layanan',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSearchBar(),
            const SizedBox(height: 20),
            
            _buildServiceGrid(),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSearchBar() {
  return Row(
    children: [
      Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari layanan laundry',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFFB0B0B0),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFFB0B0B0),
              ),
            ),
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ),
      ),
      const SizedBox(width: 12),
      // Filter button (placeholder)
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: IconButton(
          onPressed: () {},  # TODO: implement filter
          icon: const Icon(Icons.tune, color: Color(0xFFB0B0B0)),
        ),
      ),
    ],
  );
}

Widget _buildServiceGrid() {
  if (_filteredServices.isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Layanan tidak ditemukan',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.9,
    ),
    itemCount: _filteredServices.length,
    itemBuilder: (context, index) {
      final service = _filteredServices[index];
      return _buildServiceTile(context, service);
    },
  );
}

Widget _buildServiceTile(BuildContext context, KatalogModel service) {
  return GestureDetector(
    onTap: () {
      // Navigate to booking dengan pre-selected service
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BookingLaundryScreen(
            selectedItem: service,
          ),
        ),
      );
    },
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: const Icon(
              Icons.local_laundry_service,
              size: 40,
              color: Color(0xFFBB2BCD),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nama,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${service.harga}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B5BDB),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    service.estimasi,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
```

**Key Points**:
- Local state management (no Firestore stream)
- Search filters by name + description
- Tap navigates to booking with pre-selected service
- Grid layout with service previews

---

### 5. customer_profil_screen.dart

**Lokasi**: `/lib/screens/customer/customer_profil_screen.dart`  
**Fungsi**: Customer profile view dengan logout  
**Pattern**: StatelessWidget (read-only profile)

#### Build Method
```dart
class CustomerProfilScreen extends StatelessWidget {
  const CustomerProfilScreen({super.key});

  static const Color _blue = Color(0xFF3B5BDB);

  // Extract name from user
  String _displayName() {
    final user = FirestoreService.currentUser;
    final name = user?['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    // Fallback to email prefix
    final email = user?['email']?.toString().trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'Pengguna';
  }

  // Extract phone from user
  String _displayPhone() {
    final user = FirestoreService.currentUser;
    final phone = user?['phone']?.toString().trim();
    return (phone != null && phone.isNotEmpty) 
      ? phone 
      : 'Tidak ada nomor';
  }

  // Get first letter for avatar
  String _displayInitial() {
    final name = _displayName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'C';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profil Saya',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // ── Profile Card ───────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                    // Avatar with initial
                    Container(
                      width: 60,
                      height: 60,
                      decoration: const BoxDecoration(
                        color: _blue,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _displayInitial(),
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 14),
                    
                    // Name + Phone
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayName(),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            _displayPhone(),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),

              // ── Menu Items ──────────────────────────────
              _buildMenuItem(Icons.location_on_outlined, 'Alamat Saya'),
              _buildMenuItem(Icons.history_rounded, 'Riwayat Order'),
              _buildMenuItem(Icons.notifications_outlined, 'Notifikasi'),
              _buildMenuItem(Icons.help_outline_rounded, 'Bantuan'),
              _buildMenuItem(Icons.settings_outlined, 'Pengaturan'),
              
              const SizedBox(height: 12),

              // ── Logout Button ────────────────────────────
              GestureDetector(
                onTap: () {
                  // Navigate back to login screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,  # Remove all routes
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFCDD2),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Keluar',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String label) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF666666)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Color(0xFFCCCCCC),
          ),
        ],
      ),
    );
  }
}
```

**Key Points**:
- Reads from FirestoreService.currentUser
- Fallback values for missing data
- Menu items are placeholders (not implemented)
- Logout with pushAndRemoveUntil to clear all routes

---

### 6. customer_pembayaran_screen.dart

**Lokasi**: `/lib/screens/customer/customer_pembayaran_screen.dart`  
**Fungsi**: Show pending payment invoices  
**Pattern**: StreamBuilder untuk real-time invoices

#### Build with StreamBuilder
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bayar',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 16),

            // ── Tagihan list ────────────────────────────
            StreamBuilder<List<OrderModel>>(
              // Stream orders dengan status konfirmasiBayar
              stream: FirestoreService
                  .streamOrdersForCurrentCustomer(),
              builder: (context, snap) {
                // Error state
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Gagal memuat data pembayaran: ${snap.error}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.redAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                // Loading state
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Filter to pending payments only
                final tagihan = (snap.data ?? [])
                    .where((o) =>
                        o.status == OrderStatus.konfirmasiBayar &&
                        !o.isPaid)
                    .toList();

                // Empty state
                if (tagihan.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Text(
                        'Tidak ada tagihan saat ini',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black38,
                        ),
                      ),
                    ),
                  );
                }

                // Display invoices
                return Column(
                  children: tagihan
                      .map((o) => _buildTagihanCard(context, o))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTagihanCard(BuildContext context, OrderModel order) {
  final dateStr = DateFormat('d MMMM yyyy', 'id')
      .format(order.pickupDate);
  final berat = order.beratKg ?? 0;
  final total = (order.totalHarga ?? berat * 7000).round();

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.id,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.serviceType} - ${berat.toStringAsFixed(0)}kg',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Rp${_formatHarga(total)}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to payment detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => 
                    DetailPembayaranScreen(order: order),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF3B5BDB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Bayar',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String _formatHarga(int harga) {
  return harga
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}
```

**Key Points**:
- Filters to konfirmasiBayar + not paid
- Shows invoice card with amount + date
- Tap navigates to payment detail screen
- Real-time updates via StreamBuilder

---

## 🔄 NAVIGATION PATTERNS

### Common Navigation Flow
```
CustomerMainScreen (5 tabs)
├─ Dashboard
├─ Order History → Detail Order → Edit Order
├─ Booking Catalog → Katalog Layanan
│                  ├─ Detail Layanan → Booking Form
│                  └─ Booking Form → Confirmation
├─ Payment → Detail Pembayaran
└─ Profile → Logout → Login
```

### Parameter Passing
```dart
// Pass model to detail screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DetailScreen(item: model),
  ),
);

// Pass model with optional callback
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => EditScreen(
      order: order,
      onSaved: () => setState(() {}),
    ),
  ),
);

// Pop with result
Navigator.pop(context, true);  // Signal success
```

---

**Document Version**: 4.0  
**Total Screens**: 6 detailed implementations  
**Code Examples**: 80+  
**Last Updated**: 2026-06-18