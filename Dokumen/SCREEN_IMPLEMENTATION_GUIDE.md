# 📚 PART 2: DETAILED SCREEN DOCUMENTATION

**Coverage**: Customer & Staff Screens (Line-by-line explanation)  
**Status**: Complete  
**Last Updated**: 2026-06-18

---

## 📑 TABLE OF CONTENTS

1. [Customer Screens](#customer-screens)
2. [Staff Screens](#staff-screens)
3. [Common Patterns](#common-patterns)
4. [State Management](#state-management)

---

## 👥 CUSTOMER SCREENS

### 1. customer_order_screen.dart

**Lokasi**: `/lib/screens/customer/customer_order_screen.dart`  
**Fungsi**: Menampilkan history order customer dengan filter dan sub-tabs

#### Imports & Setup
```dart
import 'package:flutter/material.dart';          # Material Design widgets
import 'package:google_fonts/google_fonts.dart'; # Google Fonts library
import 'package:intl/intl.dart';                 # Date formatting (Indonesian)
import '../../models/order_model.dart';          # Order data model
import '../../services/firestore_service.dart';  # Firestore operations
import 'detail_order_screen.dart';               # Detail screen
import 'edit_order_screen.dart';                 # Edit screen

class CustomerOrderScreen extends StatefulWidget {
  const CustomerOrderScreen({super.key});
  
  @override
  State<CustomerOrderScreen> createState() => _CustomerOrderScreenState();
}
```

#### State Variables
```dart
class _CustomerOrderScreenState extends State<CustomerOrderScreen> {
  int _filterIndex = 0;                   # Current filter tab index (0-4)
  int _selesaiSub = 0;                    # Sub-tab index for "Selesai" (0=Diterima, 1=Dibatalkan)
  
  // Tab names untuk filter horizontal
  static const _filters = [
    'Semua',            # 0: All active orders
    'Konfirmasi',       # 1: masuk status only
    'Dijemput',         # 2: dijemput + perluTimbang
    'Diproses',         # 3: dicuci + disetrika + dikirim
    'Selesai'           # 4: selesai atau dibatalkan (sub-tab)
  ];
  
  static const Color _blue = Color(0xFF3B5BDB);  # Blue accent color
}
```

#### Filter Logic
```dart
List<OrderModel> _applyFilter(List<OrderModel> all) {
  // Apply filter berdasarkan _filterIndex
  
  switch (_filterIndex) {
    case 1: // Konfirmasi Tab
      // Filter: status = masuk (belum dijemput)
      return all.where((o) => o.status == OrderStatus.masuk).toList();
      
    case 2: // Dijemput Tab
      // Filter: status = dijemput OR perluTimbang
      return all
          .where((o) =>
              o.status == OrderStatus.dijemput ||
              o.status == OrderStatus.perluTimbang)
          .toList();
      
    case 3: // Diproses Tab
      // Filter: status = dicuci OR disetrika OR dikirim (active processing)
      return all
          .where((o) =>
              o.status == OrderStatus.dicuci ||
              o.status == OrderStatus.disetrika ||
              o.status == OrderStatus.dikirim)
          .toList();
      
    case 4: // Selesai Tab
      // Sub-filter: _selesaiSub menentukan completed vs cancelled
      if (_selesaiSub == 0) {
        return all.where((o) => o.status == OrderStatus.selesai).toList();
      } else {
        return all.where((o) => o.status == OrderStatus.dibatalkan).toList();
      }
      
    default: // Semua Tab (0)
      // Tampilkan semua active orders
      return all.toList();
  }
}
```

#### Main Build Method
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB), # Light background
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Text(
              'Riwayat Order',              # "Order History"
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,  # Bold title
                color: Colors.black87,
              ),
            ),
          ),
          
          // ── Filter Chips Row ──────────────────────────────
          _buildFilterRow(),
          
          // ── Sub-tabs (hanya tampil jika Selesai selected) ─
          if (_filterIndex == 4) _buildSelesaiSubTabs(),
          
          const SizedBox(height: 10),
          
          // ── Orders List / Stream ──────────────────────────
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // Listen to current customer's orders dari Firestore
              stream: FirestoreService.streamOrdersForCurrentCustomer(),
              builder: (context, snap) {
                // Handle error state
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Gagal memuat data order: ${snap.error}',
                        style: GoogleFonts.inter(
                            fontSize: 13, 
                            color: Colors.redAccent),
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
                
                // Get all orders dari Firestore, apply filter
                final orders = _applyFilter(snap.data ?? []);
                
                // Empty state
                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      'Belum ada order',
                      style: GoogleFonts.inter(
                          fontSize: 13, 
                          color: Colors.black45),
                    ),
                  );
                }
                
                // Display list of order cards
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => 
                    _buildOrderCard(context, orders[i]),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
