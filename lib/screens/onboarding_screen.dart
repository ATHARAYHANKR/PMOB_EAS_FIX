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
  double _pageValue = 0;

  static const _pages = [
    _OnboardData(
      gradient: [Color(0xFF3B5BDB), Color(0xFF4A90D9)],
      icon: Icons.local_laundry_service_rounded,
      title: 'Laundry Lebih\nMudah & Cepat',
      subtitle:
          'Pesan layanan laundry kapan saja dan di mana saja. Kami jemput, cuci, dan antar kembali ke rumahmu.',
      illustrationItems: [
        _IllustItem(Icons.dry_cleaning_outlined, 'Cuci Kering'),
        _IllustItem(Icons.iron_outlined, 'Setrika'),
        _IllustItem(Icons.shopping_bag_outlined, 'Antar Jemput'),
      ],
    ),
    _OnboardData(
      gradient: [Color(0xFF1565C0), Color(0xFF42A5F5)],
      icon: Icons.track_changes_rounded,
      title: 'Pantau Status\nOrder Real-time',
      subtitle:
          'Lihat perkembangan cucianmu dari dijemput hingga siap diambil — semuanya bisa dipantau langsung dari aplikasi.',
      illustrationItems: [
        _IllustItem(Icons.inventory_2_outlined, 'Diterima'),
        _IllustItem(Icons.local_shipping_outlined, 'Dijemput'),
        _IllustItem(Icons.done_all_rounded, 'Selesai'),
      ],
    ),
    _OnboardData(
      gradient: [Color(0xFF00897B), Color(0xFF26C6DA)],
      icon: Icons.payment_rounded,
      title: 'Bayar Mudah\nlewat QRIS',
      subtitle:
          'Pembayaran aman dan cepat menggunakan QRIS. Tidak perlu tunai, cukup scan dan selesai!',
      illustrationItems: [
        _IllustItem(Icons.qr_code_2_rounded, 'QRIS'),
        _IllustItem(Icons.shield_outlined, 'Aman'),
        _IllustItem(Icons.flash_on_rounded, 'Instan'),
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
    _pageCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_pageCtrl.hasClients) return;
    final p = _pageCtrl.page;
    if (p != null) {
      setState(() => _pageValue = p);
    }
  }

  @override
  void dispose() {
    _pageCtrl.removeListener(_onScroll);
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
        child: Stack(
          children: [
            // ── Decorative background blobs for depth ──────────
            Positioned(
              top: -50,
              right: -60,
              child: _Blob(size: 200, alpha: 16),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: _Blob(size: 220, alpha: 10),
            ),

            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    // ── Top bar: brand mark + skip ───────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 12, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(40),
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.local_laundry_service_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'CleanGo',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 250),
                            opacity: isLast ? 0.0 : 1.0,
                            child: IgnorePointer(
                              ignoring: isLast,
                              child: GestureDetector(
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
                        ],
                      ),
                    ),

                    // ── PageView with parallax fade/scale ─────────
                    Expanded(
                      child: PageView.builder(
                        controller: _pageCtrl,
                        onPageChanged: (i) =>
                            setState(() => _currentPage = i),
                        itemCount: _pages.length,
                        itemBuilder: (_, i) {
                          final delta = _pageValue - i;
                          final double scale =
                              (1 - delta.abs() * 0.12).clamp(0.85, 1.0).toDouble();
                          final double fade =
                              (1 - delta.abs()).clamp(0.0, 1.0).toDouble();
                          return Opacity(
                            opacity: fade,
                            child: Transform.scale(
                              scale: scale,
                              child: _PageContent(data: _pages[i]),
                            ),
                          );
                        },
                      ),
                    ),

                    // ── Bottom controls ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
                      child: Column(
                        children: [
                          // Smooth "worm" indicator that follows the swipe
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(_pages.length, (i) {
                              final double active = (1 - (_pageValue - i).abs())
                                  .clamp(0.0, 1.0)
                                  .toDouble();
                              final double dotWidth = 8 + (16 * active);
                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: dotWidth,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Color.lerp(
                                    Colors.white.withAlpha(80),
                                    Colors.white,
                                    active,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 28),

                          // CTA Button with tactile press feedback
                          _PrimaryButton(
                            label: isLast ? 'Mulai Sekarang' : 'Lanjut',
                            icon: isLast
                                ? Icons.rocket_launch_rounded
                                : Icons.arrow_forward_rounded,
                            color: page.gradient.first,
                            onTap: _next,
                          ),
                        ],
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
}

// ── Decorative background blob ───────────────────────────────────
class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.alpha});
  final double size;
  final int alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withAlpha(alpha),
        ),
      ),
    );
  }
}

// ── Primary CTA button with tactile press feedback ────────────────
class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  double _scale = 1;

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setScale(0.97),
      onTapUp: (_) => _setScale(1),
      onTapCancel: () => _setScale(1),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 8),
              Icon(widget.icon, size: 18, color: widget.color),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Hero badge: layered "floating sticker" illustration ──
          SizedBox(
            width: 176,
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 176,
                  height: 176,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(18),
                    border: Border.all(
                        color: Colors.white.withAlpha(55), width: 1.5),
                  ),
                ),
                Container(
                  width: 122,
                  height: 122,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(45),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, size: 56, color: data.gradient.first),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // ── Illustration chips (Expanded = never overflows) ──
          Row(
            children: data.illustrationItems
                .map((item) => Expanded(
                      child: _Chip(item: item, accent: data.gradient.first),
                    ))
                .toList(),
          ),
          const SizedBox(height: 40),

          // ── Title ──────────────────────────────────────────
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),

          // ── Subtitle ────────────────────────────────────────
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              data.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                color: Colors.white.withAlpha(210),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Feature chip ────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  const _Chip({required this.item, required this.accent});
  final _IllustItem item;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accent.withAlpha(28),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Icon(item.icon, size: 14, color: accent),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data classes ────────────────────────────────────────────────────
class _OnboardData {
  final List<Color> gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<_IllustItem> illustrationItems;

  const _OnboardData({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.illustrationItems,
  });
}

class _IllustItem {
  final IconData icon;
  final String label;

  const _IllustItem(this.icon, this.label);
}
