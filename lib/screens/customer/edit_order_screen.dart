import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../owner/owner_kelola_screen.dart';

class EditOrderScreen extends StatefulWidget {
  const EditOrderScreen({super.key, required this.order});
  final OrderModel order;

  @override
  State<EditOrderScreen> createState() => _EditOrderScreenState();
}

class _EditOrderScreenState extends State<EditOrderScreen> {
  static const Color _blue = Color(0xFF3B5BDB);

  late KatalogItem _selectedLayanan;
  final _alamatCtrl = TextEditingController(text: 'Jl. Mawar No. 10');
  final _catatanCtrl = TextEditingController();
  DateTime? _tanggalJemput;
  String _sesiJemput = '08.00 - 10.00 (Pagi)';

  final _sesiOptions = const [
    '08.00 - 10.00 (Pagi)',
    '10.00 - 12.00 (Pagi)',
    '14.00 - 16.00 (Siang)',
    '16.00 - 18.00 (Sore)',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLayanan = KatalogRepository.items.firstWhere(
      (i) => i.nama == widget.order.serviceType,
      orElse: () => KatalogRepository.items.isNotEmpty
          ? KatalogRepository.items.first
          : KatalogItem(
              nama: widget.order.serviceType,
              satuan: 'Kg',
              harga: 7000,
              estimasi: '2 hari',
              deskripsi: widget.order.serviceType,
            ),
    );
    _alamatCtrl.text = widget.order.address;
    _catatanCtrl.text =
        widget.order.catatan == '-' ? '' : widget.order.catatan;
    _tanggalJemput = widget.order.pickupDate;
    final slot = widget.order.pickupSlot;
    _sesiJemput = _sesiOptions.firstWhere(
      (s) => s.startsWith(slot.split('-')[0].trim()),
      orElse: () => _sesiOptions.first,
    );
  }

  @override
  void dispose() {
    _alamatCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title bar ─────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_rounded,
                          size: 20, color: Colors.black87),
                    ),
                  ),
                  Text('Edit Order',
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // ── Pilih Layanan ──────────────────────────────
              _label('Pilih Layanan'),
              const SizedBox(height: 8),
              _buildLayananSelector(),
              const SizedBox(height: 20),

              // ── Alamat Penjemputan ───────────────────────────
              _label('Alamat Penjemputan'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: TextField(
                  controller: _alamatCtrl,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Tanggal & Sesi ────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Tanggal Jemput'),
                        const SizedBox(height: 8),
                        _buildDatePicker(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Sesi Jemput'),
                        const SizedBox(height: 8),
                        _buildSesiPicker(),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Catatan ───────────────────────────────────────
              _label('Catatan'),
              const SizedBox(height: 8),
              _buildBoxField(
                child: TextField(
                  controller: _catatanCtrl,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.black87),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Misal: Hati-hati baju warna putih',
                    hintStyle:
                        GoogleFonts.inter(fontSize: 13, color: Colors.black38),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // ── Batalkan & Edit ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _showBatalkanDialog,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _blue, width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text('Batalkan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _blue,
                            )),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _onSimpanEdit,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text('Edit',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ));
  }

  Widget _buildBoxField({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: child,
    );
  }

  // ── Layanan Selector ─────────────────────────────────────────
  Widget _buildLayananSelector() {
    return GestureDetector(
      onTap: _showLayananPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD0DCF8), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFCCCCCC),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selectedLayanan.nama,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _blue,
                      )),
                  Text(
                      'Rp${_formatHarga(_selectedLayanan.harga)}/${_selectedLayanan.satuan.toLowerCase()}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      )),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: _blue, size: 22),
          ],
        ),
      ),
    );
  }

  void _showLayananPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: KatalogRepository.items.map((item) {
              return ListTile(
                title: Text(item.nama,
                    style: GoogleFonts.inter(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: Text(
                    'Rp${_formatHarga(item.harga)}/${item.satuan.toLowerCase()}',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: Colors.black54)),
                onTap: () {
                  setState(() => _selectedLayanan = item);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── Date Picker ──────────────────────────────────────────────
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _tanggalJemput ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 60)),
        );
        if (picked != null) {
          setState(() => _tanggalJemput = picked);
        }
      },
      child: _buildBoxField(
        child: Row(
          children: [
            Expanded(
              child: Text(
                _tanggalJemput == null
                    ? 'dd/mm/yyyy'
                    : '${_tanggalJemput!.day.toString().padLeft(2, '0')}/${_tanggalJemput!.month.toString().padLeft(2, '0')}/${_tanggalJemput!.year}',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _tanggalJemput == null
                      ? Colors.black38
                      : Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  // ── Sesi Picker ──────────────────────────────────────────────
  Widget _buildSesiPicker() {
    return _buildBoxField(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _sesiJemput,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.black45),
          style: GoogleFonts.inter(fontSize: 12, color: Colors.black87),
          items: _sesiOptions
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) {
            if (v != null) setState(() => _sesiJemput = v);
          },
        ),
      ),
    );
  }

  // ── Simpan Edit ────────────────────────────────────────────────
  void _onSimpanEdit() {
    Navigator.pop(context);
  }

  // ── Batalkan Dialog ──────────────────────────────────────────
  void _showBatalkanDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _buildBatalkanDialog(),
    );
  }

  Widget _buildBatalkanDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Yakin batalkan order ini?',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                )),
            const SizedBox(height: 16),
            const Icon(Icons.delete_outline_rounded,
                size: 64, color: Color(0xFF8B4040)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF2E7D32), width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text('Kembali',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          )),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        widget.order.status = OrderStatus.dibatalkan;
                      });
                      Navigator.pop(context); // close dialog
                      Navigator.pop(context); // close edit screen
                    },
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text('Batalkan',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHarga(int h) {
    final s = h.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