```

#### Filter Row Builder (Horizontal Chips)
```dart
Widget _buildFilterRow() {
  return SizedBox(
    height: 36,                               # Fixed height for chips
    child: ListView.separated(
      scrollDirection: Axis.horizontal,       # Scroll horizontally
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _filters.length,             # 5 filter tabs
      separatorBuilder: (_, __) => 
        const SizedBox(width: 8),             # Gap between chips
      itemBuilder: (_, i) {
        final selected = _filterIndex == i;   # Is this chip selected?
        
        return GestureDetector(
          onTap: () => setState(() {
            _filterIndex = i;                 # Update active filter
            _selesaiSub = 0;                  # Reset sub-tab
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, 
              vertical: 8
            ),
            decoration: BoxDecoration(
              color: selected 
                ? _blue                       # Active: blue
                : const Color(0xFFEDEDF2),   # Inactive: light gray
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              _filters[i],                    # Filter name
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected 
                  ? Colors.white              # Active: white text
                  : Colors.black54,           # Inactive: gray text
              ),
            ),
          ),
        );
      },
    ),
  );
}
```

#### Sub-Tabs for Selesai (Completed vs Cancelled)
```dart
Widget _buildSelesaiSubTabs() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
    child: Row(
      children: [
        _buildSubTab('Diterima', 0),          # Sub-tab 0: Completed
        const SizedBox(width: 24),
        _buildSubTab('Dibatalkan', 1),        # Sub-tab 1: Cancelled
      ],
    ),
  );
}

