import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';

class EditLayananScreen extends StatefulWidget {
  final String id;
  final String nama;
  final String satuan;
  final int harga;
  final String estimasi;
  final String deskripsi;
  final bool aktif;

  const EditLayananScreen({
    super.key,
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    required this.aktif,
  });

  @override
  State<EditLayananScreen> createState() => _EditLayananScreenState();
}

class _EditLayananScreenState extends State<EditLayananScreen> {
  static const Color _purple = Color(0xFFBB2BCD);

  late TextEditingController _namaCtrl;
  late TextEditingController _hargaCtrl;
  late TextEditingController _deskripsiCtrl;

  late String _satuan;
  late String _estimasi;
  late bool _statusAktif;
  bool _isLoading = false;

  final List<String> _satuanOptions = ['Kg', 'Pcs', 'Lusin', 'Pasang'];
  final List<String> _estimasiOptions = [
    '6 jam',
    '1 hari',
    '2 hari',
    '3 hari',
    '4 hari',
    '5 hari'
  ];

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.nama);
    _hargaCtrl = TextEditingController(text: widget.harga.toString());
    _deskripsiCtrl = TextEditingController(text: widget.deskripsi);
    _satuan = widget.satuan;
    _estimasi = widget.estimasi;
    _statusAktif = widget.aktif;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _hargaCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSimpan() async {
    if (_namaCtrl.text.trim().isEmpty) {
      _showError('Nama layanan tidak boleh kosong');
      return;
    }
    final harga = int.tryParse(
        _hargaCtrl.text.replaceAll('.', '').replaceAll('Rp', '').trim());
    if (harga == null || harga <= 0) {
      _showError('Harga tidak valid');
      return;
    }
    if (_estimasi.isEmpty) {
      _showError('Pilih estimasi pengerjaan');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirestoreService.updateLayanan(widget.id, {
        'nama': _namaCtrl.text.trim(),
        'satuan': _satuan,
        'harga': harga,
        'estimasi': _estimasi,
        'deskripsi': _deskripsiCtrl.text.trim(),
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
              Text('Layanan berhasil\ndiperbarui!',
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
                  Text('Edit Layanan',
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
                    _label('Nama Layanan'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _namaCtrl,
                      hint: 'Cuci Seprai',
                    ),
                    const SizedBox(height: 16),
                    _label('Jenis Satuan'),
                    const SizedBox(height: 8),
                    _dropdown(
                      value: _satuan,
                      items: _satuanOptions,
                      onChanged: (v) => setState(() => _satuan = v ?? _satuan),
                    ),
                    const SizedBox(height: 16),
                    _label('Harga'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _hargaCtrl,
                      hint: 'Rp. 13.000',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                    const SizedBox(height: 16),
                    _label('Estimasi Pengerjaan'),
                    const SizedBox(height: 8),
                    _dropdown(
                      value: _estimasi,
                      items: _estimasiOptions,
                      hint: 'Pilih Estimasi',
                      onChanged: (v) =>
                          setState(() => _estimasi = v ?? _estimasi),
                    ),
                    const SizedBox(height: 16),
                    _label('Deskripsi'),
                    const SizedBox(height: 8),
                    _textField(
                      controller: _deskripsiCtrl,
                      hint: 'Cont: Cuci Kering',
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
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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

  Widget _dropdown({
    required String value,
    required List<String> items,
    String? hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint ?? items.first,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black54)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Colors.black45),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
          items: items
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
