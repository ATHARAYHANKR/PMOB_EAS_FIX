# 📚 Dokumentasi Lengkap CleanGo Project

**Project**: CleanGo - Laundry Management App (Flutter)  
**Status**: Development  
**Last Updated**: 2026-06-18

---

## 📑 Daftar Isi

1. [File Konfigurasi & Utama](#1-file-konfigurasi--utama)
2. [Models](#2-models)
3. [Services](#3-services)
4. [Themes & UI](#4-themes--ui)
5. [Auth Screens](#5-auth-screens)
6. [Staff Screens](#6-staff-screens)
7. [Customer Screens](#7-customer-screens)
8. [Owner Screens](#8-owner-screens)
9. [Dependencies](#9-dependencies)

---

## 1. FILE KONFIGURASI & UTAMA

### 📄 pubspec.yaml
**Lokasi**: `/pubspec.yaml`  
**Fungsi**: Mendefinisikan dependencies dan konfigurasi project Flutter

```yaml
name: cleango_staff                              # Nama package aplikasi
description: CleanGo – Staff App                 # Deskripsi singkat
publish_to: 'none'                               # Tidak dipublikasikan ke pub.dev
version: 1.0.0+1                                 # Version: major.minor.patch + build number

environment:
  sdk: '>=3.0.0 <4.0.0'                         # Versi SDK Dart yang diperlukan

dependencies:                                    # Package dependencies
  flutter:
    sdk: flutter                                 # Core Flutter framework
  google_fonts: ^6.2.1                          # Library untuk font Google
  intl: ^0.19.0                                 # Internationalization (format tanggal, currency)
  firebase_core: ^2.19.0                        # Firebase initialization
  cloud_firestore: ^4.9.0                       # Firestore database untuk real-time sync

dev_dependencies:                                # Dependencies untuk development only
  flutter_test:
    sdk: flutter                                 # Testing framework
  flutter_lints: ^2.0.0                         # Lint rules untuk code quality

flutter:
  uses-material-design: true                     # Menggunakan Material Design 3
  assets:
    - assets/images/                             # Path untuk image assets
```

---

### 📄 main.dart
**Lokasi**: `/lib/main.dart`  
**Fungsi**: Entry point aplikasi, inisialisasi Firebase dan konfigurasi app

```dart
// ═══════════════════════════════════════════════════════════════════
// IMPORTS - Library yang digunakan
// ═══════════════════════════════════════════════════════════════════
import 'package:flutter/material.dart';          // Flutter Material Design
import 'package:flutter/services.dart';          // Akses system services
import 'package:firebase_core/firebase_core.dart'; // Firebase initialization
import 'package:intl/date_symbol_data_local.dart'; // Locale formatting untuk Indonesia
import 'screens/auth/login_screen.dart';         // Login screen widget
import 'app_theme.dart';                         // Tema & warna global
import 'firebase_options.dart';                  # Firebase config (platform-specific)
import 'services/firestore_service.dart';        # Service untuk Firestore database

// ═══════════════════════════════════════════════════════════════════
// MAIN FUNCTION - Entry point aplikasi
// ═══════════════════════════════════════════════════════════════════
void main() async {
  // Memastikan Flutter binding diinisialisasi sebelum async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale Indonesia untuk format tanggal (dd/MM/yyyy, dll)
  await initializeDateFormatting('id', null);

  // Inisialisasi Firebase dengan config platform-specific
  // DefaultFirebaseOptions.currentPlatform akan memilih config sesuai platform
  // (Android, iOS, Web, Windows, macOS)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Firestore service (cek Firebase availability, setup listeners)
  await FirestoreService.initialize();

  // Konfigurasi status bar (bagian paling atas layar Android)
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,    // Membuat status bar transparan
    statusBarIconBrightness: Brightness.dark, // Icon status bar berwarna gelap
  ));

  // Jalankan aplikasi dengan root widget CleanGoApp
  runApp(const CleanGoApp());
}

// ═══════════════════════════════════════════════════════════════════
// MAIN APP WIDGET - Root aplikasi
// ═══════════════════════════════════════════════════════════════════
class CleanGoApp extends StatelessWidget {
  const CleanGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CleanGo Staff',                    // Judul app (task switcher Android)
      debugShowCheckedModeBanner: false,         // Sembunyikan banner "DEBUG"
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,          // Primary color: dark green (#2E7D32)
        ),
        useMaterial3: true,                      // Menggunakan Material Design 3
        scaffoldBackgroundColor: AppColors.bgPage, // Default background: light gray
        fontFamily: 'Inter',                     # Font default: Inter (dari google_fonts)
      ),
      home: const LoginScreen(),                 // Screen pertama saat app dibuka
    );
  }
}
```

---

### 📄 firebase_options.dart
**Lokasi**: `/lib/firebase_options.dart`  
**Fungsi**: Konfigurasi Firebase untuk setiap platform (Android, iOS, Web, Windows, macOS)  
**⚠️ Generated File**: File ini di-generate otomatis oleh `flutterfire configure`

```dart
// File yang di-generate oleh FlutterFire CLI
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Kelas yang menyimpan konfigurasi Firebase untuk setiap platform
/// Menghubungkan app dengan Firebase project 'cleango-pmob'
class DefaultFirebaseOptions {
  
  // ── Getter untuk mendapatkan config platform yang sedang running ──
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {                           // Jika running di Web
      return web;
    }
    switch (defaultTargetPlatform) {        // Deteksi platform saat runtime
      case TargetPlatform.android:
        return android;                     # Konfigurasi Firebase untuk Android
      case TargetPlatform.iOS:
        return ios;                         # Konfigurasi Firebase untuk iOS
      case TargetPlatform.macOS:
        return macos;                       # Konfigurasi Firebase untuk macOS
      case TargetPlatform.windows:
        return windows;                     # Konfigurasi Firebase untuk Windows
      case TargetPlatform.linux:
        throw UnsupportedError(              # Linux tidak didukung
          'DefaultFirebaseOptions have not been configured for linux',
        );
      default:
        throw UnsupportedError('Platform tidak didukung');
    }
  }

  // ── WEB FIREBASE CONFIG ──────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAfSzHf-dgjlMPus3AavCujJS0xpi15MKw',
    appId: '1:48359423210:web:a44fcf63581bd283846b93',
    messagingSenderId: '48359423210',
    projectId: 'cleango-pmob',              # Firebase project ID
    authDomain: 'cleango-pmob.firebaseapp.com',
    databaseURL: 'https://cleango-pmob-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cleango-pmob.firebasestorage.app',
    measurementId: 'G-HEHYQVKZ5B',
  );

  // ── ANDROID FIREBASE CONFIG ─────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDvZgpicPkMWFiApjhtbeA5o61RNjxmyt4',
    appId: '1:48359423210:android:dcb55b805d51e440846b93',
    messagingSenderId: '48359423210',
    projectId: 'cleango-pmob',
    databaseURL: 'https://cleango-pmob-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cleango-pmob.firebasestorage.app',
  );

  // ── iOS FIREBASE CONFIG ──────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB7HJLiyBV6IV4QmTtlFb-riI5G8ihdfy8',
    appId: '1:48359423210:ios:b484f5cbc2bb5286846b93',
    messagingSenderId: '48359423210',
    projectId: 'cleango-pmob',
    databaseURL: 'https://cleango-pmob-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cleango-pmob.firebasestorage.app',
    iosBundleId: 'com.example.cleango',     # Bundle ID untuk iOS app
  );

  // ── macOS FIREBASE CONFIG ────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB7HJLiyBV6IV4QmTtlFb-riI5G8ihdfy8',
    appId: '1:48359423210:ios:b484f5cbc2bb5286846b93',
    messagingSenderId: '48359423210',
    projectId: 'cleango-pmob',
    databaseURL: 'https://cleango-pmob-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cleango-pmob.firebasestorage.app',
    iosBundleId: 'com.example.cleango',
  );

  // ── WINDOWS FIREBASE CONFIG ──────────────────────────────────────
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAfSzHf-dgjlMPus3AavCujJS0xpi15MKw',
    appId: '1:48359423210:web:ef1b18ec8fcda2be846b93',
    messagingSenderId: '48359423210',
    projectId: 'cleango-pmob',
    authDomain: 'cleango-pmob.firebaseapp.com',
    databaseURL: 'https://cleango-pmob-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'cleango-pmob.firebasestorage.app',
    measurementId: 'G-588LFX97Y4',
  );
}
```

---

## 2. MODELS

### 📄 order_model.dart
**Lokasi**: `/lib/models/order_model.dart`  
**Fungsi**: Mendefinisikan OrderStatus enum dan OrderModel class untuk data order

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

// ═══════════════════════════════════════════════════════════════════
// ENUM: ORDER STATUS - Status workflow order
// ═══════════════════════════════════════════════════════════════════
enum OrderStatus {
  masuk,              # Status awal: order masuk, menunggu konfirmasi staff
  dijemput,           # Order telah dijemput dari customer
  perluTimbang,       # Order perlu ditimbang untuk menentukan tarif
  konfirmasiBayar,    # Menunggu customer mengkonfirmasi pembayaran
  dicuci,             # Order sedang dalam proses cuci
  disetrika,          # Order sedang dalam proses setrika
  dikirim,            # Order sedang dikirim kembali ke customer
  selesai,            # Order sudah selesai
  dibatalkan,         # Order dibatalkan
}

// ═══════════════════════════════════════════════════════════════════
// EXTENSION: OrderStatusX - Menambah method pada enum OrderStatus
// ═══════════════════════════════════════════════════════════════════
extension OrderStatusX on OrderStatus {
  // Normalisasi status (untuk mapping legacy values ke status baru)
  OrderStatus get normalized {
    return this;
  }

  // Label step untuk progress indicator (workflow laundry)
  String get stepTitle {
    switch (normalized) {
      case OrderStatus.masuk:
        return 'Menunggu Konfirmasi';  // Step 0: Menunggu staff confirm
      case OrderStatus.dijemput:
        return 'Dijemput';              # Step 1: Barang diambil dari customer
      case OrderStatus.perluTimbang:
        return 'Timbang';               # Step 2: Menimbang berat barang
      case OrderStatus.dicuci:
        return 'Dicuci';                # Step 3a: Proses mencuci
      case OrderStatus.disetrika:
        return 'Disetrika';             # Step 3b: Proses menyetrika
      case OrderStatus.dikirim:
        return 'Dikirim';               # Step 4: Dikirim kembali ke customer
      case OrderStatus.konfirmasiBayar:
        return 'Menunggu Pembayaran';   # Step setelah cuci: tunggu bayar
      case OrderStatus.selesai:
        return 'Selesai';               # Final step: Order selesai
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';            # Cancelled: Order dibatalkan
    }
  }

  // Label user-friendly untuk ditampilkan di UI
  String get statusLabel {
    switch (normalized) {
      case OrderStatus.masuk:
        return 'Menunggu Konfirmasi';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.perluTimbang:
        return 'Perlu Timbang';
      case OrderStatus.dicuci:
        return 'Dicuci';
      case OrderStatus.disetrika:
        return 'Disetrika';
      case OrderStatus.dikirim:
        return 'Dikirim';
      case OrderStatus.konfirmasiBayar:
        return 'Menunggu Pembayaran';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// HELPER FUNCTION: Convert OrderStatus to String untuk Firebase
// ═══════════════════════════════════════════════════════════════════
String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.masuk:
      return 'masuk';                  # String untuk disimpan di Firestore
    case OrderStatus.dijemput:
      return 'dijemput';
    case OrderStatus.perluTimbang:
      return 'perluTimbang';
    case OrderStatus.dicuci:
      return 'dicuci';
    case OrderStatus.disetrika:
      return 'disetrika';
    case OrderStatus.dikirim:
      return 'dikirim';
    case OrderStatus.konfirmasiBayar:
      return 'konfirmasiBayar';
    case OrderStatus.selesai:
      return 'selesai';
    case OrderStatus.dibatalkan:
      return 'dibatalkan';
  }
}

// ═══════════════════════════════════════════════════════════════════
// HELPER FUNCTION: Parse String dari Firebase ke OrderStatus
// ═══════════════════════════════════════════════════════════════════
OrderStatus orderStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    // Legacy values mapping: konversi status lama ke status baru
    case 'diproses':
    case 'diambil':
    case 'dijemput':
      return OrderStatus.dijemput;      # Map legacy names to new status
    case 'perlu timbang':
    case 'perlu_timbang':
    case 'perlutimbang':
    case 'perluTimbang':
      return OrderStatus.perluTimbang;
    case 'dicuci':
      return OrderStatus.dicuci;
    case 'disetrika':
      return OrderStatus.disetrika;
    case 'konfirmasi bayar':
    case 'konfirmasibayar':
    case 'konfirmasiBayar':
    case 'menunggu pembayaran':
      return OrderStatus.konfirmasiBayar;
    case 'dikirim':
      return OrderStatus.dikirim;
    case 'selesai':
      return OrderStatus.selesai;
    case 'dibatalkan':
      return OrderStatus.dibatalkan;
    // Legacy status mapping:
    case 'konfirmasi':
    case 'dicuci & disetrika':
    case 'lunas':
      return OrderStatus.dicuci;        # Map old 'lunas' to new 'dicuci'
    default:
      return OrderStatus.masuk;         # Default ke status awal
  }
}

// ═══════════════════════════════════════════════════════════════════
// CLASS: StatusStep - Satu step dalam progress order
// ═══════════════════════════════════════════════════════════════════
class StatusStep {
  final String title;                   # Nama step (misal: 'Dijemput')
  final String? date;                   # Tanggal step selesai (optional)
  final bool done;                      # Apakah step sudah selesai?
  StatusStep({
    required this.title,
    this.date,
    this.done = false,                  # Default: belum selesai
  });
}

// ═══════════════════════════════════════════════════════════════════
// CLASS: OrderModel - Data structure untuk order
// ═══════════════════════════════════════════════════════════════════
class OrderModel {
  final String id;                      # Unique ID order (misal: ORD-20260618-001)
  final String customerName;            # Nama customer
  final String phone;                   # No. telepon customer
  final String serviceType;             # Jenis layanan (misal: 'Cuci Kering')
  final DateTime pickupDate;            # Tanggal jemput barang
  final String pickupSlot;              # Waktu slot jemput (misal: '08:00 - 10:00')
  final DateTime createdAt;             # Timestamp order dibuat
  OrderStatus status;                   # Status order (bisa berubah)
  double? beratKg;                      # Berat barang (kg) - diisi saat timbang
  double? totalHarga;                   # Total harga order
  bool isPaid;                          # Apakah sudah dibayar?
  String address;                       # Alamat pickup
  String catatan;                       # Catatan/notes dari customer
  List<StatusStep> steps;               # Progress steps order
  DateTime? paymentConfirmedAt;         # Timestamp payment confirmed

  // Constructor
  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.serviceType,
    required this.pickupDate,
    required this.pickupSlot,
    required this.createdAt,
    this.status = OrderStatus.masuk,
    this.beratKg,
    this.totalHarga,
    this.isPaid = false,
    this.address = '',
    this.catatan = '',
    this.steps = const [],
    this.paymentConfirmedAt,
  });

  // Factory constructor: membuat OrderModel dari Firestore document
  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    return OrderModel(
      id: id,
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      serviceType: map['serviceType']?.toString() ?? '',
      pickupDate: map['pickupDate'] is Timestamp
          ? (map['pickupDate'] as Timestamp).toDate()
          : DateTime.parse(map['pickupDate']?.toString() ?? ''),
      pickupSlot: map['pickupSlot']?.toString() ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']?.toString() ?? ''),
      status: orderStatusFromString(map['status']?.toString()),
      beratKg: double.tryParse(map['beratKg']?.toString() ?? ''),
      totalHarga: double.tryParse(map['totalHarga']?.toString() ?? ''),
      isPaid: map['isPaid'] == true || map['isPaid']?.toString() == 'true',
      address: map['address']?.toString() ?? '',
      catatan: map['catatan']?.toString() ?? '',
      paymentConfirmedAt: map['paymentConfirmedAt'] is Timestamp
          ? (map['paymentConfirmedAt'] as Timestamp).toDate()
          : null,
    );
  }

  // Konversi OrderModel ke Map (untuk menyimpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phone': phone,
      'serviceType': serviceType,
      'pickupDate': pickupDate,
      'pickupSlot': pickupSlot,
      'createdAt': createdAt,
      'status': orderStatusToString(status),
      'beratKg': beratKg,
      'totalHarga': totalHarga,
      'isPaid': isPaid,
      'address': address,
      'catatan': catatan,
      'paymentConfirmedAt': paymentConfirmedAt,
    };
  }
}
```

---

### 📄 booking_model.dart
**Lokasi**: `/lib/models/booking_model.dart`  
**Fungsi**: Data model untuk booking/reservasi layanan laundry

```dart
class BookingModel {
  final String id;                      # Unique booking ID
  final String customerId;              # Reference ke customer
  final String katalogId;               # Reference ke katalog layanan
  final String katalogNama;             # Nama layanan (misal: 'Cuci Setrika')
  final int harga;                      # Harga per unit (Rp)
  final String satuan;                  # Satuan (misal: 'Kg', 'Pasang')
  final String alamat;                  # Alamat pickup
  final DateTime tanggalJemput;         # Tanggal pickup
  final DateTime tanggalSelesai;        # Tanggal estimasi selesai
  final String sesiJemput;              # Jam slot pickup
  final String catatan;                 # Catatan dari customer
  final String status;                  # Status booking (pending, confirmed, dll)
  final DateTime createdAt;             # Timestamp booking dibuat

  // Constructor
  BookingModel({
    required this.id,
    required this.customerId,
    required this.katalogId,
    required this.katalogNama,
    required this.harga,
    required this.satuan,
    required this.alamat,
    required this.tanggalJemput,
    required this.tanggalSelesai,
    required this.sesiJemput,
    required this.catatan,
    this.status = 'pending',            # Default status
    required this.createdAt,
  });

  // Factory: Parse dari Map (Firestore)
  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      customerId: map['customerId']?.toString() ?? '',
      katalogId: map['katalogId']?.toString() ?? '',
      katalogNama: map['katalogNama']?.toString() ?? '',
      harga: int.tryParse(map['harga']?.toString() ?? '') ?? 0,
      satuan: map['satuan']?.toString() ?? '',
      alamat: map['alamat']?.toString() ?? '',
      tanggalJemput: map['tanggalJemput'] is DateTime
          ? map['tanggalJemput']
          : DateTime.parse(map['tanggalJemput']?.toString() ?? ''),
      tanggalSelesai: map['tanggalSelesai'] is DateTime
          ? map['tanggalSelesai']
          : DateTime.parse(map['tanggalSelesai']?.toString() ?? ''),
      sesiJemput: map['sesiJemput']?.toString() ?? '08:00 - 10:00 (Pagi)',
      catatan: map['catatan']?.toString() ?? '',
      status: map['status']?.toString() ?? 'pending',
      createdAt: map['createdAt'] is DateTime
          ? map['createdAt']
          : DateTime.parse(map['createdAt']?.toString() ?? ''),
    );
  }

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'katalogId': katalogId,
      'katalogNama': katalogNama,
      'harga': harga,
      'satuan': satuan,
      'alamat': alamat,
      'tanggalJemput': tanggalJemput,
      'tanggalSelesai': tanggalSelesai,
      'sesiJemput': sesiJemput,
      'catatan': catatan,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
```

---

### 📄 katalog_model.dart
**Lokasi**: `/lib/models/katalog_model.dart`  
**Fungsi**: Data model untuk katalog layanan laundry

```dart
class KatalogModel {
  final String id;                      # Unique katalog ID
  final String nama;                    # Nama layanan (misal: 'Cuci Kering')
  final String satuan;                  # Satuan harga (Kg, Pasang, dll)
  final int harga;                      # Harga per satuan (Rp)
  final String estimasi;                # Estimasi durasi (misal: '2 hari')
  final String deskripsi;               # Deskripsi layanan
  final bool aktif;                     # Apakah layanan aktif/tersedia?

  KatalogModel({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    this.aktif = true,                  # Default: aktif
  });

  // Factory: Parse dari Map (Firestore)
  factory KatalogModel.fromMap(String id, Map<String, dynamic> map) {
    return KatalogModel(
      id: id,
      nama: map['nama']?.toString() ?? 'Unknown',
      satuan: map['satuan']?.toString() ?? 'Kg',
      harga: int.tryParse(map['harga']?.toString() ?? '') ?? 0,
      estimasi: map['estimasi']?.toString() ?? '-',
      deskripsi: map['deskripsi']?.toString() ?? '-',
      aktif: map['aktif'] == true || map['aktif']?.toString().toLowerCase() == 'true',
    );
  }

  // Konversi ke Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'satuan': satuan,
      'harga': harga,
      'estimasi': estimasi,
      'deskripsi': deskripsi,
      'aktif': aktif,
    };
  }
}
```

---

## 3. SERVICES

### 📄 firestore_service.dart
**Lokasi**: `/lib/services/firestore_service.dart`  
**Fungsi**: Service untuk handle semua interaksi dengan Firestore database

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/katalog_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  // ───────────────────────────────────────────────────────────────
  // STATIC PROPERTIES - Global state
  // ───────────────────────────────────────────────────────────────
  static bool firebaseAvailable = false;  # Flag: apakah Firebase tersedia?
  static FirebaseFirestore? _db;          # Reference ke Firestore instance
  
  // Local fallback data (saat Firebase tidak available)
  static final List<OrderModel> _localOrders = [];
  static final List<BookingModel> _localBookings = [];
  static final List<Map<String, dynamic>> _localKatalog = [
    // Default katalog layanan (fallback data)
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
    // ... more katalog items
  ];

  // User state
  static Map<String, dynamic>? currentUser;  # Data user yang login

  // ───────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ───────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    try {
      // Firebase.initializeApp() sudah dipanggil di main.dart
      _db = FirebaseFirestore.instance;
      firebaseAvailable = true;
      print('Firebase initialized successfully.');
    } catch (e) {
      firebaseAvailable = false;
      print('Firebase init failed, using local fallback: $e');
    }
  }

  // ───────────────────────────────────────────────────────────────
  // CURRENT USER GETTERS - Akses data user yang login
  // ───────────────────────────────────────────────────────────────
  static String? get currentUserName =>
      currentUser?['name']?.toString().trim().isNotEmpty == true
          ? currentUser!['name'].toString().trim()
          : null;

  static String? get currentUserPhone =>
      currentUser?['phone']?.toString().trim().isNotEmpty == true
          ? currentUser!['phone'].toString().trim()
          : null;

  static String? get currentUserAddress =>
      currentUser?['address']?.toString().trim().isNotEmpty == true
          ? currentUser!['address'].toString().trim()
          : null;

  // ───────────────────────────────────────────────────────────────
  // UPDATE USER PROFILE
  // ───────────────────────────────────────────────────────────────
  static Future<void> updateUserProfile({
    required String name,               # Nama baru customer
    required String phone,              # No. telpon baru
    required String address,            # Alamat baru
  }) async {
    final updated = {
      'name': name,
      'phone': phone,
      'address': address,
    };

    if (!firebaseAvailable) {           # Jika Firebase tidak available
      if (currentUser != null) {
        currentUser = {...currentUser!, ...updated};  # Update local data
      }
      return;
    }

    if (currentUser == null) {
      throw StateError('Pengguna belum login.');
    }
    
    final userId = currentUser!['id']?.toString();
    if (userId == null || userId.isEmpty) {
      throw StateError('ID pengguna tidak tersedia.');
    }
    
    // Update di Firestore: users collection, merge dengan data existing
    await _db!
        .collection('users')
        .doc(userId)
        .set(updated, SetOptions(merge: true));
    
    // Update local currentUser
    currentUser = {...currentUser!, ...updated};
  }

  // ───────────────────────────────────────────────────────────────
  // GET KATALOG - Ambil list katalog layanan
  // ───────────────────────────────────────────────────────────────
  static List<KatalogModel> getKatalog() {
    return _localKatalog
        .map((data) => KatalogModel.fromMap(data['id']?.toString() ?? '', data))
        .toList();
  }

  // ───────────────────────────────────────────────────────────────
  // CREATE BOOKING - Buat booking baru
  // ───────────────────────────────────────────────────────────────
  static Future<void> createBooking(BookingModel booking) async {
    // Generate booking ID jika belum ada
    final bookingId = booking.id.isNotEmpty
        ? booking.id
        : (firebaseAvailable
            ? _db!.collection('bookings').doc().id  # Generate dari Firestore
            : 'booking_${_localBookings.length + 1}'); # Generate local ID

    if (!firebaseAvailable) {
      // Jika Firebase tidak available, simpan ke local list
      _localBookings.add(BookingModel(
        id: bookingId,
        customerId: booking.customerId,
        katalogId: booking.katalogId,
        katalogNama: booking.katalogNama,
        harga: booking.harga,
        satuan: booking.satuan,
        alamat: booking.alamat,
        tanggalJemput: booking.tanggalJemput,
        tanggalSelesai: booking.tanggalSelesai,
        sesiJemput: booking.sesiJemput,
        catatan: booking.catatan,
        status: booking.status,
        createdAt: booking.createdAt,
      ));
    } else {
      // Simpan ke Firestore: bookings collection
      await _db!.collection('bookings').doc(bookingId).set(booking.toMap());
    }

    // Juga buat Order corresponding (untuk history customer)
    final orderId = bookingId;
    final customerName = currentUserName ?? '';
    final phone = currentUserPhone ?? '';

    final order = OrderModel(
      id: orderId,
      customerName: customerName,
      phone: phone,
      serviceType: booking.katalogNama,
      pickupDate: booking.tanggalJemput,
      pickupSlot: booking.sesiJemput,
      status: OrderStatus.masuk,       # Status awal: masuk
      beratKg: null,
      totalHarga: booking.harga.toDouble(),
      address: booking.alamat,
      catatan: booking.catatan,
      steps: const [],
    );

    await addOrder(order);              # Tambah ke orders collection
  }

  // ───────────────────────────────────────────────────────────────
  // STREAM ORDERS
  // ───────────────────────────────────────────────────────────────
  static Stream<List<OrderModel>> streamAllOrders() {
    if (!firebaseAvailable) {
      return Stream.value(_localOrders);
    }
    // Stream dari Firestore: orders, sorted by pickupDate descending
    return _db!
        .collection('orders')
        .orderBy('pickupDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Stream<List<OrderModel>> streamOrdersByStatus(OrderStatus status) {
    if (!firebaseAvailable) {
      return Stream.value(
          _localOrders.where((order) => order.status == status).toList());
    }
    // Filter orders dengan status tertentu
    return _db!
        .collection('orders')
        .where('status', isEqualTo: orderStatusToString(status))
        .orderBy('pickupDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Stream<List<OrderModel>> streamOrdersByStatuses(
      List<OrderStatus> statuses) {
    if (!firebaseAvailable) {
      return Stream.value(_localOrders
          .where((order) => statuses.contains(order.status))
          .toList());
    }
    // Filter orders dengan multiple statuses
    final statusStrings = statuses.map(orderStatusToString).toList();
    return _db!
        .collection('orders')
        .where('status', whereIn: statusStrings)
        .orderBy('pickupDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // ───────────────────────────────────────────────────────────────
  // ADD / UPDATE ORDER
  // ───────────────────────────────────────────────────────────────
  static Future<void> addOrder(OrderModel order) async {
    if (!firebaseAvailable) {
      _localOrders.add(order);           # Tambah ke local list
      return;
    }
    // Simpan ke Firestore: orders collection
    await _db!.collection('orders').doc(order.id).set(order.toMap());
  }

  static Future<void> updateOrderStatus(
    String orderId,
    OrderStatus status,
  ) async {
    if (!firebaseAvailable) {
      final order = _localOrders.firstWhere(
        (o) => o.id == orderId,
        orElse: () => throw Exception('Order not found'),
      );
      order.status = status;
      return;
    }
    // Update status di Firestore
    await _db!
        .collection('orders')
        .doc(orderId)
        .update({'status': orderStatusToString(status)});
  }

  // ... more methods ...
}
```

