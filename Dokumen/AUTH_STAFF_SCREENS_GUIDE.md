# 📚 PART 3: AUTH & STAFF SCREENS - DETAILED IMPLEMENTATION

**Coverage**: Authentication & Staff Management Screens  
**Status**: Complete  
**Last Updated**: 2026-06-18

---

## 🔐 AUTHENTICATION SCREENS

### 1. login_screen.dart

**Lokasi**: `/lib/screens/auth/login_screen.dart`  
**Fungsi**: Login screen untuk semua roles (Customer, Staff, Owner)  
**Background**: Menggunakan image dari `assets/images/bg_login.jpg` atau fallback gradient

#### State Variables
```dart
class _LoginScreenState extends State<LoginScreen> {
  // Text input controllers
  final _usernameCtrl = TextEditingController();  # Username field
  final _passwordCtrl = TextEditingController();  # Password field

  // UI state
  bool _obscure = true;      # Password visibility toggle
  bool _remember = false;    # Remember me checkbox

  // Demo credentials (hardcoded untuk testing)
  static const _accounts = {
    'staff': ('staff123', 'staff'),        # Key: username, Value: (password, role)
    'owner': ('owner123', 'owner'),
    'customer': ('customer123', 'customer'),
  };

  static const Color _blue = Color(0xFF3B5BDB);      # Primary blue
  static const Color _purple = Color(0xFFBB2BCD);   # Purple accent
}
```

#### Background Widget
```dart
Widget _buildBg() {
  return Image.asset(
    'assets/images/bg_login.jpg',   # Try to load background image
    fit: BoxFit.cover,              # Cover entire screen
    errorBuilder: (_, __, ___) => Container(
      // Fallback gradient if image not found
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B5E20),  # Dark green
            Color(0xFF2E7D32),  # Medium green
            Color(0xFF43A047),  # Light green
          ],
        ),
      ),
    ),
  );
}
```

#### Main Build with Overlay
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      fit: StackFit.expand,  # Fill entire screen
      children: [
        // Layer 1: Background image
        _buildBg(),
        
        // Layer 2: Dark overlay (opacity ~0.35)
        Container(color: Colors.black.withAlpha(89)),
        
        // Layer 3: Safe area with login card
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildCard(),
            ),
          ),
        ),
      ],
    ),
  );
}
```

#### Login Card
```dart
Widget _buildCard() {
  return Container(
    width: double.infinity,
    constraints: const BoxConstraints(maxWidth: 400),  # Max width on tablet
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(46),
          blurRadius: 32,
          offset: const Offset(0, 12),  # Drop shadow below
        ),
      ],
    ),
    padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header text with "Selamat" normal, "Datang" blue
        RichText(
          text: TextSpan(children: [
            TextSpan(
              text: 'Selamat ',
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            TextSpan(
              text: 'Datang',  # "Welcome"
              style: GoogleFonts.inter(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _blue,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 6),
        
        // Subtitle: "Masuk ke akun CleanGo Anda"
        Text(
          'Masuk ke akun CleanGo Anda',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 28),
        
        // Demo Credentials Hint Box
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5),  # Light purple background
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFCC44DD).withAlpha(80),  # Purple border
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun Demo:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _purple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '👤 Staff   →  staff / staff123',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '👑 Owner  →  owner / owner123',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Input fields
        _label('EMAIL / TELEPON / NAMA'),
        const SizedBox(height: 8),
        _buildInputField(
          controller: _usernameCtrl,
          icon: Icons.person_outline,
          hintText: 'staff / owner / customer',
        ),
        
        const SizedBox(height: 16),
        
        _label('PASSWORD'),
        const SizedBox(height: 8),
        _buildPasswordField(),
        
        const SizedBox(height: 12),
        
        // Remember checkbox
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _remember,
                onChanged: (value) => 
                  setState(() => _remember = value ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ingat saya',  # "Remember me"
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Login button
        _buildLoginButton(),
        
        const SizedBox(height: 14),
        
        // Register link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum punya akun? ',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RegisterScreen(),
                ),
              ),
              child: Text(
                'Daftar sekarang',  # "Register now"
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _blue,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
```

#### Login Handler
```dart
Future<void> _login() async {
  // Validate inputs
  if (_usernameCtrl.text.isEmpty) {
    _showError('Username tidak boleh kosong');
    return;
  }

  if (_passwordCtrl.text.isEmpty) {
    _showError('Password tidak boleh kosong');
    return;
  }

  // Check demo credentials
  final account = _accounts[_usernameCtrl.text];
  if (account == null || account.$1 != _passwordCtrl.text) {
    _showError('Username atau password salah');
    return;
  }

  final role = account.$2;  # Get role from tuple: 'staff', 'owner', 'customer'

  // Save to FirestoreService or local storage
  // This is where you'd call FirestoreService.login()
  
  // Navigate to role-specific main screen
  if (mounted) {
    late Widget nextScreen;

    switch (role) {
      case 'staff':
        nextScreen = const StaffMainScreen();
        break;
      case 'owner':
        nextScreen = const OwnerMainScreen();
        break;
      case 'customer':
        nextScreen = const CustomerMainScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => nextScreen),
      (route) => false,  # Remove all previous routes
    );
  }
}

void _showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ),
  );
}
```

**Key Points**:
- Hardcoded demo credentials untuk development
- Role-based navigation (Staff vs Owner vs Customer)
- Remember me checkbox
- Forgot password placeholder
- Image background dengan fallback gradient

---

## 👨‍💼 STAFF SCREENS

### 2. order_masuk_screen.dart

**Lokasi**: `/lib/screens/staff/order_masuk_screen.dart`  
**Fungsi**: Staff view untuk order masuk (pickup vs weighing)  
**Sub-tabs**: Ambil (pickup) | Timbang (weighing)

#### State & Tab Management
```dart
class _OrderMasukScreenState extends State<OrderMasukScreen> {
  int _tabIndex = 0;  # 0 = Ambil (Pickup), 1 = Timbang (Weighing)

