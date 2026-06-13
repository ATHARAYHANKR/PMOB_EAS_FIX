import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // ─── Warna utama ───────────────────────────────────────────
  static const Color _primaryBlue = Color(0xFF3B5BDB);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background image ──────────────────────────────
          _buildBackground(),

          // ── Dark overlay ──────────────────────────────────
          Container(
            color: Colors.black.withAlpha(89),
          ),

          // ── Login card centered ───────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildLoginCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  BACKGROUND
  // ──────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    // Cek apakah file background tersedia di assets
    // Ganti 'bg_login.jpg' dengan nama file foto yang kamu kirim
    const String bgAsset = 'assets/images/bg_login.jpg';

    return Image.asset(
      bgAsset,
      fit: BoxFit.cover,
      // Jika gambar belum ada, tampilkan gradient sebagai fallback
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF3949AB),
                Color(0xFF5C6BC0),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  CARD
  // ──────────────────────────────────────────────────────────────
  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(46),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────
          _buildHeader(),
          const SizedBox(height: 32),

          // ── Username field ──────────────────────────────
          _buildLabel('USERNAME'),
          const SizedBox(height: 8),
          _buildUsernameField(),
          const SizedBox(height: 20),

          // ── Password field ──────────────────────────────
          _buildLabel('PASSWORD'),
          const SizedBox(height: 8),
          _buildPasswordField(),
          const SizedBox(height: 16),

          // ── Remember me + Daftar ────────────────────────
          _buildBottomRow(),
          const SizedBox(height: 24),

          // ── Login button ────────────────────────────────
          _buildLoginButton(),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  HEADER
  // ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Selamat ',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'Datang',
                style: GoogleFonts.inter(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _primaryBlue,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Masuk ke akun CleanGo Anda',
          style: GoogleFonts.inter(
            fontSize: 13.5,
            color: Colors.black45,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  LABEL
  // ──────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
        letterSpacing: 1.1,
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  TEXT FIELD BASE
  // ──────────────────────────────────────────────────────────────
  InputDecoration _fieldDecoration({
    required IconData prefixIcon,
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      prefixIcon: Icon(prefixIcon, color: Colors.black38, size: 20),
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF7F8FC),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E4F0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _primaryBlue, width: 1.6),
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      keyboardType: TextInputType.text,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
      decoration: _fieldDecoration(
        prefixIcon: Icons.person_outline_rounded,
        hint: 'Masukkan username',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
      decoration: _fieldDecoration(
        prefixIcon: Icons.lock_outline_rounded,
        hint: 'Masukkan password',
        suffix: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.black38,
            size: 20,
          ),
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  REMEMBER ME + DAFTAR
  // ──────────────────────────────────────────────────────────────
  Widget _buildBottomRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Ingat saya
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                fillColor: WidgetStateProperty.all(_primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: const BorderSide(color: Color(0xFFCDD3E0), width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Ingat saya',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.black54,
              ),
            ),
          ],
        ),

        // Daftar akun baru
        GestureDetector(
          onTap: () {
            // TODO: navigasi ke halaman register
          },
          child: Text(
            'Daftar akun baru',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: _primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  LOGIN BUTTON
  // ──────────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _handleLogin,
        icon: const Icon(Icons.login_rounded, color: Colors.white, size: 20),
        label: Text(
          'Masuk ke Dashboard',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: _primaryBlue.withAlpha(115),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  HANDLER
  // ──────────────────────────────────────────────────────────────
  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Username dan password tidak boleh kosong.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // TODO: Hubungkan ke API Laravel CleanGo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Berhasil masuk sebagai $username',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: _primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
