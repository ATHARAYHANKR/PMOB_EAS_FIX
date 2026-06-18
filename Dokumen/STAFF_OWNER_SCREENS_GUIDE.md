# 📚 PART 5: STAFF & OWNER MANAGEMENT SCREENS

**Coverage**: Staff operations and Owner dashboard/management  
**Status**: Complete  
**Last Updated**: 2026-06-18

---

## 📑 TABLE OF CONTENTS

1. [Staff Screens](#staff-screens)
2. [Owner Dashboard](#owner-dashboard)
3. [Weight Verification](#weight-verification)
4. [Registration Flow](#registration-flow)

---

## 👨‍💼 STAFF SCREENS

### 1. kelola_order_screen.dart

**Lokasi**: `/lib/screens/staff/kelola_order_screen.dart`  
**Fungsi**: Staff manage all orders dengan filter tabs  
**Pattern**: Enum-based filtering, StreamBuilder

#### Filter & State Setup
```dart
// Filter tab enum
enum _FilterTab {
  semua,      # All processing orders
  dicuci,     # Being washed
  disetrika,  # Being ironed
  kirim,      # Being shipped
  selesai     # Completed
}

class _KelolaOrderScreenState extends State<KelolaOrderScreen> {
  _FilterTab _activeFilter = _FilterTab.semua;  # Current filter

  // Apply filter logic
  List<OrderModel> _applyFilter(List<OrderModel> all) {
    switch (_activeFilter) {
      case _FilterTab.semua:
        // Show all processing orders (exclude masuk, dijemput, perluTimbang)
        return all
            .where((o) =>
                o.status == OrderStatus.dicuci ||
                o.status == OrderStatus.disetrika ||
                o.status == OrderStatus.dikirim ||
                o.status == OrderStatus.selesai)
            .toList();
      
      case _FilterTab.dicuci:
        return all.where((o) => o.status == OrderStatus.dicuci).toList();
      
      case _FilterTab.disetrika:
        return all.where((o) => o.status == OrderStatus.disetrika).toList();
      
      case _FilterTab.kirim:
        return all.where((o) => o.status == OrderStatus.dikirim).toList();
      
      case _FilterTab.selesai:
        return all.where((o) => o.status == OrderStatus.selesai).toList();
    }
  }

  // Get appropriate empty message per filter
  String get _emptyMessage {
    switch (_activeFilter) {
      case _FilterTab.selesai:
        return 'Belum ada pesenan yang selesai';
      case _FilterTab.dicuci:
        return 'Tidak ada order yang sedang dicuci';
      case _FilterTab.disetrika:
        return 'Tidak ada order yang sedang disetrika';
      case _FilterTab.kirim:
        return 'Tidak ada order yang sedang dikirim';
      default:
        return 'Tidak ada order';
    }
  }
}
```

#### Build Method with Filter Chips
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.bgPage,
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────
          const StaffPageHeader(
            title: 'Kelola Order',
            subtitle: 'Pantau dan kelola seluruh pesanan',
          ),

          // ── Filter Chips ────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _StaffOrderFilterChips(
              activeFilter: _activeFilter,
              onSelected: (tab) => 
                setState(() => _activeFilter = tab),
            ),
          ),

          // ── Order List ──────────────────────────────
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // Stream ALL orders
              stream: FirestoreService.streamAllOrders(),
              builder: (context, snapshot) {
                // Error handling
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

                // Loading state
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Apply filter
                final filtered = _applyFilter(snapshot.data!);

                // Empty state
                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                // Display list
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => 
                    const SizedBox(height: 12),
                  itemBuilder: (_, i) => 
                    _buildCard(filtered[i]),
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

#### Order Card with Navigation
```dart
Widget _buildCard(OrderModel order) {
  final dateStr = DateFormat('d MMMM yyyy', 'id')
      .format(order.pickupDate);
  final timeStr = order.pickupSlot.split(' ').first;

  return GestureDetector(
    onTap: order.status == OrderStatus.dijemput ||
            order.status == OrderStatus.perluTimbang ||
            order.status == OrderStatus.dicuci ||
            order.status == OrderStatus.disetrika ||
            order.status == OrderStatus.dikirim
        ? () {
            // Navigate to LanjutProsesScreen untuk status updates
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LanjutProsesScreen(order: order),
              ),
            );
          }
        : null,  # Disabled for completed orders
    child: StaffOrderCard(
      order: order,
      dateStr: dateStr,
      timeStr: timeStr,
    ),
  );
}
```

**Key Points**:
- Enum-based filter tabs (type-safe)
- Only shows processing stages (tidak termasuk masuk/dijemput)
- Tap navigates to LanjutProsesScreen for status updates
- Real-time updates via StreamBuilder

---

### 2. verifikasi_berat_screen.dart

**Lokasi**: `/lib/screens/staff/verifikasi_berat_screen.dart`  
**Fungsi**: Staff verify order weight dan calculate total price  
**Pattern**: Form with weight input, automatic price calculation

#### State Setup
```dart
class VerifikasiBeratScreen extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onKonfirmasi;

  const VerifikasiBeratScreen({
    super.key,
    required this.order,
    this.onKonfirmasi,
  });

  @override
  State<VerifikasiBeratScreen> createState() => 
    _VerifikasiBeratScreenState();
}

class _VerifikasiBeratScreenState extends State<VerifikasiBeratScreen> {
  final TextEditingController _beratController = 
    TextEditingController();

  @override
  void dispose() {
    _beratController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) => 
    DateFormat('d MMMM yyyy', 'id').format(dt);
}
```

#### Order Header Card
```dart
Widget _buildOrderHeader() {
  // Display order ID, date, and "Timbang" status
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F7F0),  # Light green
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.order.id,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(widget.order.pickupDate)} - '
                '${widget.order.pickupSlot.split(' ').first}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFD9C2F0),  # Light purple
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Timbang',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6A1F9F),
            ),
          ),
        ),
      ],
    ),
  );
}
```

#### Detail Card (Info Rows)
```dart
Widget _buildDetailCard() {
  // Display customer, service, pickup date, unit price
  final rows = [
    ('Customer', widget.order.customerName),
    ('Layanan', widget.order.serviceType),
    (
      'Jemput',
      '${_formatDate(widget.order.pickupDate)}, '
      '${widget.order.pickupSlot.split(' ').first}'
    ),
    ('Harga Satuan', 'Rp7.000'),  # Placeholder
  ];

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 1,
      ),
    ),
    child: Column(
      children: rows.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                row.$1,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textGrey,
                ),
              ),
              Text(
                row.$2,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ),
  );
}
```

#### Weight Input with Validation
```dart
Widget _buildBeratInput() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Berat (kg)',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          controller: _beratController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true
          ),
          inputFormatters: [
            // Allow only numbers and decimal point
            FilteringTextInputFormatter.allow(
              RegExp(r'^\d*\.?\d*$'),
            ),
          ],
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: '0.0',
          ),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (value) {
            // Trigger rebuild to update total
            setState(() {});
          },
        ),
      ),
    ],
  );
}

// Helper to calculate total
double _getBerat() {
  final value = double.tryParse(_beratController.text) ?? 0;
  return value;
}

double _getTotalHarga() {
  // Assuming 7000 per kg
  return _getBerat() * 7000;
}
```

#### Confirm Button with Validation
```dart
Widget _buildConfirmButton() {
  final berat = _getBerat();
  final isValid = berat > 0;

  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isValid
          ? () async {
              // Update order with weight + total price
              try {
                await FirestoreService.updateOrder(
                  widget.order.id,
                  {
                    'beratKg': berat,
                    'totalHarga': _getTotalHarga(),
                    'status': OrderStatus.perluTimbang.name,
                  },
                );
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Berat berhasil disimpan'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Callback if provided
                  widget.onKonfirmasi?.call();
                  
                  // Navigate back
                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            }
          : null,  # Disabled if no weight
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        'Simpan Berat',
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
```

**Key Points**:
- Weight input with decimal validation
- Auto-calculation of total price (berat × 7000)
- Firestore update on confirm
- Callback notification to parent screen

---

### 3. profil_screen.dart (Staff)

**Lokasi**: `/lib/screens/staff/profil_screen.dart`  
**Fungsi**: Staff profile view dengan info dan logout  
**Pattern**: Stateless widget, info display with gradients

#### Build with Header Gradient
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.bgPage,
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header with Gradient ───────────────────
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary,          # Blue
                    AppColors.primaryLight,     # Light blue
                  ],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: Column(
                children: [
                  // Avatar with border
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 42,
                      backgroundColor: AppColors.primaryLight
                          .withAlpha(38),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 46,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 14),
                  
                  // Name
                  Text(
                    'Karimah Staff',
                    style: GoogleFonts.inter(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(46),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Staff Laundry',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),

            // ── Info Section ────────────────────────────
            _section(
              title: 'Informasi Akun',
              items: const [
                _InfoItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Username',
                  value: 'karimah_staff',
                ),
                _InfoItem(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: '+62 812 3456 7890',
                ),
                _InfoItem(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: 'karimah@cleango.id',
                ),
                _InfoItem(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: 'Staff Laundry',
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // ── Action Section ──────────────────────────
            _actionSection(context),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
}

Widget _section({
  required String title,
  required List<_InfoItem> items,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
        ),
        ...items.asMap().entries.map((e) {
          return Column(
            children: [
              _buildInfoTile(e.value),
              if (e.key < items.length - 1)
                const Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 16,
                ),
            ],
          );
        }),
        const SizedBox(height: 4),
      ],
    ),
  );
}

Widget _buildInfoTile(_InfoItem item) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Row(
      children: [
        Icon(item.icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.value,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _actionSection(BuildContext context) {
  return Column(
    children: [
      _actionButton(
        context,
        Icons.edit_rounded,
        'Edit Profil',
        AppColors.primary,
        () {},
      ),
      const SizedBox(height: 8),
      _actionButton(
        context,
        Icons.logout_rounded,
        'Keluar',
        Colors.redAccent,
        () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
            (route) => false,
          );
        },
      ),
    ],
  );
}

Widget _actionButton(
  BuildContext context,
  IconData icon,
  String label,
  Color color,
  VoidCallback onPressed,
) {
  return GestureDetector(
    onTap: onPressed,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
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
```

**Key Points**:
- Header gradient background
- Info sections with dividers
- Logout button with navigation
- Edit profile placeholder

---

## 👑 OWNER DASHBOARD

### 4. owner_dashboard_screen.dart

**Lokasi**: `/lib/screens/owner/owner_dashboard_screen.dart`  
**Fungsi**: Owner overview dengan stats, recent orders, staff list  
**Pattern**: Multiple StreamBuilders, stat cards, quick menu

#### State & Callback
```dart
class OwnerDashboardScreen extends StatelessWidget {
  const OwnerDashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  /// Callback untuk berpindah tab pada OwnerMainScreen
  /// [kelolaTab] untuk membuka sub-tab tertentu (Katalog/Layanan/Staff)
  final void Function(int index, {KelolaTab? kelolaTab}) 
    onNavigateTab;

  static const Color _purple = Color(0xFFBB2BCD);
}
```

#### Main Build with Stat Grid
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    body: SafeArea(
      child: StreamBuilder<List<OrderModel>>(
        // Stream ALL orders untuk stats
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

          final orders = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── App Bar ─────────────────────────────
                _buildAppBar(),
                const SizedBox(height: 20),

                // ── Greeting + Avatar ────────────────────
                _buildGreeting(),
                const SizedBox(height: 20),

                // ── Stat Cards 2x2 ───────────────────────
                _buildStatGrid(orders),
                const SizedBox(height: 20),

                // ── Order Terbaru ────────────────────────
                _buildSectionCard(
                  title: 'Order Terbaru',
                  actionLabel: 'Lihat semua',
                  onAction: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => 
                        const OwnerSemuaOrderScreen(),
                    ),
                  ),
                  child: Column(
                    children: _buildRecentOrders(orders),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Staff List ────────────────────────────
                _buildSectionCard(
                  title: 'Daftar Staff',
                  actionLabel: 'Kelola',
                  onAction: () => onNavigateTab(
                    1,
                    kelolaTab: KelolaTab.staff,
                  ),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: FirestoreService
                        .streamStaffRaw(),
                    builder: (context, staffSnapshot) {
                      if (!staffSnapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: _buildStaffList(
                          staffSnapshot.data!,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ── Quick Menu ────────────────────────────
                Text(
                  'Menu Cepat',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickMenu(context),
              ],
            ),
          );
        },
      ),
    ),
  );
}
```

#### Stat Grid (4 Cards)
```dart
Widget _buildStatGrid(List<OrderModel> orders) {
  // Calculate stats
  final totalOrders = orders.length;
  final completedToday = orders
      .where((o) => 
          o.status == OrderStatus.selesai &&
          _isToday(o.createdAt))
      .length;
  final pendingPayment = orders
      .where((o) =>
          o.status == OrderStatus.konfirmasiBayar &&
          !o.isPaid)
      .length;
  final totalRevenue = orders
      .where((o) => o.status == OrderStatus.selesai)
      .fold<double>(
        0,
        (sum, o) => sum + (o.totalHarga ?? 0),
      );

  return Column(
    children: [
      // Row 1: Total Orders | Completed Today
      Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.shopping_bag_outlined,
              label: 'Total Order',
              value: totalOrders.toString(),
              color: const Color(0xFF3B5BDB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.check_circle_outline,
              label: 'Selesai Hari Ini',
              value: completedToday.toString(),
              color: const Color(0xFF1F9D55),
            ),
          ),
        ],
      ),
      
      const SizedBox(height: 12),
      
      // Row 2: Pending Payment | Revenue
      Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.warning_amber_rounded,
              label: 'Menunggu Bayar',
              value: pendingPayment.toString(),
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.trending_up,
              label: 'Total Pendapatan',
              value: _formatCurrency(totalRevenue),
              color: Colors.purple,
            ),
          ),
        ],
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFEEEEEE),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Section Card with Title
```dart
Widget _buildSectionCard({
  required String title,
  required String actionLabel,
  required VoidCallback onAction,
  required Widget child,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: const Color(0xFFEEEEEE),
        width: 1,
      ),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B5BDB),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    ),
  );
}
```

**Key Points**:
- Multiple StreamBuilders untuk different data sources
- 2x2 stat grid dengan calculated metrics
- Quick actions untuk navigating to kelola screens
- Callback untuk tab navigation

---

## 🔐 REGISTRATION

### 5. register_screen.dart

**Lokasi**: `/lib/screens/auth/register_screen.dart`  
**Fungsi**: Customer registration form  
**Pattern**: Form validation, FirestoreService.createUser()

#### State & Validation
```dart
class _RegisterScreenState extends State<RegisterScreen> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isSaving = false;

  static const Color _blue = Color(0xFF3B5BDB);

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nama = _namaCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    // Validation
    if (nama.isEmpty || email.isEmpty || 
        phone.isEmpty || password.isEmpty) {
      _showSnack('Semua field wajib diisi', Colors.redAccent);
      return;
    }
    if (password.length < 6) {
      _showSnack('Password minimal 6 karakter', Colors.redAccent);
      return;
    }

    setState(() => _isSaving = true);
    try {
      // Create user in Firestore
      await FirestoreService.createUser({
        'name': nama,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'customer',
      });
      
      if (!mounted) return;
      
      _showSnack(
        'Registrasi berhasil. Silakan login.',
        Colors.green,
      );
      
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      
      Navigator.pop(context);  # Go back to login
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal registrasi: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
```

#### Build Method
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    appBar: AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      title: Text(
        'Daftar Akun',
        style: GoogleFonts.inter(fontWeight: FontWeight.w700),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Buat akun baru',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),

            _field(
              'Nama Lengkap',
              _namaCtrl,
              hint: 'Masukkan nama',
            ),
            const SizedBox(height: 14),

            _field(
              'Email',
              _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              hint: 'Masukkan email',
            ),
            const SizedBox(height: 14),

            _field(
              'Nomor Telepon',
              _phoneCtrl,
              keyboardType: TextInputType.phone,
              hint: 'Masukkan nomor telepon',
            ),
            const SizedBox(height: 14),

            _field(
              'Password',
              _passwordCtrl,
              obscure: true,
              hint: 'Minimal 6 karakter',
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Daftar',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
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

Widget _field(
  String label,
  TextEditingController controller,
  {
  TextInputType keyboardType = TextInputType.text,
  bool obscure = false,
  String? hint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFEEEEEE),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        style: GoogleFonts.inter(fontSize: 13),
      ),
    ],
  );
}
```

**Key Points**:
- Full form validation (empty, password length)
- FirestoreService.createUser() integration
- Loading state during submission
- Floating snackbar feedback
- Pop back to login on success

---

## 🎯 HELPER FUNCTIONS

```dart
// Format currency untuk display
String _formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(amount);
}

// Check if date is today
bool _isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

// Format date for display
String _formatDate(DateTime date) {
  return DateFormat('d MMMM yyyy', 'id').format(date);
}
```

---

**Document Version**: 5.0  
**Total Screens**: 9 detailed implementations  
**Code Examples**: 120+  
**Last Updated**: 2026-06-18