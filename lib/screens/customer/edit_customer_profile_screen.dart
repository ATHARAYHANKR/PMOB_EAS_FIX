import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/firestore_service.dart';
import '../../services/notification_helper.dart';

class EditCustomerProfileScreen extends StatefulWidget {
  const EditCustomerProfileScreen({super.key});

  @override
  State<EditCustomerProfileScreen> createState() =>
      _EditCustomerProfileScreenState();
}

class _EditCustomerProfileScreenState extends State<EditCustomerProfileScreen> {
  static const Color _blue = Color(0xFF3B5BDB);

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaCtrl;
  late TextEditingController _teleponCtrl;
  late TextEditingController _alamatCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl =
        TextEditingController(text: FirestoreService.currentUserName ?? '');
    _teleponCtrl =
        TextEditingController(text: FirestoreService.currentUserPhone ?? '');
    _alamatCtrl =
        TextEditingController(text: FirestoreService.currentUserAddress ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _teleponCtrl.dispose();
    _alamatCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirestoreService.updateUserProfile(
        name: _namaCtrl.text.trim(),
        phone: _teleponCtrl.text.trim(),
        address: _alamatCtrl.text.trim(),
      );

      if (mounted) {
        NotificationHelper.showSuccessSnackBar(
            context, 'Profil berhasil diperbarui');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        NotificationHelper.showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                    Text('Edit Profil',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        )),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Nama ────────────────────────────────────
                _label('Nama Lengkap'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _namaCtrl,
                  hintText: 'Masukkan nama lengkap Anda',
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
                const SizedBox(height: 20),

                // ── Nomor Telepon ─────────────────────────────
                _label('Nomor Telepon'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _teleponCtrl,
                  hintText: 'Masukkan nomor telepon',
                  keyboardType: TextInputType.phone,
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
                const SizedBox(height: 20),

                // ── Alamat ──────────────────────────────────
                _label('Alamat'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _alamatCtrl,
                  hintText: 'Masukkan alamat lengkap Anda',
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Alamat wajib diisi';
                    }
                    if (value.trim().length < 5) {
                      return 'Alamat minimal 5 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // ── Save Button ────────────────────────────────
                GestureDetector(
                  onTap: _isSaving ? null : _saveProfile,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isSaving
                          ? _blue.withAlpha(179) // 0.7 opacity
                          : _blue,
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
                        : Text('Simpan Perubahan',
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

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }
}
