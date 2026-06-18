import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';
import 'staff/dashboard_screen.dart';
import 'staff/order_masuk_screen.dart';
import 'staff/kelola_order_screen.dart';
import 'staff/konfirmasi_bayar_screen.dart';
import 'staff/profil_screen.dart';

class StaffMainScreen extends StatefulWidget {
  const StaffMainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<StaffMainScreen> createState() => _StaffMainScreenState();
}

class _StaffMainScreenState extends State<StaffMainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(onNavigate: (i) => setState(() => _currentIndex = i)),
          const OrderMasukScreen(),
          const KelolaOrderScreen(),
          const KonfirmasiBayarScreen(),
          const ProfilScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return StreamBuilder<List<OrderModel>>(
      // Badge Order Masuk: status 'masuk'
      stream: FirestoreService.streamOrdersByStatus(OrderStatus.masuk),
      builder: (context, snapMasuk) {
        final countMasuk = snapMasuk.data?.length ?? 0;

        return StreamBuilder<List<OrderModel>>(
          // Badge Kelola Order: status aktif (dijemput, perluTimbang, dicuci, disetrika, dikirim)
          stream: FirestoreService.streamOrdersByStatuses([
            OrderStatus.dijemput,
            OrderStatus.perluTimbang,
            OrderStatus.dicuci,
            OrderStatus.disetrika,
            OrderStatus.dikirim,
          ]),
          builder: (context, snapKelola) {
            final countKelola = snapKelola.data?.length ?? 0;

            return StreamBuilder<List<OrderModel>>(
              // Badge Konfirmasi Bayar: isPaid=true belum dikonfirmasi
              stream: FirestoreService.streamOrdersByStatus(OrderStatus.konfirmasiBayar),
              builder: (context, snapBayar) {
                final countBayar = snapBayar.data
                        ?.where((o) => o.isPaid)
                        .length ??
                    0;

                return _NavBar(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                  countMasuk: countMasuk,
                  countKelola: countKelola,
                  countBayar: countBayar,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ── Bottom Nav Widget ──────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.currentIndex,
    required this.onTap,
    required this.countMasuk,
    required this.countKelola,
    required this.countBayar,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int countMasuk;
  final int countKelola;
  final int countBayar;

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
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFFB0B0B0),
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _badge(Icons.inventory_2_outlined, countMasuk),
              activeIcon: _badge(Icons.inventory_2_rounded, countMasuk, active: true),
              label: 'Order Masuk',
            ),
            BottomNavigationBarItem(
              icon: _badge(Icons.list_alt_outlined, countKelola),
              activeIcon: _badge(Icons.list_alt_rounded, countKelola, active: true),
              label: 'Kelola Order',
            ),
            BottomNavigationBarItem(
              icon: _badge(Icons.credit_card_outlined, countBayar),
              activeIcon: _badge(Icons.credit_card_rounded, countBayar, active: true),
              label: 'Konfirmasi B.',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil Saya',
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
