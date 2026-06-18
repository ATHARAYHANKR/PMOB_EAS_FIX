import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardData(
      gradient: [Color(0xFF3B5BDB), Color(0xFF4A90D9)],
      icon: Icons.local_laundry_service_rounded,
      iconBg: Color(0x33FFFFFF),
      title: 'Laundry Lebih\nMudah & Cepat',
      subtitle:
          'Pesan layanan laundry kapan saja dan di mana saja. Kami jemput, cuci, dan antar kembali ke rumahmu.',
      illustrationItems: [
        _IllustItem(Icons.dry_cleaning_outlined,   'Cuci Kering',   Color(0xFFE3F2FD)),
        _IllustItem(Icons.iron_outlined,            'Setrika',       Color(0xFFE8F5E9)),
        _IllustItem(Icons.shopping_bag_outlined,    'Antar Jemput',  Color(0xFFFFF3E0)),
      ],
    ),
    _OnboardData(
      gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      icon: Icons.track_changes_rounded,
      iconBg: Color(0x33FFFFFF),
      title: 'Pantau Status\nOrder Real-time',
      subtitle:
          'Lihat perkembangan cucianmu dari dijemput hingga siap diambil — semuanya bisa dipantau langsung dari aplikasi.',
      illustrationItems: [
        _IllustItem(Icons.inventory_2_outlined,     'Diterima',      Color(0xFFE8F5E9)),
        _IllustItem(Icons.local_shipping_outlined,  'Dijemput',      Color(0xFFE3F2FD)),
        _IllustItem(Icons.done_all_rounded,         'Selesai',       Color(0xFFF3E5F5)),
      ],
    ),
    _OnboardData(
      gradient: [Color(0xFF00897B), Color(0xFF26C6DA)],
      icon: Icons.payment_rounded,
      iconBg: Color(0x33FFFFFF),
      title: 'Bayar Mudah\nlewat QRIS',
      subtitle:
          'Pembayaran aman dan cepat menggunakan QRIS. Tidak perlu tunai, cukup scan dan selesai!',
      illustrationItems: [
        _IllustItem(Icons.qr_code_2_rounded,        'QRIS',          Color(0xFFE8F5E9)),
        _IllustItem(Icons.shield_outlined,          'Aman',          Color(0xFFE3F2FD)),
        _IllustItem(Icons.flash_on_rounded,         'Instan',        Color(0xFFFFF9C4)),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic);
    } else {
      _goLogin();
    }
  }

  void _goLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: page.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Skip button ──────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                  child: isLast
                      ? const SizedBox(height: 36)
                      : GestureDetector(
                          onTap: _goLogin,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Lewati',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                )),
                          ),
                        ),
                ),
              ),

              // ── PageView ─────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (_, i) => _PageContent(data: _pages[i]),
                ),
              ),

              // ── Bottom controls ───────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                child: Column(
                  children: [
                    // Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? Colors.white
                                : Colors.white.withAlpha(80),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _next,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: page.gradient.first,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? 'Mulai Sekarang' : 'Lanjut',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: page.gradient.first,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isLast
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                              color: page.gradient.first,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Page content ───────────────────────────────────────────────────
class _PageContent extends StatelessWidget {
  const _PageContent({required this.data});
  final _OnboardData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // ── Main icon circle ────────────────────────────────
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: data.iconBg,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withAlpha(60), width: 2),
            ),
            child: Icon(data.icon, size: 64, color: Colors.white),
          ),
          const SizedBox(height: 36),

          // ── Illustration chips ──────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: data.illustrationItems
                .map((item) => _Chip(item: item))
                .toList(),
          ),
          const SizedBox(height: 40),

          // ── Title ──────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // ── Subtitle ────────────────────────────────────────
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              color: Colors.white.withAlpha(200),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature chip ────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.item});
  final _IllustItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 16, color: const Color(0xFF3B5BDB)),
          ),
          const SizedBox(width: 7),
          Text(item.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }
}

// ── Data classes ────────────────────────────────────────────────────
class _OnboardData {
  final List<Color> gradient;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final List<_IllustItem> illustrationItems;

  const _OnboardData({
    required this.gradient,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.illustrationItems,
  });
}

class _IllustItem {
  final IconData icon;
  final String label;
  final Color iconBg;

  const _IllustItem(this.icon, this.label, this.iconBg);
}
