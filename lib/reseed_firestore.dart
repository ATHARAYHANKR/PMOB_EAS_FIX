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

    setState(() => _status = 'Menghapus semua dokumen di koleksi layanan...');
    final deletedLayanan = await _deleteAllDocs(db, 'layanan');

    setState(() => _status = 'Menulis ulang koleksi katalog (20 data)...');
    await _writeDocs(db, 'katalog', _katalogData);

    setState(() => _status = 'Menulis ulang koleksi layanan...');
    await _writeDocs(db, 'layanan', _layananData);

    setState(() => _status = 'Menulis ulang koleksi orders (20 data)...');
    await _writeDocs(db, 'orders', _ordersData);

    final summary = 'RESEED SELESAI ✅\n\n'
        'katalog: $deletedKatalog dokumen lama dihapus, '
        '${_katalogData.length} dokumen baru ditulis\n'
        'layanan: $deletedLayanan dokumen lama dihapus, '
        '${_layananData.length} dokumen baru ditulis\n'
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
// DATA KATALOG (6 item, masing-masing 6 atribut: id, nama, satuan,
// harga, estimasi, deskripsi, aktif)
// ─────────────────────────────────────────────────────────────────
final List<Map<String, dynamic>> _katalogData = [
  {
    'id': 'cuci_kering_regular',
    'nama': 'Cuci Kering Regular',
    'satuan': 'Kg',
    'harga': 7000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci kering standar dengan waktu pengerjaan normal.',
    'aktif': true,
  },
  {
    'id': 'cuci_kering_express',
    'nama': 'Cuci Kering Express',
    'satuan': 'Kg',
    'harga': 12000,
    'estimasi': '1 hari',
    'deskripsi': 'Cuci kering cepat dengan prioritas pengerjaan.',
    'aktif': true,
  },
  {
    'id': 'cuci_setrika_regular',
    'nama': 'Cuci Setrika Regular',
    'satuan': 'Kg',
    'harga': 10000,
    'estimasi': '3 hari',
    'deskripsi': 'Cuci dan setrika standar dengan waktu pengerjaan normal.',
    'aktif': true,
  },
  {
    'id': 'cuci_setrika_express',
    'nama': 'Cuci Setrika Express',
    'satuan': 'Kg',
    'harga': 15000,
    'estimasi': '1 hari',
    'deskripsi': 'Cuci dan setrika cepat dengan prioritas pengerjaan.',
    'aktif': true,
  },
  {
    'id': 'setrika_saja_regular',
    'nama': 'Setrika Saja Regular',
    'satuan': 'Kg',
    'harga': 5000,
    'estimasi': '1 hari',
    'deskripsi': 'Setrika saja standar untuk pakaian bersih.',
    'aktif': true,
  },
  {
    'id': 'setrika_saja_express',
    'nama': 'Setrika Saja Express',
    'satuan': 'Kg',
    'harga': 8000,
    'estimasi': '6 jam',
    'deskripsi': 'Setrika saja cepat dengan prioritas pengerjaan.',
    'aktif': true,
  },
  {
    'id': 'laundry_sepatu_regular',
    'nama': 'Laundry Sepatu Regular',
    'satuan': 'Pasang',
    'harga': 18000,
    'estimasi': '2 hari',
    'deskripsi': 'Layanan cuci sepatu standar dengan waktu pengerjaan normal.',
    'aktif': true,
  },
  {
    'id': 'laundry_sepatu_express',
    'nama': 'Laundry Sepatu Express',
    'satuan': 'Pasang',
    'harga': 27000,
    'estimasi': '1 hari',
    'deskripsi': 'Layanan cuci sepatu cepat dengan prioritas pengerjaan.',
    'aktif': true,
  },
];

