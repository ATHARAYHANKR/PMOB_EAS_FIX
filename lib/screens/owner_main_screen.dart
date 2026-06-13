import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner/owner_dashboard_screen.dart';
import 'owner/owner_kelola_screen.dart';
import 'owner/owner_laporan_screen.dart';

class OwnerMainScreen extends StatefulWidget {
  const OwnerMainScreen({super.key, this.initialIndex = 0});
  final int initialIndex;

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  late int _currentIndex;

  static const Color _purple = Color(0xFFBB2BCD);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = const [
    OwnerDashboardScreen(),
    OwnerKelolaScreen(),
    OwnerLaporanScreen(),
  ];

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
          ],
        ),
      ),
    );
  }
}
