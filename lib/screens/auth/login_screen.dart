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
  bool _remember = false;

  // ── Credentials ──────────────────────────────────────────
  // Staff  → username: staff   / password: staff123
  // Owner  → username: owner   / password: owner123
  static const _accounts = {
    'staff': ('staff123', 'staff'),
    'owner': ('owner123', 'owner'),
    'customer': ('customer123', 'customer'),
  };

  static const Color _blue = Color(0xFF3B5BDB);
  static const Color _purple = Color(0xFFBB2BCD);

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBg(),
          Container(color: Colors.black.withAlpha(89)),
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

  Widget _buildBg() {
    return Image.asset(
      'assets/images/bg_login.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
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
          // Header
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Selamat ',
                  style: GoogleFonts.inter(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87)),
              TextSpan(
                  text: 'Datang',
                  style: GoogleFonts.inter(
                      fontSize: 26, fontWeight: FontWeight.w800, color: _blue)),
            ]),
          ),
          const SizedBox(height: 6),
          Text('Masuk ke akun CleanGo Anda',
              style: GoogleFonts.inter(fontSize: 13.5, color: Colors.black45)),
          const SizedBox(height: 28),

          // Hint akun
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCC44DD).withAlpha(80)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Akun Demo:',
                    style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _purple)),
                const SizedBox(height: 4),
                Text('👤 Staff   →  staff / staff123',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text('👑 Owner  →  owner / owner123',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Email / Telepon / Nama
          _label('EMAIL / TELEPON / NAMA'),
          const SizedBox(height: 8),
          _field(
            controller: _usernameCtrl,
            hint: 'Masukkan email, telepon, atau nama',
            prefix: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 18),

          // Password
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
            ),
          ),
          const SizedBox(height: 14),

          // Remember + register
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _remember,
                        onChanged: (v) =>
                            setState(() => _remember = v ?? false),
                        fillColor: WidgetStateProperty.all(_blue),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        side: const BorderSide(
                            color: Color(0xFFCDD3E0), width: 1.5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('Ingat saya',
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.black54)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()));
                    },
                    child: Text('Daftar akun baru',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            color: _blue,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Login button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _login,
              icon: const Icon(Icons.login_rounded,
                  color: Colors.white, size: 20),
              label: Text('Masuk ke Dashboard',
                  style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                elevation: 4,
                shadowColor: _blue.withAlpha(115),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(t,
      style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
          letterSpacing: 1.1));

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
        hintStyle: GoogleFonts.inter(color: Colors.black26, fontSize: 14),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF7F8FC),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E4F0), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF3B5BDB), width: 1.6),
        ),
      ),
    );
  }

  Future<void> _login() async {
    final u = _usernameCtrl.text.trim().toLowerCase();
    final p = _passwordCtrl.text.trim();

    if (u.isEmpty || p.isEmpty) {
      _showSnack('Username dan password tidak boleh kosong.', Colors.redAccent);
      return;
    }

    // First try demo accounts
    final account = _accounts[u];
    if (account != null) {
      if (account.$1 != p) {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => target),
      );
      return;
    }

    // else try Firestore users
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