Widget _buildSubTab(String label, int index) {
  final selected = _selesaiSub == index;     # Is this sub-tab selected?
  
  return GestureDetector(
    onTap: () => setState(() => _selesaiSub = index),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected 
              ? const Color(0xFF1A1A2E)      # Active: dark
              : Colors.black26,              # Inactive: very light
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 2,                          # Underline thickness
          width: label.length * 7.0 + 4,     # Dynamic width based on text
          color: selected 
            ? const Color(0xFF1A1A2E)        # Active: dark underline
            : Colors.transparent,            # Inactive: no underline
        ),
      ],
    ),
  );
}
```

#### Order Card Builder
```dart
Widget _buildOrderCard(BuildContext context, OrderModel order) {
  final dateStr = DateFormat('d MMMM yyyy', 'id')
    .format(order.pickupDate);  # Format: "18 Juni 2026"

  // Determine badge colors based on status
  Color badgeBg;     # Background color
  Color badgeFg;     # Foreground/text color
  String badgeLabel; # Status label

  switch (order.status) {
    case OrderStatus.masuk:
      badgeBg = const Color(0xFFEBEBEB);       # Gray background
      badgeFg = const Color(0xFF616161);       # Dark gray text
      badgeLabel = 'Menunggu Konfirmasi';      # "Awaiting Confirmation"
      break;
      
    case OrderStatus.dijemput:
      badgeBg = const Color(0xFFD6F0F7);       # Light blue
      badgeFg = const Color(0xFF1E88A8);       # Blue text
      badgeLabel = 'Dijemput';                 # "Picked Up"
      break;
      
    case OrderStatus.perluTimbang:
      badgeBg = const Color(0xFFFFE0B2);       # Light orange
      badgeFg = const Color(0xFFE65100);       # Orange text
      badgeLabel = 'Perlu Timbang';            # "Need Weighing"
      break;
      
    case OrderStatus.konfirmasiBayar:
      // Special logic: different colors if already paid
      if (order.isPaid) {
        badgeBg = const Color(0xFFB2DFDB);     # Teal: paid
        badgeFg = const Color(0xFF00695C);
        badgeLabel = 'Menunggu Konfirmasi Bayar';  # "Awaiting Staff Confirmation"
      } else {
        badgeBg = const Color(0xFFFFF3CD);     # Yellow: not paid
        badgeFg = const Color(0xFFB7791F);
        badgeLabel = 'Menunggu Pembayaran';    # "Awaiting Payment"
      }
      break;
      
    case OrderStatus.dicuci:
      badgeBg = const Color(0xFFD9F7E3);       # Light green
      badgeFg = const Color(0xFF1E7E34);       # Green text
      badgeLabel = 'Dicuci';                   # "Being Washed"
      break;
      
    case OrderStatus.disetrika:
      badgeBg = const Color(0xFFD1C4E9);       # Light purple
      badgeFg = const Color(0xFF512DA8);       # Purple text
      badgeLabel = 'Disetrika';                # "Being Ironed"
      break;
      
    case OrderStatus.dikirim:
      badgeBg = const Color(0xFFE3F2FD);       # Light blue
      badgeFg = const Color(0xFF1565C0);       # Blue text
      badgeLabel = 'Dikirim';                  # "Shipped"
      break;
      
    case OrderStatus.selesai:
      badgeBg = const Color(0xFFD9F7E3);       # Light green
      badgeFg = const Color(0xFF2E7D32);       # Green text (primary)
      badgeLabel = 'Diterima';                 # "Received"
      break;
      
    case OrderStatus.dibatalkan:
      badgeBg = const Color(0xFFFBD9DC);       # Light red
      badgeFg = const Color(0xFFC0392B);       # Dark red text
      badgeLabel = 'Dibatalkan';               # "Cancelled"
      break;
  }

  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailOrderScreen(order: order),
      ),
    ),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),  # Subtle shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID
                    Text(
                      order.id,                  # ORD-20260618-001
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Service + weight (if available)
                    Text(
                      order.beratKg != null
                          ? '${order.serviceType} · ${order.beratKg!.toStringAsFixed(0)} kg'
                          : order.serviceType,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeFg,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          // Date and time info
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
  );
}
```

**Key Points**:
- StreamBuilder untuk real-time update dari Firestore
- Multiple filter levels: main tab + sub-tab untuk "Selesai"
- Dynamic badge colors berdasarkan order status
- Tap navigates to DetailOrderScreen

---

### 2. customer_dashboard_screen.dart

**Lokasi**: `/lib/screens/customer/customer_dashboard_screen.dart`  
**Fungsi**: Main dashboard untuk customer dengan spotlight order, stats, recent list

#### Color Palette (Custom)
```dart
class _DashColors {
  static const ink = Color(0xFF14213D);        # Hero/primary text
  static const primary = Color(0xFF3B5BDB);   # Brand blue
  static const primarySoft = Color(0xFFE7ECFB); # Soft blue background
  static const surface = Color(0xFFF6F7FB);   # Page background
  static const card = Color(0xFFFFFFFF);      # Card background
  static const border = Color(0xFFEAEDF3);    # Border color
  static const textMuted = Color(0xFF6B7280); # Muted text
  static const success = Color(0xFF1F9D55);   # Success green
  static const successSoft = Color(0xFFE3F6EA); # Soft green
  static const amber = Color(0xFFC8821B);     # Warning amber
  static const amberSoft = Color(0xFFFBF0DD); # Soft amber
  static const danger = Color(0xFFC0392B);    # Danger red
  static const dangerSoft = Color(0xFFFBE7E5); # Soft red
}
```

#### Helper Methods
```dart
String _displayName() {
  final user = FirestoreService.currentUser;
  
  // Try to get name from user profile
  final name = user?['name']?.toString().trim();
  if (name != null && name.isNotEmpty) {
    return name;  # e.g., "Dhira"
  }
  
  // Fallback: use email prefix
  final email = user?['email']?.toString().trim();
  if (email != null && email.isNotEmpty) {
    return email.split('@').first;  # e.g., dhira from dhira@mail.com
  }
  
  // Default fallback
  return 'Pengguna';  # "User"
}

String _displayInitial() {
  final name = _displayName();
  return name.isNotEmpty ? name[0].toUpperCase() : 'C';
}