  // Get active statuses based on tab
  List<OrderStatus> get _activeStatuses => _tabIndex == 0
      ? [OrderStatus.masuk]                    # Tab 0: Just arrived orders
      : [
          OrderStatus.dijemput,                # Tab 1: Picked up or
          OrderStatus.perluTimbang             # need weighing
        ];
}
```

#### Main Build
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.bgPage,
    body: SafeArea(
      child: Column(
        children: [
          // ── Header with dynamic subtitle ──────────────
          StaffPageHeader(
            title: 'Order Masuk',
            subtitle: _tabIndex == 0
                ? 'Order yang menunggu untuk diambil'     # "Awaiting pickup"
                : 'Order yang menunggu ditimbang',       # "Awaiting weighing"
          ),

          // ── Tab Selector (Ambil / Timbang) ──────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTabSelector(),
          ),
          const SizedBox(height: 16),

          // ── Order List Stream ────────────────────────
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              // Stream all orders with active statuses
              stream: FirestoreService.streamOrdersByStatuses(
                _activeStatuses
              ),
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
                    child: CircularProgressIndicator()
                  );
                }

                // Filter orders by active statuses
                final orders = snapshot.data!
                    .where((order) => 
                      _activeStatuses.contains(order.status))
                    .toList();

                // Empty state
                if (orders.isEmpty) {
                  return _buildEmptyState();  # "No orders at this stage"
                }

                // Display list
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => 
                    const SizedBox(height: 12),
                  itemBuilder: (ctx, i) => 
                    _buildOrderCard(orders[i]),
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

#### Tab Selector
```dart
Widget _buildTabSelector() {
  return Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F5),  # Light gray background
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: _tabButton('Ambil', 0, Icons.move_to_inbox_rounded)
        ),
        const SizedBox(width: 4),
        Expanded(
          child: _tabButton('Timbang', 1, Icons.balance_rounded)
        ),
      ],
    ),
  );
}

Widget _tabButton(String label, int idx, IconData icon) {
  final isActive = _tabIndex == idx;

  return GestureDetector(
    onTap: () => setState(() => _tabIndex = idx),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 44,
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
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive 
              ? AppColors.primary        # Blue when active
              : AppColors.textGrey,      # Gray when inactive
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isActive 
                ? AppColors.primary
                : AppColors.textGrey,
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
Widget _buildOrderCard(OrderModel order) {
  final dateStr = DateFormat('d MMMM yyyy', 'id')
    .format(order.pickupDate);
  
  return GestureDetector(
    onTap: () {
      // Navigate to weighing or detail screen based on tab
      if (_tabIndex == 0) {
        // Ambil tab: go to order confirmation/pickup
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LanjutProsesScreen(order: order),
          ),
        );
      } else {
        // Timbang tab: go to weighing screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifikasiBerat Screen(order: order),
          ),
        );
      }
    },
    child: StaffCard(  # Custom card widget
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order ID + Status badge
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
              StatusBadge(status: order.status),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Customer info
          _infoRow(
            Icons.person_outline_rounded,
            '${order.customerName} • ${order.phone}',
          ),
          const SizedBox(height: 6),
          
          // Service type
          _infoRow(
            Icons.local_laundry_service_outlined,
            order.serviceType,
          ),
          const SizedBox(height: 6),
          
          // Date and time
          _infoRow(
            Icons.event_outlined,
            '$dateStr • ${order.pickupSlot}',
          ),
          
          // Weight info (if available)
          if (order.beratKg != null) ...[
            const SizedBox(height: 6),
            _infoRow(
              Icons.scale_rounded,
              '${order.beratKg} kg',
            ),
          ],
        ],
      ),
    ),
  );
}

