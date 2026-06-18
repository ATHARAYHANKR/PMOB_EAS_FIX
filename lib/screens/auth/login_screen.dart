import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../staff_main_screen.dart';
import '../owner_main_screen.dart';
import '../customer/customer_main_screen.dart';
import '../../services/firestore_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  static const _accounts = {
    'staff': ('staff123', 'staff'),
    'owner': ('owner123', 'owner'),
    'customer': ('customer123', 'customer'),
  };

  static const Color _blue = Color(0xFF3B5BDB);
  static const Color _blueDark = Color(0xFF2F4AC0);
  static const Color _border = Color(0xFFDDE1F0);
  static const Color _labelColor = Color(0xFF6B7280);

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBg(),
          // dark scrim
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x55000000), Color(0xBB000000)],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
                child: _buildCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ────────────────────────────────────────────────
  Widget _buildBg() {
    return Image.asset(
      'assets/images/bg_login.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          ),
        ),
      ),
    );
  }

  // ── Card utama ────────────────────────────────────────────────
  Widget _buildCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top banner biru ───────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_blue, _blueDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo / icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.local_laundry_service_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                Text('Selamat Datang',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.4,
                    )),
                const SizedBox(height: 4),
                Text('Masuk ke akun CleanGo Anda',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white.withAlpha(180),
                    )),
              ],
            ),
          ),

          // ── Form area ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),

                // ── Field username ────────────────────────────────
                _label('IDENTIFIER'),
                const SizedBox(height: 8),
                _field(
                  controller: _usernameCtrl,
                  hint: 'Email, telepon, atau username',
                  prefix: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 16),

                // ── Field password ────────────────────────────────
                _label('PASSWORD'),
                const SizedBox(height: 8),
                _field(
                  controller: _passwordCtrl,
                  hint: 'Masukkan password',
                  prefix: Icons.lock_outline_rounded,
                  obscure: _obscure,
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black38,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    splashRadius: 20,
                  ),
                ),
                const SizedBox(height: 8),

                // ── Daftar akun baru (kanan) ──────────────────────
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen())),
                    child: Text('Daftar akun baru',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: _blue,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Tombol login ──────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      disabledBackgroundColor: _blue.withAlpha(140),
                      elevation: 4,
                      shadowColor: _blue.withAlpha(100),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.login_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text('Masuk ke Dashboard',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  )),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: label field ───────────────────────────────────────
  Widget _label(String t) => Text(t,
      style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _labelColor,
          letterSpacing: 1.1));

  // ── Helper: text field ────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData prefix,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        prefixIcon: Icon(prefix, color: Colors.black38, size: 20),
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 13.5),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF8F9FD),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _border, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _blue, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
    );
  }

  // ── Login logic ───────────────────────────────────────────────
  Future<void> _login() async {
    final u = _usernameCtrl.text.trim().toLowerCase();
    final p = _passwordCtrl.text.trim();

    if (u.isEmpty || p.isEmpty) {
      _showSnack('Username dan password tidak boleh kosong.', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    // Demo accounts
    final account = _accounts[u];
    if (account != null) {
      if (account.$1 != p) {
        setState(() => _isLoading = false);
        _showSnack('Username atau password salah.', Colors.redAccent);
        return;
      }
      final role = account.$2;
      switch (role) {
        case 'customer':
          FirestoreService.currentUser = {
            'id': 'demo_customer',
            'name': 'Dhira Putri',
            'phone': '081323230001',
            'role': 'customer',
          };
          break;
        case 'owner':
          FirestoreService.currentUser = {
            'id': 'demo_owner',
            'name': 'Pemilik CleanGo',
            'phone': '+62 821 9876 5432',
            'email': 'owner@cleango.id',
            'role': 'owner',
          };
          break;
        case 'staff':
          FirestoreService.currentUser = {
            'id': 'demo_staff',
            'name': 'Karimah',
            'phone': '0812 0000 1111',
            'email': 'karimah@cleango.local',
            'role': 'staff',
          };
          break;
      }
      Widget target;
      switch (role) {
        case 'owner':
          target = const OwnerMainScreen();
          break;
        case 'customer':
          target = const CustomerMainScreen();
          break;
        default:
          target = const StaffMainScreen();
      }
      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => target));
      return;
    }

    // Firestore users
    try {
      final user = await FirestoreService.findUserByCredential(
          usernameOrEmail: u, password: p);
      if (user == null) {
        _showSnack('Username atau password salah.', Colors.redAccent);
        return;
      }
      final role = (user['role'] ?? 'customer').toString();
      FirestoreService.currentUser = user;
      Widget target;
      switch (role) {
        case 'owner':
          target = const OwnerMainScreen();
          break;
        case 'staff':
          target = const StaffMainScreen();
          break;
        default:
          target = const CustomerMainScreen();
      }
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => target));
    } catch (e) {
      _showSnack('Gagal login: $e', Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(16),
    ));
  }
}