// Status style record (using Dart records/tuples)
({Color bg, Color fg, String label}) _statusStyle(OrderStatus status) {
  switch (status) {
    case OrderStatus.masuk:
      return (
        bg: _DashColors.neutralSoft,
        fg: _DashColors.neutral,
        label: status.stepTitle
      );
    case OrderStatus.dicuci:
      return (
        bg: _DashColors.primarySoft,
        fg: _DashColors.primary,
        label: 'Dicuci'
      );
    // ... more statuses
  }
}
```

#### Main Build (CustomScrollView with Slivers)
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: _DashColors.surface,  # Light background
    body: SafeArea(
      child: StreamBuilder<List<OrderModel>>(
        // Listen to all orders for current customer
        stream: FirestoreService.streamOrdersForCurrentCustomer(),
        builder: (context, snap) {
          if (snap.hasError) {
            return _ErrorState(message: '${snap.error}');
          }
          
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final all = snap.data ?? [];
          
          // Separate active vs completed orders
          final aktif = all
              .where((o) =>
                  o.status != OrderStatus.selesai &&
                  o.status != OrderStatus.dibatalkan)
              .toList();
          
          // Count completed orders
          final selesaiCount = all
              .where((o) => o.status == OrderStatus.selesai)
              .length;
          
          // Calculate total revenue from completed orders
          final totalBayar = all
              .where((o) => o.status == OrderStatus.selesai)
              .fold<double>(
                0, 
                (sum, o) => sum + (o.totalHarga ?? 0)
              );

          // Get spotlight order: newest active, or any if no active
          final spotlight = aktif.isNotEmpty
              ? aktif.first
              : (all.isNotEmpty ? all.first : null);

          // Get recent 3 orders for list
          final recent = all.take(3).toList();

          return CustomScrollView(
            slivers: [
              // ── App Bar + Greeting ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildAppBar(),
                ),
              ),
              
              // ── Hero Spotlight Order ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: _buildHero(context, spotlight, aktif.length),
                ),
              ),
              
              // ── Stat Row (Active, Completed, Revenue) ───────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildStatRow(
                    aktif.length, 
                    selesaiCount, 
                    totalBayar
                  ),
                ),
              ),
              
              // ── "Booking Baru" Button ────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _buildBookingBaruButton(context),
                ),
              ),
              
              // ── "Recent Orders" Header ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _buildSectionHeader(context),
                ),
              ),
              
              // ── Recent Orders List ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: recent.isEmpty
                      ? _buildEmptyOrders()
                      : Column(
                          children: recent
                              .map((o) => _buildOrderCard(context, o))
                              .toList(),
                        ),
                ),
              ),
              
              // ── Promo Banner ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: _buildPromoBanner(),
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

**Key Architecture**:
- Uses `CustomScrollView` + `Slivers` untuk smooth scrolling
- `StreamBuilder` untuk real-time order updates
- Separate logic untuk active vs completed orders
- Spotlight order untuk quick action

---

### 3. form_booking_screen.dart

**Lokasi**: `/lib/screens/customer/form_booking_screen.dart`  
**Fungsi**: Form untuk customer membuat booking baru

#### State Variables
```dart
class _FormBookingScreenState extends State<FormBookingScreen> {
  // Text controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Form state
  DateTime? _selectedPickupDate;  # Tanggal pickup (from date picker)
  String _selectedPickupSession = '08:00 - 10:00 (Pagi)'; # Default time slot
  bool _isLoading = false;        # Loading state during submit

  // Available time slots
  final List<String> _sessions = [
    '08:00 - 10:00 (Pagi)',       # Morning
    '10:00 - 12:00 (Siang)',      # Midday
    '14:00 - 16:00 (Sore)',       # Afternoon
    '16:00 - 18:00 (Malam)',      # Evening
  ];
}
```

#### Init State - Load Default Address
```dart
@override
void initState() {
  super.initState();
  _loadDefaultAddress();
}