Widget _infoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: AppColors.textGrey),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppColors.textDark,
          ),
        ),
      ),
    ],
  );
}
```

**Key Features**:
- Dual tabs for workflow stages (Ambil → Timbang)
- Tab-specific empty states
- Navigation to detail/weighing screens
- StreamBuilder for real-time order updates

---

### 3. booking_laundry_screen.dart

**Lokasi**: `/lib/screens/customer/booking_laundry_screen.dart`  
**Fungsi**: Comprehensive booking form dengan service selection, date picker, session selection

#### State Variables
```dart
class _BookingLaundryScreenState extends State<BookingLaundryScreen> {
  static const Color _blue = Color(0xFF3B5BDB);

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Selected service
  KatalogModel? _selectedLayanan;

  // Text controllers pre-filled with user data
  final _namaCtrl = TextEditingController(text: 'Dhira Putri');
  final _teleponCtrl = TextEditingController(text: '081323230001');
  final _alamatCtrl = TextEditingController(text: 'Jl. Mawar No. 10');
  final _catatanCtrl = TextEditingController();

  // Date & time
  DateTime? _tanggalJemput;  # Nullable until selected
  String _sesiJemput = '08.00 - 10.00 (Pagi)';  # Default session
  bool _dateError = false;   # Show error if date not selected
  bool _isSaving = false;    # Loading state during submission

  // Available sessions
  final _sesiOptions = const [
    '08.00 - 10.00 (Pagi)',    # Morning
    '10.00 - 12.00 (Pagi)',    # Late morning
    '14.00 - 16.00 (Siang)',   # Afternoon
    '16.00 - 18.00 (Sore)',    # Evening
  ];
}
```

#### Init State - Pre-fill from FirestoreService
```dart
@override
void initState() {
  super.initState();

  // Get current user data from FirestoreService
  final currentName = FirestoreService.currentUserName;
  final currentPhone = FirestoreService.currentUserPhone;

  // Pre-fill name if available
  if (currentName != null && currentName.isNotEmpty) {
    _namaCtrl.text = currentName;
  }

  // Pre-fill phone if available
  if (currentPhone != null && currentPhone.isNotEmpty) {
    _teleponCtrl.text = currentPhone;
  }

  // If a service was passed in, select it
  if (widget.selectedItem != null) {
    _selectedLayanan = KatalogModel(
      id: 'local',
      nama: widget.selectedItem!.nama,
      satuan: widget.selectedItem!.satuan,
      harga: widget.selectedItem!.harga,
      estimasi: widget.selectedItem!.estimasi,
      deskripsi: widget.selectedItem!.deskripsi,
    );
  }
}
```

#### Order ID Generation
```dart
String _generateOrderId() {
  final now = DateTime.now();
  
  // Format: yyyyMMdd
  final datePart = DateFormat('yyyyMMdd').format(now);
  
  // Get last 8 digits of milliseconds as random suffix
  final suffix = now.millisecondsSinceEpoch.toString().substring(8);
  
  // Result: ORD-20260618-12345678
  return 'ORD-$datePart-$suffix';
}
```

#### Main Build with Form
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F8FB),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title bar with back button ──────────────
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
                    'Booking Laundry',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Customer Name Input ─────────────────────
              _label('Nama Pelanggan'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: TextFormField(
                  controller: _namaCtrl,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';  # "Name is required"
                    }
                    if (value.trim().length < 3) {
                      return 'Nama minimal 3 karakter';  # "Name min 3 chars"
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Phone Number Input ───────────────────────
              _label('Nomor Telepon'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: TextFormField(
                  controller: _teleponCtrl,
                  keyboardType: TextInputType.phone,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nomor telepon wajib diisi';
                    }
                    if (!RegExp(r'^(?:62|\+62|0)8[1-9]\d{6,9}$')
                        .hasMatch(value)) {
                      return 'Nomor telepon tidak valid';  # Invalid phone
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Service Selection ────────────────────────
              _label('Pilih Layanan'),
              const SizedBox(height: 8),
              StreamBuilder<List<KatalogModel>>(
                stream: FirestoreService.streamKatalog(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return _buildBoxField(
                      child: SizedBox(
                        height: 60,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    );
                  }

                  final services = snapshot.data ?? [];
                  
                  return _buildBoxField(
                    child: DropdownButton<KatalogModel>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      value: _selectedLayanan,
                      items: services
                          .map((service) =>
                              DropdownMenuItem(
                                value: service,
                                child: Text(
                                  '${service.nama} (Rp${service.harga}/${service.satuan})',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (service) => setState(() {
                        _selectedLayanan = service;
                      }),
                      hint: Text(
                        'Pilih layanan...',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // ── Address Input ────────────────────────────
              _label('Alamat Pengambilan'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: TextFormField(
                  controller: _alamatCtrl,
                  maxLines: null,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alamat wajib diisi';  # "Address is required"
                    }
                    if (value.trim().length < 5) {
                      return 'Alamat terlalu pendek';  # "Address too short"
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ── Pickup Date Selector ─────────────────────
              _label('Tanggal Pengambilan'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(),
                child: _buildBoxField(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _tanggalJemput != null
                              ? DateFormat('d MMMM yyyy', 'id')
                                  .format(_tanggalJemput!)
                              : 'Pilih tanggal...',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _tanggalJemput != null
                                ? Colors.black87
                                : Colors.black45,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: _blue,
                      ),
                    ],
                  ),
                ),
              ),
              if (_dateError)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Tanggal wajib dipilih',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.red,
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // ── Session Selection (Dropdown) ─────────────
              _label('Sesi Pengambilan'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: DropdownButton<String>(
                  isExpanded: true,
                  underline: const SizedBox(),
                  value: _sesiJemput,
                  items: _sesiOptions
                      .map((session) =>
                          DropdownMenuItem(
                            value: session,
                            child: Text(
                              session,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (session) => setState(() {
                    _sesiJemput = session ?? _sesiJemput;
                  }),
                ),
              ),
              const SizedBox(height: 20),

              // ── Notes / Catatan ─────────────────────────
              _label('Catatan (Opsional)'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: TextFormField(
                  controller: _catatanCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Catatan khusus untuk layanan...',
                    isCollapsed: true,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Submit Button ────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Buat Booking',  # "Create Booking"
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
    ),
  );
}
```

