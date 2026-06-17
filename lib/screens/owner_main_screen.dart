import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_kelola_screen.dart';
import 'owner/owner_laporan_screen.dart';
import 'owner/owner_profil_screen.dart';
import 'dart:async';
import '../services/firestore_service.dart';
import '../models/order_model.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  late int _currentIndex;
  StreamSubscription<OrderModel>? _newOrderSub;

  static const Color _purple = Color(0xFFBB2BCD);

  /// Digunakan agar dashboard / menu cepat dapat membuka tab tertentu
  /// pada halaman Kelola (Katalog / Layanan / Staff).
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
    // Listen for new orders to notify owner
    _newOrderSub = FirestoreService.newOrderStream.listen((order) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    _kelolaTabNotifier.dispose();
    super.dispose();
  }

  /// Navigasi ke tab tertentu pada bottom navigation. Jika [kelolaTab]
  /// diberikan, halaman Kelola akan otomatis berpindah ke sub-tab terkait.
  void _goToTab(int index, {KelolaTab? kelolaTab}) {
    if (kelolaTab != null) {
      _kelolaTabNotifier.value = kelolaTab;
    }
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
          selectedItemColor: _purple,
          unselectedItemColor: const Color(0xFFB0B0B0),
          selectedLabelStyle:
              GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.flash_on_outlined),
              activeIcon: Icon(Icons.flash_on_rounded),
              label: 'Kelola',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