final List<Map<String, dynamic>> _layananData = [
  {
    'id': 'cuci_kering',
    'nama': 'Cuci Kering',
    'satuan': 'Kg',
    'harga': 7000,
    'estimasi': '2 hari',
    'deskripsi': 'Layanan cuci kering standar.',
    'aktif': true,
  },
  {
    'id': 'cuci_setrika',
    'nama': 'Cuci Setrika',
    'satuan': 'Kg',
    'harga': 10000,
    'estimasi': '3 hari',
    'deskripsi': 'Layanan cuci dan setrika.',
    'aktif': true,
  },
  {
    'id': 'setrika_saja',
    'nama': 'Setrika Saja',
    'satuan': 'Kg',
    'harga': 5000,
    'estimasi': '1 hari',
    'deskripsi': 'Setrika saja tanpa proses cuci.',
    'aktif': true,
  },
  {
    'id': 'laundry_sepatu',
    'nama': 'Laundry Sepatu',
    'satuan': 'Pcs',
    'harga': 18000,
    'estimasi': '2 hari',
    'deskripsi': 'Cuci sepatu kain dan kanvas.',
    'aktif': true,
  },
];

// ─────────────────────────────────────────────────────────────────
// DATA ORDERS (20 item untuk Dhira dengan berbagai status)
// Harga: Cuci Kering Reg=7000/kg, Express=12000/kg, Cuci Setrika Reg=10000/kg,
//        Express=15000/kg, Setrika Saja Reg=5000/kg, Express=8000/kg,
//        Sepatu Reg=18000/pcs, Express=27000/pcs
// ─────────────────────────────────────────────────────────────────
final List<Map<String, dynamic>> _ordersData = [
  // ── Sesuai screenshot yang terlihat ──────────────────────────────
  // ORD-20260618002: Cuci Setrika Regular, pickup 21 Jun, status masuk
  _order('ORD-20260618002', 'Dhira Putri', '081323230001', 'Cuci Setrika Regular',
      DateTime(2026, 6, 21), '08.00 - 10.00', 'masuk',
      beratKg: 1,
      totalHarga: 10000,
      alamat: 'Jl. Mawar No. 10',
      catatan: '-',
      createdAt: DateTime(2026, 6, 18, 8, 30)),

  // ORD-20260617001: Cuci Kering Express, 2kg, Rp14.000, sudah bayar
  _order('ORD-20260617001', 'Dhira Putri', '081323230001', 'Cuci Kering Express',
      DateTime(2026, 6, 19), '08.00 - 10.00', 'konfirmasiBayar',
      beratKg: 2,
      totalHarga: 14000,
      alamat: 'Jl. Mawar No. 10',
      catatan: '-',
      isPaid: true,
      createdAt: DateTime(2026, 6, 17, 8, 0)),

  // ORD-20260618-60109: Cuci Kering Express, 1kg, Rp7000, selesai/diterima
  _order('ORD-20260618-60109', 'Dhira Putri', '081323230001', 'Cuci Kering Express',
      DateTime(2026, 6, 18), '08.00 - 10.00', 'selesai',
      beratKg: 1,
      totalHarga: 7000,
      alamat: 'Jl. Mawar No. 10',
      catatan: '-',
      createdAt: DateTime(2026, 6, 18, 6, 9)),

  // ── Status aktif lainnya ──────────────────────────────────────────
  _order('ORD-20260616001', 'Dhira Putri', '081323230001', 'Cuci Setrika Express',
      DateTime(2026, 6, 16), '10.00 - 12.00', 'dijemput',
      beratKg: 3,
      totalHarga: 45000,
      alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 16, 9, 0)),

  _order('ORD-20260615001', 'Dhira Putri', '081323230001', 'Cuci Kering Regular',
      DateTime(2026, 6, 15), '08.00 - 10.00', 'perluTimbang',
      alamat: 'Jl. Mawar No. 10',
      catatan: 'Menunggu penimbangan',
      createdAt: DateTime(2026, 6, 15, 7, 30)),

  _order('ORD-20260614001', 'Dhira Putri', '081323230001', 'Cuci Kering Regular',
      DateTime(2026, 6, 14), '08.00 - 10.00', 'dicuci',
      beratKg: 4,
      totalHarga: 28000,
      alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 14, 8, 0)),

  _order('ORD-20260613001', 'Dhira Putri', '081323230001', 'Cuci Setrika Regular',
      DateTime(2026, 6, 13), '14.00 - 16.00', 'disetrika',
      beratKg: 2,
      totalHarga: 20000,
      alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 13, 13, 0)),

  _order('ORD-20260612001', 'Dhira Putri', '081323230001', 'Cuci Kering Express',
      DateTime(2026, 6, 12), '10.00 - 12.00', 'dikirim',
      beratKg: 3,
      totalHarga: 36000,
      alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 12, 9, 0)),

  _order('ORD-20260611001', 'Dhira Putri', '081323230001', 'Laundry Sepatu Regular',
      DateTime(2026, 6, 11), '08.00 - 10.00', 'selesai',
      beratKg: 2,
      totalHarga: 36000,
      alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 11, 8, 0)),

  _order('ORD-20260610001', 'Dhira Putri', '081323230001', 'Cuci Kering Regular',
      DateTime(2026, 6, 10), '08.00 - 10.00', 'selesai',
      beratKg: 6,
      totalHarga: 42000,
      alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 10, 8, 0)),

  _order('ORD-20260609001', 'Dhira Putri', '081323230001', 'Cuci Setrika Regular',
      DateTime(2026, 6, 9), '10.00 - 12.00', 'dibatalkan',
      beratKg: 2.5,
      alamat: 'Jl. Mawar No. 10',
      catatan: 'Dibatalkan oleh pelanggan',
      createdAt: DateTime(2026, 6, 9, 9, 30)),

  // ── Historis (selesai) ────────────────────────────────────────────
  _order('ORD-20260608001', 'Dhira Putri', '081323230001', 'Setrika Saja Regular',
      DateTime(2026, 6, 8), '10.00 - 12.00', 'selesai',
      beratKg: 1.5, totalHarga: 7500, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 8, 9, 0)),

  _order('ORD-20260607001', 'Dhira Putri', '081323230001', 'Cuci Setrika Regular',
      DateTime(2026, 6, 7), '08.00 - 10.00', 'selesai',
      beratKg: 3, totalHarga: 30000, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 7, 8, 0)),

  _order('ORD-20260606001', 'Dhira Putri', '081323230001', 'Cuci Kering Regular',
      DateTime(2026, 6, 6), '14.00 - 16.00', 'selesai',
      beratKg: 4.5, totalHarga: 31500, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 6, 13, 0)),

  _order('ORD-20260605001', 'Dhira Putri', '081323230001', 'Laundry Sepatu Regular',
      DateTime(2026, 6, 5), '10.00 - 12.00', 'selesai',
      beratKg: 2, totalHarga: 36000, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 5, 9, 0)),

  _order('ORD-20260604001', 'Dhira Putri', '081323230001', 'Cuci Kering Express',
      DateTime(2026, 6, 4), '08.00 - 10.00', 'selesai',
      beratKg: 5, totalHarga: 60000, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 4, 8, 0)),

  _order('ORD-20260603001', 'Dhira Putri', '081323230001', 'Cuci Setrika Express',
      DateTime(2026, 6, 3), '08.00 - 10.00', 'selesai',
      beratKg: 3.5, totalHarga: 52500, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 3, 8, 0)),

  _order('ORD-20260602001', 'Dhira Putri', '081323230001', 'Cuci Kering Regular',
      DateTime(2026, 6, 2), '14.00 - 16.00', 'selesai',
      beratKg: 2.5, totalHarga: 17500, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 2, 13, 0)),

  _order('ORD-20260601001', 'Dhira Putri', '081323230001', 'Setrika Saja Regular',
      DateTime(2026, 6, 1), '10.00 - 12.00', 'selesai',
      beratKg: 1.5, totalHarga: 7500, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 6, 1, 9, 0)),

  _order('ORD-20260531001', 'Dhira Putri', '081323230001', 'Cuci Kering Regular',
      DateTime(2026, 5, 31), '08.00 - 10.00', 'selesai',
      beratKg: 6, totalHarga: 42000, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 5, 31, 8, 0)),

  _order('ORD-20260530001', 'Dhira Putri', '081323230001', 'Cuci Setrika Regular',
      DateTime(2026, 5, 30), '08.00 - 10.00', 'selesai',
      beratKg: 4, totalHarga: 40000, alamat: 'Jl. Mawar No. 10',
      createdAt: DateTime(2026, 5, 30, 8, 0)),
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
  String alamat = 'Jl. Mawar No. 10',
  String catatan = '-',
  bool isPaid = false,
  DateTime? createdAt,
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
    'isPaid': isPaid,
    'createdAt': Timestamp.fromDate(createdAt ?? pickupDate),
  };
}