#### Submit Handler
```dart
Future<void> _submitBooking() async {
  // Validate form fields
  if (!_formKey.currentState!.validate()) {
    return;
  }

  // Validate date selection
  if (_tanggalJemput == null) {
    setState(() => _dateError = true);
    return;
  }

  // Validate service selection
  if (_selectedLayanan == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pilih layanan terlebih dahulu')),
    );
    return;
  }

  setState(() => _isSaving = true);

  try {
    // Create order
    final order = OrderModel(
      id: _generateOrderId(),
      customerId: FirestoreService.currentUser?['id']?.toString() ??
          _teleponCtrl.text,
      customerName: _namaCtrl.text,
      phone: _teleponCtrl.text,
      serviceType: _selectedLayanan!.nama,
      pickupDate: _tanggalJemput!,
      pickupSlot: _sesiJemput,
      pickupAddress: _alamatCtrl.text,
      notes: _catatanCtrl.text,
      status: OrderStatus.masuk,
      createdAt: DateTime.now(),
    );

    // Save to Firebase
    await FirestoreService.addOrder(order);

    if (mounted) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context, true);  # Return true to indicate success
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}

Future<void> _selectDate() async {
  final now = DateTime.now();
  final picked = await showDatePicker(
    context: context,
    initialDate: _tanggalJemput ?? now,
    firstDate: now.add(const Duration(days: 1)),
    lastDate: now.add(const Duration(days: 30)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: _blue),
        ),
        child: child!,
      );
    },
  );

  if (picked != null) {
    setState(() {
      _tanggalJemput = picked;
      _dateError = false;
    });
  }
}
```

**Key Features**:
- Form validation dengan multiple rules
- Pre-filled user data dari FirestoreService
- Service dropdown dari Firestore stream
- Date picker dengan min/max constraints
- Session time slot selector
- Order ID generation (ORD-yyyyMMdd-xxxxx)
- Auto-navigation back on success

---

## 🔄 SUMMARY & PATTERNS

### Common UI Components (Custom)

```dart
// ── Custom Box Field (Border + Rounded Corner) ──
Widget _buildBoxField({required Widget child}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color(0xFFEDEDF2),
        width: 1,
      ),
    ),
    child: child,
  );
}

// ── Section Label ──
Widget _label(String text) {
  return Text(
    text,
    style: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF5B6472),
      letterSpacing: 0.3,
    ),
  );
}

// ── Info Row with Icon ──
Widget _infoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: const Color(0xFF374151),
          ),
        ),
      ),
    ],
  );
}
```

### Form Validation Patterns

```dart
// ── Text validation ──
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Field tidak boleh kosong';
  }
  if (value.trim().length < 3) {
    return 'Minimal 3 karakter';
  }
  return null;
}

// ── Phone validation (Indonesia) ──
if (!RegExp(r'^(?:62|\+62|0)8[1-9]\d{6,9}$')
    .hasMatch(value)) {
  return 'Nomor telepon tidak valid';
}

// ── Email validation ──
if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
    .hasMatch(value)) {
  return 'Email tidak valid';
}
```

---

**Document Version**: 3.0  
**Total Screen Coverage**: 60+ implementations  
**Last Updated**: 2026-06-18