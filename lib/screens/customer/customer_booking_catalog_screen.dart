import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/katalog_model.dart';
import '../../services/firestore_service.dart';
import 'detail_booking_screen.dart';

class CustomerBookingCatalogScreen extends StatefulWidget {
  const CustomerBookingCatalogScreen({super.key});

  @override
  State<CustomerBookingCatalogScreen> createState() =>
      _CustomerBookingCatalogScreenState();
}

class _CustomerBookingCatalogScreenState
    extends State<CustomerBookingCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<KatalogModel> _filteredServices = [];
  List<KatalogModel> _allServices = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadServices() {
    final services = FirestoreService.getKatalog();
    setState(() {
      _allServices = services;
      _filteredServices = services;
    });
  }

  void _filterServices() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredServices = _allServices;
      } else {
        _filteredServices = _allServices
            .where((service) =>
                service.nama.toLowerCase().contains(query) ||
                service.deskripsi.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Katalog Layanan',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildServiceGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari layanan laundry',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFFB0B0B0),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFB0B0B0)),
              ),
              style: GoogleFonts.inter(fontSize: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, color: Color(0xFFB0B0B0)),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceGrid() {
    if (_filteredServices.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Layanan tidak ditemukan',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredServices.length,
      itemBuilder: (context, index) {
        return _buildServiceCard(_filteredServices[index]);
      },
    );
  }

  Widget _buildServiceCard(KatalogModel service) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailBookingScreen(service: service),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEF8),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: const Icon(
                Icons.dry_cleaning,
                size: 48,
                color: Color(0xFF3B5BDB),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.nama,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp${service.harga.toString()}/${service.satuan}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF3B5BDB),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Estimasi ${service.estimasi}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: const Color(0xFFB0B0B0),
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
