import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class FirestoreService {
  static bool firebaseAvailable = false;
  static FirebaseFirestore? _db;

  static final List<OrderModel> _localOrders = [];
  static final List<Map<String, dynamic>> _localKatalog = [
    {
      'id': 'cuci_kering',
      'nama': 'Cuci Kering',
      'satuan': 'Kg',
      'harga': 7000,
      'estimasi': '2 hari',
      'deskripsi': 'Cuci Kering',
      'aktif': true,
    },
    {
      'id': 'cuci_basah',
      'nama': 'Cuci Basah',
      'satuan': 'Kg',
      'harga': 6000,
      'estimasi': '1 hari',
      'deskripsi': 'Cuci Basah',
      'aktif': true,
    },
    {
      'id': 'setrika',
      'nama': 'Setrika',
      'satuan': 'Kg',
      'harga': 5000,
      'estimasi': '1 hari',
      'deskripsi': 'Setrika saja',
      'aktif': true,
    },
    {
      'id': 'cuci_setrika',
      'nama': 'Cuci + Setrika',
      'satuan': 'Kg',
      'harga': 10000,
      'estimasi': '3 hari',
      'deskripsi': 'Cuci dan Setrika',
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

  static final List<Map<String, dynamic>> _localStaff = [];

  static Map<String, dynamic>? currentUser;

  static String? get currentUserName =>
      currentUser?['name']?.toString().trim().isNotEmpty == true
          ? currentUser!['name'].toString().trim()
          : null;

  static String? get currentUserPhone =>
      currentUser?['phone']?.toString().trim().isNotEmpty == true
          ? currentUser!['phone'].toString().trim()
          : null;

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

  static Future<void> updateStatus(String id, OrderStatus status) async {
    if (!firebaseAvailable) {
      final index = _localOrders.indexWhere((order) => order.id == id);
      if (index >= 0) {
        _localOrders[index].status = status;
      }
      return;
    }
    await _db!
        .collection('orders')
        .doc(id)
        .update({'status': orderStatusToString(status)});
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
    if (!firebaseAvailable) {
      final index = _localOrders.indexWhere((order) => order.id == id);
      if (index >= 0) {
        _localOrders[index].beratKg = weightKg;
        _localOrders[index].status = OrderStatus.konfirmasi;
      }
      return;
    }
    await _db!.collection('orders').doc(id).update({
      'beratKg': weightKg,
      'status': orderStatusToString(OrderStatus.konfirmasi),
    });
  }

  static Future<void> addOrder(OrderModel order) async {
    if (!firebaseAvailable) {
      _localOrders.add(order);
      return;
    }
    await _db!.collection('orders').doc(order.id).set(order.toMap());
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
}
