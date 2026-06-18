import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/katalog_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  static bool firebaseAvailable = false;
  static FirebaseFirestore? _db;

  static final List<OrderModel> _localOrders = [];
  static final List<BookingModel> _localBookings = [];
  static final List<Map<String, dynamic>> _localKatalog = [
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
      'deskripsi':
          'Layanan cuci sepatu standar dengan waktu pengerjaan normal.',
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

  static final List<Map<String, dynamic>> _localLayanan = [
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
      'deskripsi': 'Layanan cuci dan setrika lengkap.',
      'aktif': true,
    },
    {
      'id': 'setrika_saja',
      'nama': 'Setrika Saja',
      'satuan': 'Kg',
      'harga': 5000,
      'estimasi': '1 hari',
      'deskripsi': 'Setrika saja tanpa cuci.',
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

  static final List<Map<String, dynamic>> _localUsers = [
    {
      'id': 'demo_customer',
      'name': 'Customer Demo',
      'role': 'customer',
      'email': 'demo@cleango.local',
      'phone': '0000000000',
      'password': 'customer123',
    },
  ];

  static final List<Map<String, dynamic>> _localStaff = [
    {
      'id': 'karimah_staff',
      'nama': 'Karimah',
      'telepon': '0812 0000 1111',
      'email': 'karimah@cleango.local',
      'aktif': true,
    },
  ];

  static Map<String, dynamic>? currentUser;

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

  static Future<void> updateUserProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final updated = {
      'name': name,
      'phone': phone,
      'address': address,
    };

    if (!firebaseAvailable) {
      if (currentUser != null) {
        currentUser = {...currentUser!, ...updated};
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
    await _db!
        .collection('users')
        .doc(userId)
        .set(updated, SetOptions(merge: true));
    currentUser = {...currentUser!, ...updated};
  }

  static List<KatalogModel> getKatalog() {
    return _localKatalog
        .map((data) => KatalogModel.fromMap(data['id']?.toString() ?? '', data))
        .toList();
  }

  static Future<void> createBooking(BookingModel booking) async {
    // Persist booking (bookings collection / local fallback)
    final bookingId = booking.id.isNotEmpty
        ? booking.id
        : (firebaseAvailable
            ? _db!.collection('bookings').doc().id
            : 'booking_${_localBookings.length + 1}');

    if (!firebaseAvailable) {
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
      await _db!.collection('bookings').doc(bookingId).set(booking.toMap());
    }

    // Also create a corresponding Order so it appears in customer history
    final orderId = bookingId; // reuse booking id for simplicity
    final customerName = currentUserName ?? '';
    final phone = currentUserPhone ?? '';

    final order = OrderModel(
      id: orderId,
      customerName: customerName,
      phone: phone,
      serviceType: booking.katalogNama,
      pickupDate: booking.tanggalJemput,
      pickupSlot: booking.sesiJemput,
      status: OrderStatus.masuk,
      beratKg: null,
      totalHarga: booking.harga.toDouble(),
      address: booking.alamat,
      catatan: booking.catatan,
      steps: const [],
    );

    await addOrder(order);
  }

  static Future<void> initialize() async {
    try {
      // Firebase.initializeApp() sudah dipanggil di main.dart dengan
      // DefaultFirebaseOptions hasil `flutterfire configure`.
      _db = FirebaseFirestore.instance;
      firebaseAvailable = true;
      // ignore: avoid_print
      print('Firebase initialized successfully.');
    } catch (e) {
      firebaseAvailable = false;
      // ignore: avoid_print
      print('Firebase init failed, using local fallback: $e');
    }
  }

  static Stream<List<OrderModel>> streamAllOrders() {
    if (!firebaseAvailable) {
      return Stream.value(_localOrders);
    }
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

    final statusStrings =
        statuses.map(orderStatusToString).toList(growable: false);

    return _db!
        .collection('orders')
        .where('status', whereIn: statusStrings)
        .orderBy('pickupDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  static Stream<List<OrderModel>> streamOrdersForCurrentCustomer() {
    if (!firebaseAvailable) {
      final phone = currentUserPhone;
      final name = currentUserName;
      return Stream.value(_localOrders.where((order) {
        if (phone != null && phone.isNotEmpty) {
          return order.phone == phone;
        }
        if (name != null && name.isNotEmpty) {
          return order.customerName == name;
        }
        return false;
      }).toList());
    }

    if (currentUserPhone != null) {
      return _db!
          .collection('orders')
          .where('phone', isEqualTo: currentUserPhone)
          .orderBy('pickupDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
              .toList());
    }
    if (currentUserName != null) {
      return _db!
          .collection('orders')
          .where('customerName', isEqualTo: currentUserName)
          .orderBy('pickupDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(doc.id, doc.data()))
              .toList());
    }
    return Stream.value(<OrderModel>[]);
  }

  static Future<void> createUser(Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      final normalized = Map<String, dynamic>.from(data);
      if (normalized.containsKey('email') && normalized['email'] is String) {
        normalized['email'] = (normalized['email'] as String).toLowerCase();
      }
      normalized['id'] = normalized['email'] ??
          normalized['phone'] ??
          'user_${_localUsers.length + 1}';
      _localUsers.add(normalized);
      return;
    }

    if (data.containsKey('email') && data['email'] is String) {
      data['email'] = (data['email'] as String).toLowerCase();
    }
    final id =
        data['email'] ?? data['phone'] ?? _db!.collection('users').doc().id;
    await _db!
        .collection('users')
        .doc(id.toString())
        .set(data, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> findUserByCredential(
      {required String usernameOrEmail, required String password}) async {
    final key = usernameOrEmail.trim();
    final lowerKey = key.toLowerCase();
    final numericKey = key.replaceAll(RegExp(r'[^0-9]'), '');

    if (!firebaseAvailable) {
      for (final user in _localUsers) {
        final id = user['id']?.toString() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        final phone = user['phone']?.toString() ?? '';
        final name = user['name']?.toString().toLowerCase() ?? '';
        final pass = user['password']?.toString() ?? '';

        if (pass != password) continue;
        if (id == key ||
            email == lowerKey ||
            phone == key ||
            name == lowerKey) {
          return {...user, 'id': id};
        }
      }
      return null;
    }

    final byId = await _db!.collection('users').doc(key).get();
    if (byId.exists) {
      final data = byId.data() as Map<String, dynamic>;
      if ((data['password'] ?? '') == password) {
        return {...data, 'id': byId.id};
      }
    }
    if (lowerKey != key) {
      final byIdLower = await _db!.collection('users').doc(lowerKey).get();
      if (byIdLower.exists) {
        final data = byIdLower.data() as Map<String, dynamic>;
        if ((data['password'] ?? '') == password) {
          return {...data, 'id': byIdLower.id};
        }
      }
    }

    final emailCandidates = {key, lowerKey};
    for (final email in emailCandidates) {
      final qEmail = await _db!
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (qEmail.docs.isNotEmpty) {
        final d = qEmail.docs.first;
        final Map<String, dynamic> data = d.data();
        if ((data['password'] ?? '') == password) {
          return {...data, 'id': d.id};
        }
      }
    }

    final phoneCandidates =
        {key, numericKey}.where((v) => v.isNotEmpty).toSet();
    for (final phone in phoneCandidates) {
      final qPhone = await _db!
          .collection('users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (qPhone.docs.isNotEmpty) {
        final d = qPhone.docs.first;
        final Map<String, dynamic> data = d.data();
        if ((data['password'] ?? '') == password) {
          return {...data, 'id': d.id};
        }
      }
    }

    final qName = await _db!
        .collection('users')
        .where('name', isEqualTo: key)
        .limit(1)
        .get();
    if (qName.docs.isNotEmpty) {
      final d = qName.docs.first;
      final Map<String, dynamic> data = d.data();
      if ((data['password'] ?? '') == password) {
        return {...data, 'id': d.id};
      }
    }
    return null;
  }

  static Future<OrderModel?> getOrderById(String id) async {
    if (!firebaseAvailable) {
      try {
        return _localOrders.firstWhere((order) => order.id == id);
      } catch (_) {
        return null;
      }
    }
    final doc = await _db!.collection('orders').doc(id).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  static Future<void> updateOrder(OrderModel order) async {
    if (!firebaseAvailable) {
      final index = _localOrders.indexWhere((o) => o.id == order.id);
      if (index >= 0) {
        _localOrders[index] = order;
        return;
      }
      throw StateError('Order ${order.id} tidak ditemukan.');
    }

    final docRef = _db!.collection('orders').doc(order.id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw StateError('Order ${order.id} tidak ditemukan di Firestore.');
    }
    await docRef.set(order.toMap(), SetOptions(merge: true));
  }

  static bool _isValidStatusTransition(OrderStatus current, OrderStatus next) {
    if (current == next) return false;
    if (next == OrderStatus.dibatalkan) {
      return current != OrderStatus.selesai &&
          current != OrderStatus.dibatalkan;
    }
    if (current == OrderStatus.selesai || current == OrderStatus.dibatalkan) {
      return false;
    }
    switch (current) {
      case OrderStatus.masuk:
        return next == OrderStatus.dijemput || next == OrderStatus.perluTimbang;
      case OrderStatus.dijemput:
        return next == OrderStatus.perluTimbang;
      case OrderStatus.perluTimbang:
        return next == OrderStatus.konfirmasiBayar;
      case OrderStatus.konfirmasiBayar:
        return next == OrderStatus.dicuci;
      case OrderStatus.dicuci:
        return next == OrderStatus.disetrika;
      case OrderStatus.disetrika:
        return next == OrderStatus.dikirim;
      case OrderStatus.dikirim:
        return next == OrderStatus.selesai;
      default:
        return false;
    }
  }

  static Future<void> updateStatus(String id, OrderStatus status) async {
    if (!firebaseAvailable) {
      final index = _localOrders.indexWhere((order) => order.id == id);
      if (index < 0) {
        throw StateError('Order $id tidak ditemukan.');
      }
      final current = _localOrders[index].status;
      if (!_isValidStatusTransition(current, status)) {
        throw StateError(
            'Transisi status tidak valid: ${current.stepTitle} → ${status.stepTitle}');
      }
      _localOrders[index].status = status;
      return;
    }

    final docRef = _db!.collection('orders').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw StateError('Order $id tidak ditemukan.');
    }
    final currentOrder =
        OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    if (!_isValidStatusTransition(currentOrder.status, status)) {
      throw StateError(
          'Transisi status tidak valid: ${currentOrder.status.stepTitle} → ${status.stepTitle}');
    }
    await docRef.update({'status': orderStatusToString(status)});
  }

  static Future<void> cancelOrder(String id) async {
    await updateStatus(id, OrderStatus.dibatalkan);
  }

  static Future<void> advanceStatus(OrderModel order) async {
    final next = order.nextStatus;
    if (next != null) {
      await updateStatus(order.id, next);
    }
  }

  static Future<void> updateWeightAndConfirm(String id, double weightKg) async {
    final totalHarga = weightKg * 7000;

    if (!firebaseAvailable) {
      final index = _localOrders.indexWhere((order) => order.id == id);
      if (index < 0) {
        throw StateError('Order $id tidak ditemukan.');
      }
      final current = _localOrders[index].status;
      if (current != OrderStatus.dijemput &&
          current != OrderStatus.perluTimbang) {
        throw StateError(
            'Transisi status tidak valid: ${current.stepTitle} → ${OrderStatus.konfirmasiBayar.stepTitle}');
      }
      _localOrders[index].beratKg = weightKg;
      _localOrders[index].totalHarga = totalHarga;
      _localOrders[index].isPaid = false;
      _localOrders[index].status = OrderStatus.konfirmasiBayar;
      return;
    }

    final docRef = _db!.collection('orders').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw StateError('Order $id tidak ditemukan.');
    }
    final currentOrder =
        OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    if (currentOrder.status != OrderStatus.dijemput &&
        currentOrder.status != OrderStatus.perluTimbang) {
      throw StateError(
          'Transisi status tidak valid: ${currentOrder.status.stepTitle} → ${OrderStatus.konfirmasiBayar.stepTitle}');
    }
    await docRef.update({
      'beratKg': weightKg,
      'totalHarga': totalHarga,
      'isPaid': false,
      'status': orderStatusToString(OrderStatus.konfirmasiBayar),
    });
  }

  static Future<void> markCustomerPaid(String id) async {
    if (!firebaseAvailable) {
      final index = _localOrders.indexWhere((order) => order.id == id);
      if (index < 0) {
        throw StateError('Order $id tidak ditemukan.');
      }
      if (_localOrders[index].status != OrderStatus.konfirmasiBayar) {
        throw StateError('Order $id belum memiliki tagihan aktif.');
      }
      _localOrders[index].isPaid = true;
      return;
    }

    final docRef = _db!.collection('orders').doc(id);
    final doc = await docRef.get();
    if (!doc.exists) {
      throw StateError('Order $id tidak ditemukan.');
    }
    final order =
        OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    if (order.status != OrderStatus.konfirmasiBayar) {
      throw StateError('Order $id belum memiliki tagihan aktif.');
    }
    await docRef.update({'isPaid': true});
  }

  static Future<void> addOrder(OrderModel order) async {
    // Ensure order has an ORD-... id; generate based on createdAt date if missing
    OrderModel toSave = order;
    if (order.id.isEmpty || !order.id.startsWith('ORD-')) {
      final generated = await _generateOrderId(order.createdAt);
      toSave = order.copyWith(id: generated, createdAt: order.createdAt);
    }

    if (!firebaseAvailable) {
      _localOrders.add(toSave);
      return;
    }

    await _db!.collection('orders').doc(toSave.id).set(toSave.toMap());
  }

  static Future<String> _generateOrderId(DateTime createdAt) async {
    final y = createdAt.year.toString().padLeft(4, '0');
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    final datePart = '$y$m$d';

    if (!firebaseAvailable) {
      final count = _localOrders
          .where((o) =>
              o.createdAt.year == createdAt.year &&
              o.createdAt.month == createdAt.month &&
              o.createdAt.day == createdAt.day)
          .length;
      final seq = count + 1;
      return 'ORD-$datePart${seq.toString().padLeft(3, '0')}';
    }

    final dayStart = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final snap = await _db!
        .collection('orders')
        .where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('createdAt', isLessThan: Timestamp.fromDate(dayEnd))
        .get();
    final seq = snap.docs.length + 1;
    return 'ORD-$datePart${seq.toString().padLeft(3, '0')}';
  }

  static Stream<List<Map<String, dynamic>>> streamKatalogRaw() {
    if (!firebaseAvailable) {
      return Stream.value(_localKatalog.map((item) => {...item}).toList());
    }
    return _db!.collection('katalog').snapshots().map(
        (snap) => snap.docs.map((d) => {...(d.data()), 'id': d.id}).toList());
  }

  static Future<void> addKatalog(Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      _localKatalog.add(
          {...data, 'id': data['id'] ?? 'katalog_${_localKatalog.length + 1}'});
      return;
    }
    await _db!.collection('katalog').add(data);
  }

  static Stream<List<Map<String, dynamic>>> streamStaffRaw() {
    if (!firebaseAvailable) {
      return Stream.value(_localStaff.map((item) => {...item}).toList());
    }
    return _db!.collection('staff').snapshots().map(
        (snap) => snap.docs.map((d) => {...(d.data()), 'id': d.id}).toList());
  }

  static Future<void> addStaff(Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      _localStaff.add(
          {...data, 'id': data['id'] ?? 'staff_${_localStaff.length + 1}'});
      return;
    }
    await _db!.collection('staff').add(data);
  }

  static Stream<List<Map<String, dynamic>>> streamLayananRaw() {
    if (!firebaseAvailable) {
      return Stream.value(_localLayanan.map((item) => {...item}).toList());
    }
    return _db!.collection('layanan').snapshots().map(
        (snap) => snap.docs.map((d) => {...(d.data()), 'id': d.id}).toList());
  }

  static Future<void> addLayanan(Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      _localLayanan.add(
          {...data, 'id': data['id'] ?? 'layanan_${_localLayanan.length + 1}'});
      return;
    }
    await _db!.collection('layanan').add(data);
  }

  // ── Update & Delete Katalog ─────────────────────────────────
  static Future<void> updateKatalog(
      String id, Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      final idx = _localKatalog.indexWhere((k) => k['id'] == id);
      if (idx >= 0) {
        _localKatalog[idx] = {..._localKatalog[idx], ...data};
      }
      return;
    }
    await _db!.collection('katalog').doc(id).update(data);
  }

  static Future<void> deleteKatalog(String id) async {
    if (!firebaseAvailable) {
      _localKatalog.removeWhere((k) => k['id'] == id);
      return;
    }
    await _db!.collection('katalog').doc(id).delete();
  }

  // ── Update & Delete Layanan ────────────────────────────────
  static Future<void> updateLayanan(
      String id, Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      final idx = _localLayanan.indexWhere((l) => l['id'] == id);
      if (idx >= 0) {
        _localLayanan[idx] = {..._localLayanan[idx], ...data};
      }
      return;
    }
    await _db!.collection('layanan').doc(id).update(data);
  }

  static Future<void> deleteLayanan(String id) async {
    if (!firebaseAvailable) {
      _localLayanan.removeWhere((l) => l['id'] == id);
      return;
    }
    await _db!.collection('layanan').doc(id).delete();
  }

  // ── Update & Delete Staff ───────────────────────────────────
  static Future<void> updateStaff(String id, Map<String, dynamic> data) async {
    if (!firebaseAvailable) {
      final idx = _localStaff.indexWhere((s) => s['id'] == id);
      if (idx >= 0) {
        _localStaff[idx] = {..._localStaff[idx], ...data};
      }
      return;
    }
    await _db!.collection('staff').doc(id).update(data);
  }

  static Future<void> deleteStaff(String id) async {
    if (!firebaseAvailable) {
      _localStaff.removeWhere((s) => s['id'] == id);
      return;
    }
    await _db!.collection('staff').doc(id).delete();
  }
}