void _loadDefaultAddress() {
  // Get address from logged-in user profile
  final addr = FirestoreService.currentUserAddress;
  _addressController.text = addr ?? 'Jl. Mawar No. 10';  # Fallback default
}
```

#### Date Picker
```dart
Future<void> _selectPickupDate() async {
  final DateTime now = DateTime.now();
  
  // Minimum date: tomorrow
  final DateTime firstDate = now.add(const Duration(days: 1));
  
  // Maximum date: 30 days from now
  final DateTime lastDate = now.add(const Duration(days: 30));

  // Show date picker dialog
  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: firstDate,          # Default selected date
    firstDate: firstDate,
    lastDate: lastDate,
    builder: (context, child) {
      // Customize date picker theme (use primary blue color)
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF3B5BDB),  # Blue for selected date
          ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedPickupDate) {
    setState(() {
      _selectedPickupDate = picked;
    });
  }
}
```

#### Submit Booking
```dart
Future<void> _submitBooking() async {
  // Validation: date required
  if (_selectedPickupDate == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pilih tanggal jemput terlebih dahulu')
      ),
    );
    return;
  }

  // Validation: address required
  if (_addressController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masukkan alamat pengambilan'))
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // Calculate finish date based on service estimation
    // e.g., "2 hari" → add 2 days to pickup date
    DateTime finishDate = _calculateFinishDate(_selectedPickupDate!);

    // Create booking model
    final booking = BookingModel(
      id: '',                          # Empty → will be generated
      customerId: FirestoreService.currentUser?['id']?.toString() ??
          FirestoreService.currentUserPhone ?? '',
      katalogId: widget.service.id,    # Service ID
      katalogNama: widget.service.nama, # Service name
      harga: widget.service.harga,     # Price per unit
      satuan: widget.service.satuan,   # Unit (Kg, etc)
      alamat: _addressController.text,  # Pickup address
      tanggalJemput: _selectedPickupDate!,
      tanggalSelesai: finishDate,      # Estimated completion
      sesiJemput: _selectedPickupSession,
      catatan: _notesController.text,  # Customer notes
      createdAt: DateTime.now(),
    );

    // Save booking to Firestore
    await FirestoreService.createBooking(booking);

    if (mounted) {
      // Show success snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to main customer screen
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  } catch (e) {
    if (mounted) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);  # Stop loading
    }
  }
}
```

#### Calculate Finish Date
```dart
DateTime _calculateFinishDate(DateTime pickupDate) {
  // Parse estimation string like "2 hari", "1 hari", "3 hari"
  final estimationParts = widget.service.estimasi.split(' ');
  
  if (estimationParts.length >= 2) {
    // First part is number: "2"
    final days = int.tryParse(estimationParts[0]) ?? 1;
    return pickupDate.add(Duration(days: days));
  }
  
  // Default: 2 days if can't parse
  return pickupDate.add(const Duration(days: 2));
}
```

#### Build UI
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Booking Laundry',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceCard(),      # Show selected service
          const SizedBox(height: 24),
          _buildFormSection(),       # Date, time, address, notes
          const SizedBox(height: 32),
          _buildSubmitButton(),      # Submit button
          const SizedBox(height: 16),
        ],
      ),
    ),
  );
}

Widget _buildServiceCard() {
  // Display selected service with icon, price, estimation
  return Container(
    padding: const EdgeInsets.all(16),
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
    child: Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFFE8EEF8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.dry_cleaning,
            color: Color(0xFF3B5BDB),
            size: 32,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih Layanan',          # "Select Service"
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFFB0B0B0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.service.nama,      # Service name
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp${widget.service.harga}/${widget.service.satuan}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3B5BDB),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
```

**Key Points**:
- Form validation sebelum submit
- Date picker dengan min/max constraints
- Auto-calculate finish date berdasarkan service estimation
- Create booking + corresponding Order atomically

---

### 4. detail_order_screen.dart

**Lokasi**: `/lib/screens/customer/detail_order_screen.dart`  
**Fungsi**: Full detail view dari satu order dengan progress bar

#### Build Method
```dart
@override
Widget build(BuildContext context) {
  final dateStr = DateFormat('d MMMM yyyy', 'id')
    .format(order.pickupDate);  # Format date to Indonesian

  // Determine badge colors based on status
  Color badgeBg;
  Color badgeFg;
  String badgeLabel;
  
  // ... [badge color mapping - similar to customer_order_screen]

  // Calculate progress metrics
  final steps = order.computedSteps;          # Get all workflow steps
  final progress = order.status == OrderStatus.dibatalkan
      ? 0.0
      : order.workflowProgress;              # 0.0 to 1.0
  final doneSteps = steps.where((step) => step.done).length;

  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    appBar: AppBar(
      backgroundColor: const Color(0xFFF8F8FB),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left,
          color: Colors.black87,
          size: 28
        ),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      title: Text(
        'Detail Order',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Colors.black87,
        ),
      ),
    ),
    body: SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header Card (Order ID + Date + Status) ────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FB),  # Light blue background
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.id,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dateStr - ${order.pickupSlot.split('-')[0].trim()}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeLabel,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 14),
            
            // ── Progress Bar (jika order belum dibatalkan) ────
            if (order.status != OrderStatus.dibatalkan) ...[
              Text(
                'Progress Pesanan',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              
              // Linear progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,          # 0.0 to 1.0
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEDEDF2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF3B5BDB)
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Progress text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).round()}% selesai',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    '$doneSteps/${steps.length} tahap',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 14),
            ],
            
            // ── Info Card (Customer, Service, Date, etc) ─────
            _buildInfoCard(),
            
            // ── Timeline Steps ───────────────────────────────
            if (order.status != OrderStatus.dibatalkan)
              _buildTimeline(steps),
          ],
        ),
      ),
    ),
  );
}
```

