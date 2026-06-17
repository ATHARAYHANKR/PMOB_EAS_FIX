import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';
import '../app_theme.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';
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
  StreamSubscription<OrderModel>? _newOrderSub;

  // Screens are built in `build` so we can pass callbacks that use `setState`.

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    // Listen to new order events and show an in-app SnackBar
    _newOrderSub = FirestoreService.newOrderStream.listen((order) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = context;
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text('Order baru: ${order.id} • ${order.customerName}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      });
    });
  }

  @override
  void dispose() {
    _newOrderSub?.cancel();
    super.dispose();
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
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFFB0B0B0),
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2_rounded),
              label: 'Order Masuk',
            ),
            BottomNavigationBarItem(
              icon: StreamBuilder<List<OrderModel>>(
                stream:
                    FirestoreService.streamOrdersByStatus(OrderStatus.masuk),
                builder: (context, snap) {
                  final count = (snap.data ?? []).length;
                  return _badgeIcon(Icons.list_alt_outlined, count);
                },
              ),
              activeIcon: StreamBuilder<List<OrderModel>>(
                stream:
                    FirestoreService.streamOrdersByStatus(OrderStatus.masuk),
                builder: (context, snap) {
                  final count = (snap.data ?? []).length;
                  return _badgeIcon(Icons.list_alt_rounded, count,
                      active: true);
                },
              ),
              label: 'Kelola Order',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.credit_card_outlined),
              activeIcon: Icon(Icons.credit_card_rounded),
              label: 'Konfirmasi Bayar',
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

  Widget _badgeIcon(IconData icon, int count, {bool active = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
