import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_kelola_screen.dart';
import 'owner/owner_laporan_screen.dart';
import 'owner/owner_profil_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  late int _currentIndex;
  static const Color _purple = Color(0xFFBB2BCD);

  final ValueNotifier<KelolaTab> _kelolaTabNotifier =
      ValueNotifier(KelolaTab.katalog);

  late final List<Widget> _screens = [
    OwnerDashboardScreen(onNavigateTab: _goToTab),
    OwnerKelolaScreen(tabNotifier: _kelolaTabNotifier),
    const OwnerLaporanScreen(),
    const OwnerProfilScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void dispose() {
    _kelolaTabNotifier.dispose();
    super.dispose();
  }

  void _goToTab(int index, {KelolaTab? kelolaTab}) {
    if (kelolaTab != null) _kelolaTabNotifier.value = kelolaTab;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    // Owner melihat total order yang sedang aktif (semua status non-final)
    return StreamBuilder<List<OrderModel>>(
      stream: FirestoreService.streamOrdersByStatuses([
        OrderStatus.masuk,
        OrderStatus.dijemput,
        OrderStatus.perluTimbang,
        OrderStatus.konfirmasiBayar,
        OrderStatus.dicuci,
        OrderStatus.disetrika,
        OrderStatus.dikirim,
      ]),
      builder: (context, snap) {
        // Badge di Beranda: total order aktif
        final countAktif = snap.data?.length ?? 0;

        return _OwnerNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          countAktif: countAktif,
          activeColor: _purple,
        );
      },
    );
  }
}

class _OwnerNavBar extends StatelessWidget {
  const _OwnerNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.countAktif,
    required this.activeColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int countAktif;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: activeColor,
          unselectedItemColor: const Color(0xFFB0B0B0),
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: _badge(Icons.home_outlined, countAktif),
              activeIcon: _badge(Icons.home_rounded, countAktif, active: true),
              label: 'Beranda',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_outlined),
              activeIcon: Icon(Icons.flash_on_rounded),
              label: 'Kelola',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Laporan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, int count, {bool active = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -8,
            top: -5,
            child: _AnimatedBadge(count: count),
          ),
      ],
    );
  }
}

// ── Animated Badge ──────────────────────────────────────────────
class _AnimatedBadge extends StatefulWidget {
  const _AnimatedBadge({required this.count});
  final int count;

  @override
  State<_AnimatedBadge> createState() => _AnimatedBadgeState();
}

class _AnimatedBadgeState extends State<_AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  int _prevCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.45).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
    _prevCount = widget.count;
  }

  @override
  void didUpdateWidget(_AnimatedBadge old) {
    super.didUpdateWidget(old);
    if (widget.count != _prevCount) {
      _prevCount = widget.count;
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.count > 99 ? '99+' : '${widget.count}';
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withAlpha(120),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
