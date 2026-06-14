import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final CollectionReference _ordersRef = _db.collection('orders');

  static final CollectionReference _usersRef = _db.collection('users');
  static final CollectionReference _katalogRef = _db.collection('katalog');
  static final CollectionReference _staffRef = _db.collection('staff');

  static Map<String, dynamic>? currentUser;

  static String? get currentUserName =>
      currentUser?['name']?.toString().trim().isEmpty == false
          ? currentUser!['name'].toString().trim()
          : null;

  static String? get currentUserPhone =>
      currentUser?['phone']?.toString().trim().isEmpty == false
          ? currentUser!['phone'].toString().trim()
          : null;

  static Stream<List<OrderModel>> streamAllOrders() {
    return _ordersRef.orderBy('pickupDate', descending: true).snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList(),
        );
  }

  static Stream<List<OrderModel>> streamOrdersForCurrentCustomer() {
    if (currentUserPhone != null) {
      return _ordersRef
          .where('phone', isEqualTo: currentUserPhone)
          .orderBy('pickupDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    }
    if (currentUserName != null) {
      return _ordersRef
          .where('customerName', isEqualTo: currentUserName)
          .orderBy('pickupDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => OrderModel.fromMap(
                  doc.id, doc.data() as Map<String, dynamic>))
              .toList());
    }
    return Stream.value(<OrderModel>[]);
  }

  /// Create a new user document in `users` collection.
  /// `data` must contain at least: name, email, phone, password, role
  static Future<void> createUser(Map<String, dynamic> data) async {
    // normalize email to lowercase if present
    if (data.containsKey('email') && data['email'] is String) {
      data['email'] = (data['email'] as String).toLowerCase();
    }
    final id = data['email'] ?? data['phone'] ?? _usersRef.doc().id;
    await _usersRef.doc(id.toString()).set(data, SetOptions(merge: true));
  }

  /// Find user by email/username and password. Returns map or null.
  static Future<Map<String, dynamic>?> findUserByCredential(
      {required String usernameOrEmail, required String password}) async {
    final key = usernameOrEmail.trim();
    final lowerKey = key.toLowerCase();
    final numericKey = key.replaceAll(RegExp(r'[^0-9]'), '');

    // Try doc lookup by id first (support emails stored as lowercase or original case)
    final byId = await _usersRef.doc(key).get();
    if (byId.exists) {
      final data = byId.data() as Map<String, dynamic>;
      if ((data['password'] ?? '') == password) {
        return {...data, 'id': byId.id};
      }
    }
    if (lowerKey != key) {
      final byIdLower = await _usersRef.doc(lowerKey).get();
      if (byIdLower.exists) {
        final data = byIdLower.data() as Map<String, dynamic>;
        if ((data['password'] ?? '') == password) {
          return {...data, 'id': byIdLower.id};
        }
      }
    }

    // try querying by email field with both original and lowercase email
    final emailCandidates = {key, lowerKey};
    for (final email in emailCandidates) {
      final qEmail =
          await _usersRef.where('email', isEqualTo: email).limit(1).get();
      if (qEmail.docs.isNotEmpty) {
        final d = qEmail.docs.first;
        final data = d.data() as Map<String, dynamic>;
        if ((data['password'] ?? '') == password) {
          return {...data, 'id': d.id};
        }
      }
    }

    // fallback: search by phone field with original and normalized number
    final phoneCandidates =
        {key, numericKey}.where((v) => v.isNotEmpty).toSet();
    for (final phone in phoneCandidates) {
      final qPhone =
          await _usersRef.where('phone', isEqualTo: phone).limit(1).get();
      if (qPhone.docs.isNotEmpty) {
        final d = qPhone.docs.first;
        final data = d.data() as Map<String, dynamic>;
        if ((data['password'] ?? '') == password) {
          return {...data, 'id': d.id};
        }
      }
    }

    // final fallback: search by name field
    final qName = await _usersRef.where('name', isEqualTo: key).limit(1).get();
    if (qName.docs.isNotEmpty) {
      final d = qName.docs.first;
      final data = d.data() as Map<String, dynamic>;
      if ((data['password'] ?? '') == password) {
        return {...data, 'id': d.id};
      }
    }

    return null;
  }

  /// Ambil satu order berdasarkan ID (untuk halaman detail)
  static Future<OrderModel?> getOrderById(String id) async {
    final doc = await _ordersRef.doc(id).get();
    if (!doc.exists) return null;
    return OrderModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  /// Update status order
  static Future<void> updateStatus(String id, OrderStatus status) async {
    await _ordersRef.doc(id).update({'status': orderStatusToString(status)});
  }

  /// Update berat & ubah status jadi konfirmasiBayar
  static Future<void> updateWeightAndConfirm(String id, double weightKg) async {
    await _ordersRef.doc(id).update({
      'beratKg': weightKg,
      'status': orderStatusToString(OrderStatus.konfirmasiBayar),
    });
  }

  /// Tambah order baru (untuk form tambah data)
  static Future<void> addOrder(OrderModel order) async {
    await _ordersRef.doc(order.id).set(order.toMap());
  }

  /// Stream katalog layanan
  static Stream<List<Map<String, dynamic>>> streamKatalogRaw() {
    return _katalogRef.snapshots().map((snap) => snap.docs
        .map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id})
        .toList());
  }

  static Future<void> addKatalog(Map<String, dynamic> data) async {
    await _katalogRef.add(data);
  }

  /// Stream staff
  static Stream<List<Map<String, dynamic>>> streamStaffRaw() {
    return _staffRef.snapshots().map((snap) => snap.docs
        .map((d) => {...(d.data() as Map<String, dynamic>), 'id': d.id})
        .toList());
  }

  static Future<void> addStaff(Map<String, dynamic> data) async {
    await _staffRef.add(data);
  }
}
