import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerLaporanScreen extends StatelessWidget {
  const OwnerLaporanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: Center(
          child: Text('Laporan',
              style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87)),
        ),
      ),
    );
  }
}
