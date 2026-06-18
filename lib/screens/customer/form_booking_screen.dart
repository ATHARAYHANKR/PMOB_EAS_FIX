import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/katalog_model.dart';
import '../../models/booking_model.dart';
import '../../services/firestore_service.dart';

class FormBookingScreen extends StatefulWidget {
  final KatalogModel service;

  const FormBookingScreen({
    super.key,
    required this.service,
  });

  @override
  State<FormBookingScreen> createState() => _FormBookingScreenState();
}

class _FormBookingScreenState extends State<FormBookingScreen> {
  // ── GlobalKey<FormState> wajib ─────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _selectedPickupDate;
  String _selectedPickupSession = '08:00 - 10:00 (Pagi)';
  bool _isLoading = false;

  final List<String> _sessions = [
    '08:00 - 10:00 (Pagi)',
    '10:00 - 12:00 (Siang)',
    '14:00 - 16:00 (Sore)',
    '16:00 - 18:00 (Malam)',
  ];

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  void _loadDefaultAddress() {
    final addr = FirestoreService.currentUserAddress;
    _addressController.text = addr ?? '';
  }

  Future<void> _selectPickupDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now.add(const Duration(days: 1));
    final DateTime lastDate = now.add(const Duration(days: 30));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B5BDB),
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

  Future<void> _submitBooking() async {
    // ── Validasi Form ──────────────────────────────────────────────
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPickupDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal jemput terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      DateTime finishDate = _calculateFinishDate(_selectedPickupDate!);

      final booking = BookingModel(
        id: '',
        customerId: FirestoreService.currentUser?['id']?.toString() ??
            FirestoreService.currentUserPhone ??
            '',
        katalogId: widget.service.id,
        katalogNama: widget.service.nama,
        harga: widget.service.harga,
        satuan: widget.service.satuan,
        alamat: _addressController.text.trim(),
        tanggalJemput: _selectedPickupDate!,
        tanggalSelesai: finishDate,
        sesiJemput: _selectedPickupSession,
        catatan: _notesController.text,
        createdAt: DateTime.now(),
      );

      await FirestoreService.createBooking(booking);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime _calculateFinishDate(DateTime pickupDate) {
    final estimationParts = widget.service.estimasi.split(' ');
    if (estimationParts.length >= 2) {
      final days = int.tryParse(estimationParts[0]) ?? 1;
      return pickupDate.add(Duration(days: days));
    }
    return pickupDate.add(const Duration(days: 2));
  }

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
        // ── Form widget wajib ──────────────────────────────────────
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceCard(),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard() {
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
                  'Pilih Layanan',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFFB0B0B0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.service.nama,
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
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.expand_more, color: Color(0xFFB0B0B0)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Field 1: Alamat dengan validasi ───────────────────────
        _buildFormLabel('Alamat Penjemputan'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _addressController,
          style: GoogleFonts.inter(fontSize: 14),
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Masukkan alamat lengkap penjemputan',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFB0B0B0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          // ── Validasi 1: tidak boleh kosong ─────────────────────
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Alamat penjemputan tidak boleh kosong';
            }
            // ── Validasi 2: minimal 10 karakter ─────────────────
            if (value.trim().length < 10) {
              return 'Alamat terlalu singkat, minimal 10 karakter';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // ── Field 2: Tanggal Jemput ────────────────────────────────
        _buildFormLabel('Tanggal Jemput'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectPickupDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedPickupDate == null
                      ? 'dd/mm/yyyy'
                      : '${_selectedPickupDate!.day.toString().padLeft(2, '0')}/${_selectedPickupDate!.month.toString().padLeft(2, '0')}/${_selectedPickupDate!.year}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: _selectedPickupDate == null
                        ? const Color(0xFFB0B0B0)
                        : Colors.black,
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: Color(0xFFB0B0B0),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Field 3: Sesi Jemput ───────────────────────────────────
        _buildFormLabel('Sesi Jemput'),
        const SizedBox(height: 8),
        _buildSessionDropdown(),
        const SizedBox(height: 24),

        // ── Field 4: Catatan (opsional, dengan validasi panjang) ───
        _buildFormLabel('Catatan (Opsional)'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          style: GoogleFonts.inter(fontSize: 14),
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Misal: Hati-hati baju warna putih',
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFFB0B0B0),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B5BDB)),
            ),
          ),
          // ── Validasi 3: catatan tidak boleh lebih dari 200 karakter
          validator: (value) {
            if (value != null && value.length > 200) {
              return 'Catatan maksimal 200 karakter';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSessionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<String>(
        value: _selectedPickupSession,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedPickupSession = newValue;
            });
          }
        },
        underline: const SizedBox(),
        isExpanded: true,
        items: _sessions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 14),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5BDB),
          disabledBackgroundColor: const Color(0xFFB0B0B0),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Kirim Booking',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