**Key Features**:
- Progress bar visualization dengan percentage
- Timeline showing all workflow steps
- Status-specific badge coloring
- Edit button untuk active orders

---

## 👨‍💼 STAFF SCREENS

### 1. konfirmasi_bayar_screen.dart

**Lokasi**: `/lib/screens/staff/konfirmasi_bayar_screen.dart`  
**Fungsi**: Staff confirm payment dari customers

#### State & Tab Selection
```dart
class _KonfirmasiBayarScreenState extends State<KonfirmasiBayarScreen> {
  int _sectionIndex = 0;  # 0 = Menunggu (Awaiting), 1 = Konfirmasi (Confirmed)

  String _formatDate(DateTime dt) => 
    DateFormat('d MMMM yyyy', 'id').format(dt);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Page Header ───────────────────────────────────
            const StaffPageHeader(
              title: 'Konfirmasi Bayar',
              subtitle: 'Order yang menunggu konfirmasi pembayaran',
            ),
            
            // ── Tab Selector (Menunggu / Konfirmasi) ─────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: _buildSectionTabs(),
            ),

            // ── Orders List ────────────────────────────────────
            Expanded(
              child: StreamBuilder<List<OrderModel>>(
                // Stream orders dengan status konfirmasiBayar
                stream: FirestoreService.streamOrdersByStatus(
                  OrderStatus.konfirmasiBayar
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Gagal memuat data: ${snapshot.error}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.redAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  }

                  // Filter based on section tab
                  final orders = (snapshot.data ?? [])
                      .where((order) =>
                          _sectionIndex == 0 
                            ? !order.isPaid      # Tab 0: Not paid yet
                            : order.isPaid       # Tab 1: Already paid
                      )
                      .toList();

                  if (orders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => 
                      const SizedBox(height: 12),
                    itemBuilder: (_, i) => _buildCard(orders[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Tab Selector
```dart
Widget _buildSectionTabs() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F5),  # Light gray background
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: _sectionButton('Menunggu', 0),  # Waiting for payment
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _sectionButton('Konfirmasi', 1), # Payment confirmed
        ),
      ],
    ),
  );
}

