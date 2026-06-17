import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_helper.dart';
import '../../models/katalog_model.dart';
import 'customer_main_screen.dart';

class BookingLaundryScreen extends StatefulWidget {
  const BookingLaundryScreen({super.key, this.selectedItem});

  final KatalogModel? selectedItem;

  @override
  State<BookingLaundryScreen> createState() => _BookingLaundryScreenState();
}

class _BookingLaundryScreenState extends State<BookingLaundryScreen> {
  static const Color _blue = Color(0xFF3B5BDB);

  final _formKey = GlobalKey<FormState>();

  KatalogModel? _selectedLayanan;
  final _namaCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  final _alamatCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  DateTime? _tanggalJemput;
  String _sesiJemput = '08.00 - 10.00 (Pagi)';
  bool _dateError = false;
  bool _isSaving = false;

  final _sesiOptions = const [
    '08.00 - 10.00 (Pagi)',
    '10.00 - 12.00 (Pagi)',
    '14.00 - 16.00 (Siang)',
    '16.00 - 18.00 (Sore)',
  ];

  @override
  void initState() {
    super.initState();
    final currentName = FirestoreService.currentUserName;
    final currentPhone = FirestoreService.currentUserPhone;
    final currentAddress = FirestoreService.currentUserAddress;

    if (currentName != null && currentName.isNotEmpty) {
      _namaCtrl.text = currentName;
    }
    if (currentPhone != null && currentPhone.isNotEmpty) {
      _teleponCtrl.text = currentPhone;
    }
    if (currentAddress != null && currentAddress.isNotEmpty) {
      _alamatCtrl.text = currentAddress;
    }

    // initial selection will be resolved from Firestore stream in build
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

  @override
  void dispose() {
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    _alamatCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  String _generateOrderId() {
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final suffix = now.millisecondsSinceEpoch.toString().substring(8);
    return 'ORD-$datePart-$suffix';
  }

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
                    Text('Booking Laundry',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        )),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Nama Pelanggan ────────────────────────────
                _label('Nama Pelanggan'),
                const SizedBox(height: 8),
                _buildBoxField(
                  child: TextFormField(
                    controller: _namaCtrl,
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      if (value.trim().length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ── Nomor Telepon ─────────────────────────────
                _label('Nomor Telepon'),
                const SizedBox(height: 8),
                _buildBoxField(
                  child: TextFormField(
                    controller: _teleponCtrl,
                    keyboardType: TextInputType.phone,
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nomor telepon wajib diisi';
                      }
                      final phoneRegex = RegExp(r'^[0-9]{9,13}$');
                      if (!phoneRegex.hasMatch(value.trim())) {
                        return 'Nomor telepon harus 9-13 digit angka';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ── Pilih Layanan ──────────────────────────────
                _label('Pilih Layanan'),
                const SizedBox(height: 8),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: FirestoreService.streamKatalogRaw(),
                  builder: (context, snap) {
                    if (snap.hasError) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDEDED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF5C2C2)),
                        ),
                        child: Text(
                          'Gagal memuat data layanan: ${snap.error}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      );
                    }
                    if (!snap.hasData) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    final list = (snap.data ?? [])
                        .map((m) => KatalogModel.fromMap(m['id'], m))
                        .where((k) => k.aktif)
                        .toList();
                    if (_selectedLayanan == null && list.isNotEmpty) {
                      _selectedLayanan = list.first;
                    }
                    return _buildLayananSelector();
                  },
                ),
                const SizedBox(height: 20),

                // ── Alamat Penjemputan ───────────────────────────
                _label('Alamat Penjemputan'),
                const SizedBox(height: 8),
                _buildBoxField(
                  child: TextFormField(
                    controller: _alamatCtrl,
                    maxLines: 3,
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Alamat penjemputan wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // ── Tanggal & Sesi ────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Tanggal Jemput'),
                          const SizedBox(height: 8),
                          _buildDatePicker(),
                          if (_dateError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Tanggal wajib dipilih',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Sesi Jemput'),
                          const SizedBox(height: 8),
                          _buildSesiPicker(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Catatan ───────────────────────────────────────
                _label('Catatan'),
                const SizedBox(height: 8),
                _buildBoxField(
                  child: TextFormField(
                    controller: _catatanCtrl,
                    style:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isCollapsed: true,
                      hintText: 'Misal: Hati-hati baju warna putih',
                      hintStyle: GoogleFonts.inter(
                          fontSize: 13, color: Colors.black38),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Submit ────────────────────────────────────────
                GestureDetector(
                  onTap: _isSaving ? null : _onKirimBooking,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text('Kirim Booking',
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
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ));
  }

  Widget _buildBoxField({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: child,
    );
  }

  // ── Layanan Selector ─────────────────────────────────────────
  Widget _buildLayananSelector() {
    return GestureDetector(
      onTap: () => _showLayananPicker(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD0DCF8), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedLayanan?.nama ?? 'Memuat...',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                      )),
                  Text(
                      'Rp${_formatHarga(_selectedLayanan?.harga ?? 0)}/${_selectedLayanan?.satuan.toLowerCase() ?? 'kg'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      )),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _blue, size: 22),
          ],
        ),
      ),
    );
  }

  void _showLayananPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirestoreService.streamKatalogRaw(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Gagal memuat data layanan: ${snap.error}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final items = (snap.data ?? [])
                    .map((m) => KatalogModel.fromMap(m['id'], m))
                    .where((k) => k.aktif)
                    .toList();
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item.nama,
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                          'Rp${_formatHarga(item.harga)}/${item.satuan.toLowerCase()}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.black54)),
                      onTap: () {
                        setState(() => _selectedLayanan = item);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ── Date Picker ──────────────────────────────────────────────
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
        );
        if (picked != null) {
          setState(() {
            _tanggalJemput = picked;
            _dateError = false;
          });
        }
      },
      child: _buildBoxField(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _tanggalJemput == null
                    ? 'dd/mm/yyyy'
                    : '${_tanggalJemput!.day.toString().padLeft(2, '0')}/${_tanggalJemput!.month.toString().padLeft(2, '0')}/${_tanggalJemput!.year}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color:
                      _tanggalJemput == null ? Colors.black38 : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  // ── Sesi Picker ──────────────────────────────────────────────
  Widget _buildSesiPicker() {
    return _buildBoxField(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          isDense: true,
          value: _sesiJemput,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.black45),
          style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
          items: _sesiOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _sesiJemput = v);
          },
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────
  Future<void> _onKirimBooking() async {
    final formValid = _formKey.currentState!.validate();
    final dateValid = _tanggalJemput != null;

    setState(() => _dateError = !dateValid);

    if (!formValid || !dateValid) return;

    setState(() => _isSaving = true);

    final newOrder = OrderModel(
      id: _generateOrderId(),
      customerName: _namaCtrl.text.trim(),
      phone: _teleponCtrl.text.trim(),
      serviceType: _selectedLayanan?.nama ?? '',
      pickupDate: _tanggalJemput!,
      pickupSlot: _sesiJemput,
      status: OrderStatus.masuk,
      address: _alamatCtrl.text.trim(),
      catatan:
          _catatanCtrl.text.trim().isEmpty ? '-' : _catatanCtrl.text.trim(),
    );

    try {
      await FirestoreService.addOrder(newOrder);
      if (!mounted) return;
      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => _buildSuccessDialog(),
      );
    } catch (e) {
      if (!mounted) return;
      NotificationHelper.showErrorSnackBar(
          context, 'Gagal mengirim booking: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSuccessDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Terima Kasih!',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                )),
            const SizedBox(height: 12),
            const Text('🙏', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Kami akan mengirimkan notifikasi saat laundrymu akan diambil',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CustomerMainScreen(),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text('Kembali',
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
