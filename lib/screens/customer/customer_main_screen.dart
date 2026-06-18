import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import 'customer_dashboard_screen.dart';
import 'customer_order_screen.dart';
import 'customer_booking_catalog_screen.dart';
import 'customer_pembayaran_screen.dart';
import 'customer_profil_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  const CustomerMainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<CustomerMainScreen> createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  late int _currentIndex;
  static const Color _blue = Color(0xFF3B5BDB);

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
        children: const [
          CustomerDashboardScreen(),
          CustomerOrderScreen(),
          CustomerBookingCatalogScreen(),
          CustomerPembayaranScreen(),
          CustomerProfilScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return StreamBuilder<List<OrderModel>>(
      // Badge Order: order aktif customer (masuk / dijemput / diproses / konfirmasiBayar)
      stream: FirestoreService.streamOrdersForCurrentCustomer(),
      builder: (context, snapOrder) {
        final orders = snapOrder.data ?? [];

        // Order yang perlu perhatian: status aktif (belum selesai/dibatalkan)
        final countOrder = orders
            .where((o) =>
                o.status == OrderStatus.masuk ||
                o.status == OrderStatus.dijemput ||
                o.status == OrderStatus.perluTimbang ||
                o.status == OrderStatus.dicuci ||
                o.status == OrderStatus.disetrika ||
                o.status == OrderStatus.dikirim)
            .length;

        // Badge Pembayaran: konfirmasiBayar dan belum dibayar
        final countBayar = orders
            .where((o) =>
                o.status == OrderStatus.konfirmasiBayar && !o.isPaid)
            .length;

        return _CustomerNavBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          countOrder: countOrder,
          countBayar: countBayar,
          activeColor: _blue,
        );
      },
    );
  }
}

class _CustomerNavBar extends StatelessWidget {
  const _CustomerNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.countOrder,
    required this.countBayar,
    required this.activeColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final int countOrder;
  final int countBayar;
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
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _badge(Icons.description_outlined, countOrder),
              activeIcon: _badge(Icons.description_rounded, countOrder, active: true),
              label: 'Order',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month_rounded),
              label: 'Booking',
            ),
            BottomNavigationBarItem(
              icon: _badge(Icons.credit_card_outlined, countBayar),
              activeIcon: _badge(Icons.credit_card_rounded, countBayar, active: true),
              label: 'Pembayaran',
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

// ── Animated Badge (sama dengan staff) ──────────────────────────
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
