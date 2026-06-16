// Script untuk MENGHAPUS SEMUA dokumen di koleksi `katalog` dan `orders`,
// lalu mengisi ulang masing-masing dengan 20 dokumen seed.
//
// PERINGATAN: Operasi ini DESTRUKTIF. Semua dokumen lama di koleksi
// `katalog` dan `orders` (termasuk seed sebelumnya) akan dihapus
// permanen sebelum data baru ditulis.
//
// CARA MENJALANKAN:
// 1. Letakkan file ini di folder `lib/` project Flutter Anda,
//    misalnya: lib/reseed_firestore.dart
// 2. Jalankan:
//
//      flutter run -t lib/reseed_firestore.dart -d windows
//
//    (ganti -d windows dengan device/emulator yang Anda gunakan)
//
// 3. Tunggu sampai layar menampilkan "RESEED SELESAI ✅".
// 4. Cek Firebase Console untuk memastikan koleksi `katalog` dan
//    `orders` masing-masing berisi 20 dokumen baru.
// 5. Setelah selesai, hapus file ini dari `lib/`.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const _ReseedApp());
}

class _ReseedApp extends StatefulWidget {
  const _ReseedApp();

  @override
  State<_ReseedApp> createState() => _ReseedAppState();
}

class _ReseedAppState extends State<_ReseedApp> {
  String _status = 'Memulai proses reseed...';

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    final db = FirebaseFirestore.instance;

    setState(() => _status = 'Menghapus semua dokumen di koleksi katalog...');
    final deletedKatalog = await _deleteAllDocs(db, 'katalog');

    setState(() => _status = 'Menghapus semua dokumen di koleksi orders...');
    final deletedOrders = await _deleteAllDocs(db, 'orders');

    setState(() => _status = 'Menulis ulang koleksi katalog (20 data)...');
    await _writeDocs(db, 'katalog', _katalogData);

    setState(() => _status = 'Menulis ulang koleksi orders (20 data)...');
    await _writeDocs(db, 'orders', _ordersData);

    final summary = 'RESEED SELESAI ✅\n\n'
        'katalog: $deletedKatalog dokumen lama dihapus, '
        '${_katalogData.length} dokumen baru ditulis\n'
        'orders: $deletedOrders dokumen lama dihapus, '
        '${_ordersData.length} dokumen baru ditulis';

    setState(() => _status = summary);