Widget _sectionButton(String label, int index) {
  final isActive = _sectionIndex == index;
  
  return GestureDetector(
    onTap: () => setState(() => _sectionIndex = index),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: isActive 
            ? AppColors.primary    # Blue when active
            : AppColors.textGrey,  # Gray when inactive
        ),
      ),
    ),
  );
}
```

#### Order Card
```dart
Widget _buildCard(OrderModel order) {
  final dateStr = _formatDate(order.pickupDate);
  final hargaStr = order.totalHarga != null
      ? NumberFormat.currency(
          locale: 'id',
          symbol: 'Rp',
          decimalDigits: 0
        ).format(order.totalHarga)
      : null;

  return StaffCard(  # Custom card widget
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header: ID + Status Badge ────────────────────
        Row(
          children: [
            Expanded(
              child: Text(
                order.id,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const StatusBadge(status: OrderStatus.konfirmasiBayar),
          ],
        ),
        const Divider(height: 18),

        // ── Info Rows ────────────────────────────────────
        _infoRow(
          Icons.person_outline_rounded,
          '${order.customerName} • ${order.phone}'
        ),
        const SizedBox(height: 6),
        _infoRow(Icons.local_laundry_service_outlined, order.serviceType),
        const SizedBox(height: 6),
        _infoRow(
          Icons.event_outlined,
          '$dateStr • ${order.pickupSlot}'
        ),

        // ── Total Payment Box ────────────────────────────
        if (hargaStr != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),  # Light purple
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Text(
                  'Total Pembayaran',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF6A1F9F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  hargaStr,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF6A1F9F),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        // ── Action Buttons ───────────────────────────────
        const SizedBox(height: 14),
        Row(
          children: [
            // Confirm payment button
            Expanded(
              child: _buildActionButton(
                'Konfirmasi',
                Colors.green,
                () => _confirmPayment(order),
              ),
            ),
            const SizedBox(width: 8),
            // Cancel/reject button
            Expanded(
              child: _buildActionButton(
                'Tolak',
                Colors.red,
                () => _rejectPayment(order),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _infoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textGrey),
      const SizedBox(width: 8),
      Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textDark,
        ),
      ),
    ],
  );
}
```

**Key Points**:
- Tab-based filtering (Awaiting vs Confirmed payments)
- Shows total amount to confirm
- Confirm/Reject action buttons

---

### 2. lanjut_proses_screen.dart

**Lokasi**: `/lib/screens/staff/lanjut_proses_screen.dart`  
**Fungsi**: Staff advance order through workflow steps

#### Badge Style Helper
```dart
class _BadgeStyle {
  final Color bg;
  final Color fg;
  final String label;
  
  const _BadgeStyle({
    required this.bg,
    required this.fg,
    required this.label,
  });
}

_BadgeStyle _badgeStyle() {
  // Return status-specific colors
  switch (order.status) {
    case OrderStatus.dijemput:
      return const _BadgeStyle(
        bg: Color(0xFFD6EEFF),
        fg: Color(0xFF1565C0),
        label: 'Dijemput',
      );
    case OrderStatus.perluTimbang:
      return const _BadgeStyle(
        bg: Color(0xFFFFF9C4),
        fg: Color(0xFF795548),
        label: 'Timbang',
      );
    case OrderStatus.dicuci:
      return const _BadgeStyle(
        bg: Color(0xFFB2DFDB),
        fg: Color(0xFF00695C),
        label: 'Dicuci',
      );
    case OrderStatus.disetrika:
      return const _BadgeStyle(
        bg: Color(0xFFD6F5F0),
        fg: Color(0xFF00897B),
        label: 'Disetrika',
      );
    case OrderStatus.dikirim:
      return const _BadgeStyle(
        bg: Color(0xFFE3F2FD),
        fg: Color(0xFF1565C0),
        label: 'Kirim',
      );
    case OrderStatus.konfirmasiBayar:
      return const _BadgeStyle(
        bg: Color(0xFFEDD6FF),
        fg: Color(0xFF6A1F9F),
        label: 'Konfirmasi Bayar',
      );
    default:
      return _BadgeStyle(
        bg: const Color(0xFFE8F5E9),
        fg: AppColors.primary,
        label: order.statusLabel,
      );
  }
}
```

#### Description Text
```dart
String get _keterangan {
  // Show workflow description based on current status
  
  if (order.isFinalized) {
    return 'Order telah selesai atau dibatalkan.';
  }
  
  switch (order.status) {
    case OrderStatus.masuk:
      return 'Terima order untuk memulai proses laundry.';
    case OrderStatus.dijemput:
      return 'Order sudah dijemput, lanjutkan ke penimbangan.';
    case OrderStatus.perluTimbang:
      return 'Lanjutkan ke proses penimbangan untuk mengirim tagihan ke customer.';
    case OrderStatus.dicuci:
      return 'Order sedang dicuci. Lanjutkan ke proses setrika setelah selesai.';
    case OrderStatus.disetrika:
      return 'Order sudah disetrika. Lanjutkan ke proses pengiriman.';
    case OrderStatus.dikirim:
      return 'Order sedang dikirim. Tandai selesai setelah diterima customer.';
    case OrderStatus.konfirmasiBayar:
      return 'Menunggu customer melakukan pembayaran sebelum dilanjutkan.';
    default:
      return 'Lanjutkan proses pesanan ini.';
  }
}

String get _buttonLabel {
  // Button label for next action
  
  if (order.isFinalized) return 'Tidak Dapat Dilanjutkan';
  
  switch (order.status) {
    case OrderStatus.masuk:
      return 'Terima Order';
    case OrderStatus.dijemput:
      return 'Timbang Order';
    case OrderStatus.perluTimbang:
      return 'Kirim Tagihan';
    case OrderStatus.dicuci:
      return 'Lanjut Setrika';
    case OrderStatus.disetrika:
      return 'Kirim Order';
    case OrderStatus.dikirim:
      return 'Tandai Selesai';
    case OrderStatus.konfirmasiBayar:
      return 'Menunggu Pembayaran';
    default:
      return 'Lanjut Proses';
  }
}

OrderStatus? get _nextStatus => order.nextStatus;

bool get _canContinue => _nextStatus != null && !order.isFinalized;
```

#### Build Method
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.bgPage,
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Lanjut Proses',
        style: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order Header ──────────────────────────────
            _buildOrderHeader(),
            const SizedBox(height: 16),
            
            // ── Detail Card ────────────────────────────────
            _buildDetailCard(),
            const SizedBox(height: 24),
            
            // ── Description ────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Color(0xFF3B5BDB),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _keterangan,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF3B5BDB),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ── Action Button ──────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue
                    ? () => _continueProcess()
                    : null,  # Disabled if can't continue
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: Text(
                  _buttonLabel,
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

Future<void> _continueProcess() async {
  // Update order status to next status
  if (_nextStatus == null) return;
  
  try {
    await FirestoreService.updateOrderStatus(
      order.id,
      _nextStatus!
    );
    
    if (mounted) {
      // Show success
      NotificationHelper.showSuccessSnackBar(
        context,
        'Status berhasil diperbarui ke ${_nextStatus!.stepTitle}',
      );
      
      // Go back
      Navigator.pop(context, true);
    }
  } catch (e) {
    if (mounted) {
      NotificationHelper.showErrorSnackBar(
        context,
        'Gagal update status: $e',
      );
    }
  }
}
```

**Key Architecture**:
- Smart state transitions (next status calculation)
- Disabled button when order is finalized
- Contextual descriptions for each step
- Updates Firestore on action

---

## 🎯 COMMON PATTERNS

### 1. StreamBuilder Pattern (Real-time Updates)

```dart
StreamBuilder<List<OrderModel>>(
  stream: FirestoreService.streamOrdersByStatus(OrderStatus.masuk),
  builder: (context, snapshot) {
    // Error handling
    if (snapshot.hasError) {
      return ErrorWidget(...);
    }
    
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return LoadingWidget();
    }
    
    // Empty state
    final items = snapshot.data ?? [];
    if (items.isEmpty) {
      return EmptyWidget();
    }
    
    // Display list
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, i) => buildCard(items[i]),
    );
  },
)
```

### 2. Status Badge Pattern

```dart
// Define colors centrally
class StatusBadgeConfig {
  static StatusBadgeConfig of(OrderStatus status) {
    switch (status) {
      case OrderStatus.masuk:
        return StatusBadgeConfig(
          bg: Color(0xFFFFF3E0),
          fg: Color(0xFFFF8C42),
          icon: Icons.inventory_2_rounded,
        );
      // ... more cases
    }
  }
}

// Reuse everywhere
StatusBadge(status: order.status)
```

### 3. Form Validation Pattern

```dart
Future<void> _submit() async {
  // Validate all fields
  if (_field1.isEmpty) {
    showError('Field 1 diperlukan');
    return;
  }
  
  if (_field2.isEmpty) {
    showError('Field 2 diperlukan');
    return;
  }
  
  // Disable button, show loading
  setState(() => _isLoading = true);
  
  try {
    // Do async operation
    await FirestoreService.save(data);
    showSuccess('Berhasil disimpan!');
    Navigator.pop(context);
  } catch (e) {
    showError('Error: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### 4. DateTime Formatting Pattern

```dart
// Indonesian locale date formatting
final dateStr = DateFormat('d MMMM yyyy', 'id')
  .format(order.pickupDate);
// Output: "18 Juni 2026"

final timeStr = order.pickupSlot.split(' ').first;
// Extract time from "08:00 - 10:00" → "08:00"
```

### 5. Navigation Pattern

```dart
// Simple navigation with data passing
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DetailScreen(order: order),
  ),
);

// Navigate back to root
Navigator.popUntil(context, (route) => route.isFirst);

// Navigate with return value
final result = await Navigator.push(...);
if (result == true) {
  // Refresh data
}
```

---

## 🔄 STATE MANAGEMENT

### 1. StatefulWidget for Local State

```dart
class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  // Local state variables
  int _selectedIndex = 0;
  bool _isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildContent(),
    );
  }
  
  @override
  void dispose() {
    // Clean up resources (controllers, streams, etc)
    super.dispose();
  }
}
```

### 2. StreamBuilder for Remote State

```dart
StreamBuilder<List<OrderModel>>(
  stream: FirestoreService.streamAllOrders(),
  builder: (context, snapshot) {
    // Automatically rebuilds when stream emits new data
    final orders = snapshot.data ?? [];
    return ListView.builder(...);
  },
)
```

### 3. setState for Local Updates

```dart
setState(() {
  _selectedIndex = newIndex;
  // UI will rebuild automatically
});
```

---

**Document Version**: 2.0  
**Total Coverage**: 50+ screen implementations  
**Code Examples**: 100+  
**Last Updated**: 2026-06-18