---

### 📄 notification_helper.dart
**Lokasi**: `/lib/services/notification_helper.dart`  
**Fungsi**: Helper class untuk menampilkan notifikasi (SnackBar, Dialog)

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationHelper {
  // ────────────────────────────────────────────────────────────────
  // SUCCESS SNACKBAR - Notifikasi berhasil
  // ────────────────────────────────────────────────────────────────
  static void showSuccessSnackBar(
    BuildContext context,
    String message,                     # Pesan yang ditampilkan
    {
      Duration duration = const Duration(seconds: 2),  # Durasi tampil
    },
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green,  # Warna latar belakang hijau
        duration: duration,
        behavior: SnackBarBehavior.floating,  # Floating above content
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // ERROR SNACKBAR - Notifikasi error
  // ────────────────────────────────────────────────────────────────
  static void showErrorSnackBar(
    BuildContext context,
    String message,
    {
      Duration duration = const Duration(seconds: 2),
    },
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,  # Warna latar belakang merah
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // WARNING SNACKBAR - Notifikasi peringatan
  // ────────────────────────────────────────────────────────────────
  static void showWarningSnackBar(
    BuildContext context,
    String message,
    {
      Duration duration = const Duration(seconds: 2),
    },
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,  # Warna latar belakang orange
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // INFO SNACKBAR - Notifikasi informasi
  // ────────────────────────────────────────────────────────────────
  static void showInfoSnackBar(
    BuildContext context,
    String message,
    {
      Duration duration = const Duration(seconds: 2),
    },
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3B5BDB),  # Warna latar belakang biru
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // NOTIFICATION DIALOG - Modal dialog untuk notifikasi
  // ────────────────────────────────────────────────────────────────
  static void showNotificationDialog(
    BuildContext context,
    {
      required String title,            # Judul dialog
      required String message,          # Pesan dialog
      String? icon,                     # Emoji/icon (optional)
      String? buttonText,               # Text tombol (optional)
      VoidCallback? onButtonPressed,   # Callback saat tombol ditekan
    },
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,     # Warna overlay
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(icon, style: const TextStyle(fontSize: 56)),
                ),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onButtonPressed ?? () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B5BDB),  # Warna tombol biru
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      buttonText ?? 'OK',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 4. THEMES & UI

### 📄 app_theme.dart
**Lokasi**: `/lib/app_theme.dart`  
**Fungsi**: Mendefinisikan warna global, theme, dan reusable UI components

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/order_model.dart';

// ═══════════════════════════════════════════════════════════════════
// CLASS: AppColors - Palet warna global
// ═══════════════════════════════════════════════════════════════════
class AppColors {
  // Primary colors
  static const primary = Color(0xFF2E7D32);        # Dark green
  static const primaryLight = Color(0xFF4CAF50);  # Medium green
  
  // Background
  static const bgPage = Color(0xFFF5F6FA);        # Light gray background
  static const bgCard = Color(0xFFFFFFFF);        # White card background
  
  // Text
  static const textDark = Color(0xFF1A1A2E);      # Dark text
  static const textGrey = Color(0xFF9E9E9E);      # Grey text
  
  // Status colors
  static const orange = Color(0xFFFF8C42);        # Orange accent
  static const blue = Color(0xFF1E88E5);          # Blue accent
  static const statusGreen = Color(0xFF43A047);  # Green status
  static const statusBlue = Color(0xFF1E88E5);   # Blue status
  static const statusOrange = Color(0xFFFB8C00); # Orange status
}

// ═══════════════════════════════════════════════════════════════════
// CLASS: StatusBadgeConfig - Konfigurasi badge status
// ═══════════════════════════════════════════════════════════════════
/// Mengatur warna background, foreground, dan icon untuk setiap status order
/// Tujuan: Konsistensi tampilan status di semua halaman
class StatusBadgeConfig {
  final Color bg;                       # Warna background badge
  final Color fg;                       # Warna text/foreground
  final IconData icon;                  # Icon untuk status

  const StatusBadgeConfig({
    required this.bg,
    required this.fg,
    required this.icon,
  });

  static StatusBadgeConfig of(OrderStatus status) {
    switch (status) {
      case OrderStatus.masuk:
        return const StatusBadgeConfig(
          bg: Color(0xFFFFF3E0),          # Light orange background
          fg: AppColors.orange,           # Orange text
          icon: Icons.inventory_2_rounded, # Inventory icon
        );
      case OrderStatus.dijemput:
        return const StatusBadgeConfig(
          bg: Color(0xFFD6EEFF),          # Light blue background
          fg: Color(0xFF1565C0),          # Dark blue text
          icon: Icons.delivery_dining_rounded, # Delivery icon
        );
      case OrderStatus.perluTimbang:
        return const StatusBadgeConfig(
          bg: Color(0xFFFFF9C4),          # Light yellow background
          fg: Color(0xFF795548),          # Brown text
          icon: Icons.balance_rounded,    # Scale icon
        );
      case OrderStatus.dicuci:
        return const StatusBadgeConfig(
          bg: Color(0xFFB2DFDB),          # Light teal background
          fg: Color(0xFF00695C),          # Dark teal text
          icon: Icons.local_laundry_service_rounded, # Washing icon
        );
      case OrderStatus.disetrika:
        return const StatusBadgeConfig(
          bg: Color(0xFFD6F5F0),          # Light cyan background
          fg: Color(0xFF00897B),          # Teal text
          icon: Icons.dry_cleaning_rounded, # Ironing icon
        );
      case OrderStatus.dikirim:
        return const StatusBadgeConfig(
          bg: Color(0xFFE3F2FD),          # Light blue background
          fg: Color(0xFF1565C0),          # Dark blue text
          icon: Icons.local_shipping_rounded, # Shipping icon
        );
      case OrderStatus.konfirmasiBayar:
        return const StatusBadgeConfig(
          bg: Color(0xFFEDD6FF),          # Light purple background
          fg: Color(0xFF6A1F9F),          # Dark purple text
          icon: Icons.payments_rounded,   # Payment icon
        );
      case OrderStatus.selesai:
        return const StatusBadgeConfig(
          bg: Color(0xFFE8F5E9),          # Light green background
          fg: AppColors.primary,          # Green text
          icon: Icons.check_circle_rounded, # Check icon
        );
      case OrderStatus.dibatalkan:
        return const StatusBadgeConfig(
          bg: Color(0xFFFFEBEE),          # Light red background
          fg: Color(0xFFC62828),          # Dark red text
          icon: Icons.cancel_rounded,     # Cancel icon
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// CLASS: StatusBadge - Widget badge status reusable
// ═══════════════════════════════════════════════════════════════════
/// Menampilkan chip kecil dengan status order yang konsisten di semua halaman
class StatusBadge extends StatelessWidget {
  final OrderStatus status;             # Status order
  final String? labelOverride;          # Label custom (optional)

  const StatusBadge({
    super.key,
    required this.status,
    this.labelOverride,
  });

  @override
  Widget build(BuildContext context) {
    final cfg = StatusBadgeConfig.of(status);  # Ambil config untuk status ini
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cfg.bg,                  # Background warna dari config
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cfg.fg, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, color: cfg.fg, size: 14),
          const SizedBox(width: 6),
          Text(
            labelOverride ?? status.statusLabel,  # Gunakan custom label atau default
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: cfg.fg,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

Dokumentasi ini mencakup:

✅ **File Konfigurasi** (main.dart, pubspec.yaml, firebase_options.dart)  
✅ **Models** (order_model.dart, booking_model.dart, katalog_model.dart)  
✅ **Services** (firestore_service.dart, notification_helper.dart)  
✅ **Theme & UI** (app_theme.dart dengan StatusBadge)  

File ini sudah tersimpan di: **CODE_DOCUMENTATION.md** di root project.

---

**Untuk melanjutkan ke bagian berikutnya**, apakah Anda ingin saya tambahkan penjelasan untuk:

1. ✅ **Auth Screens** (login_screen.dart, register_screen.dart)
2. ✅ **Staff Screens** (dashboard, order management, payment confirmation)
3. ✅ **Customer Screens** (booking, tracking, payment, profile)
4. ✅ **Owner Screens** (catalogs, staff management, reports)

Atau langsung buka file yang sudah dibuat untuk membaca dokumentasi awal?