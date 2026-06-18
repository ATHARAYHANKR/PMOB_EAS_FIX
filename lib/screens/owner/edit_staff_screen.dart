import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';

class EditStaffScreen extends StatefulWidget {
  final String id;
  final String nama;
  final String telepon;
  final String email;
  final bool aktif;

  const EditStaffScreen({
    super.key,
    required this.id,
    required this.nama,
    required this.telepon,
    required this.email,
    required this.aktif,
  });

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  late TextEditingController _namaCtrl;
  late TextEditingController _teleponCtrl;
  late TextEditingController _emailCtrl;

  late bool _statusAktif;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.nama);
    _teleponCtrl = TextEditingController(text: widget.telepon);
    _emailCtrl = TextEditingController(text: widget.email);
    _statusAktif = widget.aktif;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    if (_namaCtrl.text.trim().isEmpty) {
      _showError('Nama staff tidak boleh kosong');
      return;
    }
    if (_teleponCtrl.text.trim().isEmpty) {
      _showError('Telepon tidak boleh kosong');
      return;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      _showError('Email tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService.updateStaff(widget.id, {
        'nama': _namaCtrl.text.trim(),
        'telepon': _teleponCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'aktif': _statusAktif,
      });

      if (mounted) _showSuksesDialog();
    } catch (e) {
      if (mounted) _showError('Gagal menyimpan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }

  void _showSuksesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: _purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 20),
              Text('Staff berhasil\ndiperbarui!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.4,
                  )),
              const SizedBox(height: 8),
              Text('Perubahan telah disimpan!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.black45,
                  )),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
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
                  child: Text('Tutup',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: Colors.black87),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text('Edit Staff',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      )),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Nama Staff'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _namaCtrl,
                      hint: 'Masukkan nama staff',
                    ),
                    const SizedBox(height: 16),
                    _label('Nomor Telepon'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _teleponCtrl,
                      hint: '+62 812 3456 7890',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _label('Email'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _emailCtrl,
                      hint: 'staff@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Status',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            )),
                        Switch(
                          value: _statusAktif,
                          onChanged: (v) => setState(() => _statusAktif = v),
                          activeThumbColor: _purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onSimpan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _purple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _purple.withAlpha(120),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Simpan Perubahan',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )),
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

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _purple, width: 1.5),
        ),
      ),
    );
  }
}