    // ignore: avoid_print
    print(summary);
  }

  /// Menghapus seluruh dokumen pada sebuah koleksi, mengembalikan jumlah
  /// dokumen yang dihapus.
  Future<int> _deleteAllDocs(FirebaseFirestore db, String collection) async {
    final col = db.collection(collection);
    var total = 0;

    while (true) {
      final snapshot = await col.limit(300).get();
      if (snapshot.docs.isEmpty) break;

      final batch = db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      total += snapshot.docs.length;
    }

    return total;
  }

  /// Menulis ulang seluruh data ke koleksi (set, bukan merge, agar
  /// dokumen benar-benar fresh).
  Future<void> _writeDocs(
    FirebaseFirestore db,
    String collection,
    List<Map<String, dynamic>> items,
  ) async {
    final col = db.collection(collection);

    final batch = db.batch();
    for (final data in items) {
      final docRef = col.doc(data['id'] as String);
      batch.set(docRef, data);
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Reseed Firestore - CleanGo')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DATA KATALOG (20 item, masing-masing 6 atribut: id, nama, satuan,
// harga, estimasi, deskripsi, aktif)
// ─────────────────────────────────────────────────────────────────
final List<Map<String, dynamic>> _katalogData = [
  {
    'id': 'cuci_kering',
    'nama': 'Cuci Kering',
    'satuan': 'Kg',
    'harga': 7000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci dengan mesin, dikeringkan tanpa setrika.',
    'aktif': true,
  },
  {
    'id': 'cuci_basah',
    'nama': 'Cuci Basah',
    'satuan': 'Kg',
    'harga': 6000,
    'estimasi': '1 hari',
    'deskripsi': 'Cuci dengan mesin tanpa proses pengeringan penuh.',
    'aktif': true,
  },
  {
    'id': 'setrika',
    'nama': 'Setrika',
    'satuan': 'Kg',
    'harga': 5000,
    'estimasi': '1 hari',
    'deskripsi': 'Layanan setrika saja untuk pakaian bersih.',
    'aktif': true,
  },
  {
    'id': 'cuci_setrika',
    'nama': 'Cuci + Setrika',
    'satuan': 'Kg',
    'harga': 10000,
    'estimasi': '3 hari',
    'deskripsi': 'Paket cuci dan setrika lengkap.',
    'aktif': true,
  },
  {
    'id': 'cuci_express',
    'nama': 'Cuci Express 6 Jam',
    'satuan': 'Kg',
    'harga': 15000,
    'estimasi': '6 jam',
    'deskripsi': 'Layanan cepat selesai dalam hari yang sama.',
    'aktif': true,
  },
  {
    'id': 'cuci_selimut',
    'nama': 'Cuci Selimut',
    'satuan': 'Pcs',
    'harga': 25000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci selimut tebal dengan deterjen khusus.',
    'aktif': true,
  },
  {
    'id': 'cuci_bedcover',
    'nama': 'Cuci Bed Cover',
    'satuan': 'Pcs',
    'harga': 30000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci bed cover ukuran besar, termasuk pengeringan.',
    'aktif': true,
  },
  {
    'id': 'cuci_boneka',
    'nama': 'Cuci Boneka',
    'satuan': 'Pcs',
    'harga': 20000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci boneka dengan deterjen lembut, dijemur tanpa mesin.',
    'aktif': true,
  },
  {
    'id': 'cuci_jas',
    'nama': 'Cuci Jas / Blazer',
    'satuan': 'Pcs',
    'harga': 35000,
    'estimasi': '3 hari',
    'deskripsi': 'Dry clean untuk jas dan blazer.',
    'aktif': true,
  },
  {
    'id': 'cuci_gordyn',
    'nama': 'Cuci Gordyn',
    'satuan': 'Kg',
    'harga': 12000,
    'estimasi': '3 hari',
    'deskripsi': 'Cuci gordyn/kain jendela ukuran besar.',
    'aktif': true,
  },
  {
    'id': 'cuci_sepatu',
    'nama': 'Cuci Sepatu',
    'satuan': 'Pcs',
    'harga': 18000,
    'estimasi': '2 hari',
    'deskripsi': 'Deep clean sepatu kain dan kanvas.',
    'aktif': true,
  },
  {
    'id': 'cuci_karpet',
    'nama': 'Cuci Karpet',
    'satuan': 'Pcs',
    'harga': 50000,
    'estimasi': '4 hari',
    'deskripsi': 'Cuci karpet ukuran sedang hingga besar.',
    'aktif': true,
  },
  {
    'id': 'cuci_seragam',
    'nama': 'Cuci Seragam Sekolah',
    'satuan': 'Kg',
    'harga': 8000,
    'estimasi': '1 hari',
    'deskripsi': 'Cuci dan setrika seragam sekolah, rapi siap pakai.',
    'aktif': true,
  },
  {
    'id': 'cuci_handuk',
    'nama': 'Cuci Handuk',
    'satuan': 'Kg',
    'harga': 7000,
    'estimasi': '1 hari',
    'deskripsi': 'Cuci handuk dengan disinfektan tambahan.',
    'aktif': true,
  },
  {
    'id': 'cuci_kemeja',
    'nama': 'Cuci Setrika Kemeja',
    'satuan': 'Pcs',
    'harga': 6000,
    'estimasi': '1 hari',
    'deskripsi': 'Cuci dan setrika khusus kemeja agar tidak kusut.',
    'aktif': true,
  },
  {
    'id': 'cuci_gamis',
    'nama': 'Cuci Gamis / Daster',
    'satuan': 'Pcs',
    'harga': 9000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci dan setrika untuk gamis dan daster.',
    'aktif': true,
  },
  {
    'id': 'setrika_uap',
    'nama': 'Setrika Uap Premium',
    'satuan': 'Kg',
    'harga': 6000,
    'estimasi': '1 hari',
    'deskripsi': 'Setrika menggunakan uap untuk hasil lebih halus.',
    'aktif': true,
  },
  {
    'id': 'cuci_satuan',
    'nama': 'Cuci Satuan (Per Pakaian)',
    'satuan': 'Pcs',
    'harga': 5000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci per item untuk pakaian khusus/sensitif.',
    'aktif': true,
  },
  {
    'id': 'cuci_tas',
    'nama': 'Cuci Tas',
    'satuan': 'Pcs',
    'harga': 40000,
    'estimasi': '3 hari',
    'deskripsi': 'Pembersihan tas kain dan kulit sintetis.',
    'aktif': true,
  },
  {
    'id': 'cuci_mukena',
    'nama': 'Cuci Mukena',
    'satuan': 'Pcs',
    'harga': 15000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci lembut khusus mukena agar kain tetap halus.',
    'aktif': true,
  },
];

// ─────────────────────────────────────────────────────────────────
// DATA ORDERS (20 item, field sesuai OrderModel.toMap(): customerName,
// phone, serviceType, pickupDate, pickupSlot, status, address,
// catatan, opsional beratKg/totalHarga)
// ─────────────────────────────────────────────────────────────────
final List<Map<String, dynamic>> _ordersData = [
  _order('ORD-20260601-001', 'Dhira Putri', '081323230001', 'Cuci Kering',
      DateTime(2026, 6, 1), '08.00 - 10.00 (Pagi)', 'selesai',
      beratKg: 5, totalHarga: 35000, alamat: 'Jl. Mawar No. 10'),
  _order('ORD-20260601-002', 'Budi Santoso', '08567891234', 'Setrika',
      DateTime(2026, 6, 1), '10.00 - 12.00 (Pagi)', 'selesai',
      beratKg: 3, totalHarga: 15000, alamat: 'Jl. Anggrek No. 5'),
  _order('ORD-20260602-001', 'Rina Marlina', '08211234567', 'Cuci Setrika',
      DateTime(2026, 6, 2), '14.00 - 16.00 (Siang)', 'selesai',
      beratKg: 4, totalHarga: 40000, alamat: 'Jl. Melati No. 12'),
  _order('ORD-20260602-002', 'Andi Saputra', '081234567801', 'Cuci Basah',
      DateTime(2026, 6, 2), '08.00 - 10.00 (Pagi)', 'selesai',
      beratKg: 6, totalHarga: 36000, alamat: 'Jl. Kenanga No. 3'),
  _order(
      'ORD-20260603-001',
      'Dhira Putri',
      '081323230001',
      'Cuci Express 6 Jam',
      DateTime(2026, 6, 3),
      '08.00 - 10.00 (Pagi)',
      'selesai',
      beratKg: 2,
      totalHarga: 30000,
      alamat: 'Jl. Mawar No. 10'),
  _order('ORD-20260603-002', 'Siti Aminah', '08198765432', 'Cuci Selimut',
      DateTime(2026, 6, 3), '16.00 - 18.00 (Sore)', 'selesai',
      beratKg: 1, totalHarga: 25000, alamat: 'Jl. Dahlia No. 7'),
  _order('ORD-20260604-001', 'Dhira Putri', '081323230001', 'Cuci Setrika',
      DateTime(2026, 6, 4), '08.00 - 10.00 (Pagi)', 'selesai',
      beratKg: 3, totalHarga: 35000, alamat: 'Jl. Mawar No. 10'),
  _order('ORD-20260604-002', 'Dhira Putri', '081323230001', 'Cuci Setrika',
      DateTime(2026, 6, 4), '08.00 - 10.00 (Pagi)', 'dibatalkan',
      alamat: 'Jl. Mawar No. 10', catatan: 'Dibatalkan oleh pelanggan'),
  _order('ORD-20260605-001', 'Dhira Putri', '081323230001', 'Cuci Kering',
      DateTime(2026, 6, 5), '08.00 - 10.00 (Pagi)', 'dijemput',
      alamat: 'Jl. Mawar No. 10'),
  _order('ORD-20260606-001', 'Dhira Putri', '081323230001', 'Cuci Kering',
      DateTime(2026, 6, 6), '08.00 - 10.00 (Pagi)', 'dijemput',
      beratKg: 5, totalHarga: 35000, alamat: 'Jl. Mawar No. 10'),
  _order('ORD-20260606-002', 'Dhira Putri', '081323230001', 'Cuci Kering',
      DateTime(2026, 6, 8), '08.00 - 10.00 (Pagi)', 'masuk',
      alamat: 'Jl. Mawar No. 10'),
  _order('ORD-20260606-003', 'Rina Marlina', '08211234567', 'Cuci Setrika',
      DateTime(2026, 6, 9), '10.00 - 12.00 (Pagi)', 'perluTimbang',
      alamat: 'Jl. Melati No. 12'),
  _order('ORD-20260606-004', 'Budi Santoso', '08567891234', 'Setrika',
      DateTime(2026, 6, 7), '14.00 - 16.00 (Siang)', 'konfirmasiBayar',
      beratKg: 3.5, alamat: 'Jl. Anggrek No. 5'),
  _order('ORD-20260607-001', 'Andi Saputra', '081234567801', 'Cuci Bed Cover',
      DateTime(2026, 6, 7), '08.00 - 10.00 (Pagi)', 'dijemput',
      alamat: 'Jl. Kenanga No. 3'),
  _order('ORD-20260607-002', 'Siti Aminah', '08198765432', 'Cuci Boneka',
      DateTime(2026, 6, 7), '16.00 - 18.00 (Sore)', 'konfirmasi',
      alamat: 'Jl. Dahlia No. 7'),
  _order('ORD-20260608-001', 'Joko Widodo', '081298765432', 'Cuci Sepatu',
      DateTime(2026, 6, 8), '08.00 - 10.00 (Pagi)', 'masuk',
      alamat: 'Jl. Kamboja No. 8'),
  _order('ORD-20260608-002', 'Maya Sari', '081345678123', 'Cuci Karpet',
      DateTime(2026, 6, 8), '10.00 - 12.00 (Pagi)', 'konfirmasi',
      alamat: 'Jl. Flamboyan No. 2'),
  _order(
      'ORD-20260609-001',
      'Eka Putra',
      '081356789012',
      'Cuci Seragam Sekolah',
      DateTime(2026, 6, 9),
      '08.00 - 10.00 (Pagi)',
      'dijemput',
      alamat: 'Jl. Cempaka No. 14'),
  _order(
      'ORD-20260610-001',
      'Lia Permata',
      '081367890123',
      'Cuci Gamis / Daster',
      DateTime(2026, 6, 10),
      '14.00 - 16.00 (Siang)',
      'masuk',
      alamat: 'Jl. Tanjung No. 9'),
  _order('ORD-20260611-001', 'Dhira Putri', '081323230001', 'Cuci Kering',
      DateTime(2026, 6, 11), '08.00-10.00', 'dijemput',
      alamat: 'Jl. Mawar No. 10'),
];

Map<String, dynamic> _order(
  String id,
  String customerName,
  String phone,
  String serviceType,
  DateTime pickupDate,
  String pickupSlot,
  String status, {
  double? beratKg,
  double? totalHarga,
  String alamat = 'Jl. Mawar No. 105',
  String catatan = '-',
}) {
  return {
    'id': id,
    'customerName': customerName,
    'phone': phone,
    'serviceType': serviceType,
    'pickupDate': Timestamp.fromDate(pickupDate),
    'pickupSlot': pickupSlot,
    'status': status,
    if (beratKg != null) 'beratKg': beratKg,
    if (totalHarga != null) 'totalHarga': totalHarga,
    'address': alamat,
    'catatan': catatan,
  };
}
