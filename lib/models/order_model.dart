import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  masuk,
  dijemput,
  perluTimbang,
  konfirmasiBayar,
  dicuci,
  disetrika,
  dikirim,
  selesai,
  dibatalkan,
}

extension OrderStatusX on OrderStatus {
  OrderStatus get normalized {
    return this;
  }

  String get stepTitle {
    switch (normalized) {
      case OrderStatus.masuk:
        return 'Menunggu Konfirmasi';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.perluTimbang:
        return 'Timbang';
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

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.masuk:
      return 'masuk';
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

OrderStatus orderStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'diproses':
    case 'diambil':
    case 'dijemput':
      return OrderStatus.dijemput;
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
    // Legacy values that mapped to old konfirmasi status
    case 'konfirmasi':
    case 'dicuci & disetrika':
    case 'lunas':
      // Map legacy values to dicuci (start of washing process)
      return OrderStatus.dicuci;
    default:
      return OrderStatus.masuk;
  }
}

class StatusStep {
  final String title;
  final String? date;
  final bool done;
  StatusStep({required this.title, this.date, this.done = false});
}

class OrderModel {
  final String id;
  final String customerName;
  final String phone;
  final String serviceType;
  final DateTime pickupDate;
  final String pickupSlot;
  final DateTime createdAt;
  OrderStatus status;
  double? beratKg;
  double? totalHarga;
  bool isPaid;
  String address;
  String catatan;
  List<StatusStep> steps;
  DateTime? paymentConfirmedAt;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.serviceType,
    required this.pickupDate,
    required this.pickupSlot,
    this.status = OrderStatus.masuk,
    this.beratKg,
    this.totalHarga,
    this.isPaid = false,
    this.address = 'Jl. Mawar No. 105',
    this.catatan = '-',
    this.steps = const [],
    this.paymentConfirmedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  OrderModel._internal({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.serviceType,
    required this.pickupDate,
    required this.pickupSlot,
    this.status = OrderStatus.masuk,
    this.beratKg,
    this.totalHarga,
    this.isPaid = false,
    this.address = 'Jl. Mawar No. 105',
    this.catatan = '-',
    this.steps = const [],
    this.paymentConfirmedAt,
    required this.createdAt,
  });

  OrderModel copyWith({String? id, DateTime? createdAt}) {
    return OrderModel._internal(
      id: id ?? this.id,
      customerName: customerName,
      phone: phone,
      serviceType: serviceType,
      pickupDate: pickupDate,
      pickupSlot: pickupSlot,
      status: status,
      beratKg: beratKg,
      totalHarga: totalHarga,
      isPaid: isPaid,
      address: address,
      catatan: catatan,
      steps: steps,
      paymentConfirmedAt: paymentConfirmedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.masuk:
        return 'Order Masuk';
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

  static const List<OrderStatus> workflowStatuses = [
    OrderStatus.masuk,
    OrderStatus.dijemput,
    OrderStatus.perluTimbang,
    OrderStatus.konfirmasiBayar,
    OrderStatus.dicuci,
    OrderStatus.disetrika,
    OrderStatus.dikirim,
    OrderStatus.selesai,
  ];

  int get workflowIndex => workflowStatuses.indexOf(status.normalized);

  double get workflowProgress {
    final index = workflowIndex;
    if (index < 0) return 0;
    return (index + 1) / workflowStatuses.length;
  }

  OrderStatus? get nextStatus {
    if (status.normalized == OrderStatus.dijemput) {
      return OrderStatus.perluTimbang;
    }
    final index = workflowIndex;
    if (index < 0 || index >= workflowStatuses.length - 1) return null;
    return workflowStatuses[index + 1];
  }

  bool get isFinalized =>
      status == OrderStatus.selesai || status == OrderStatus.dibatalkan;

  List<StatusStep> get statusSteps {
    if (isFinalized) {
      return [StatusStep(title: status.stepTitle, done: true)];
    }
    return workflowStatuses.map((s) {
      final stepIndex = workflowStatuses.indexOf(s);
      return StatusStep(
        title: s.stepTitle,
        done: workflowIndex >= stepIndex,
      );
    }).toList();
  }

  List<StatusStep> get computedSteps => steps.isNotEmpty ? steps : statusSteps;

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'phone': phone,
      'serviceType': serviceType,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'pickupSlot': pickupSlot,
      'status': orderStatusToString(status),
      if (beratKg != null) 'beratKg': beratKg,
      if (totalHarga != null) 'totalHarga': totalHarga,
      'isPaid': isPaid,
      'address': address,
      'catatan': catatan,
      'createdAt': Timestamp.fromDate(createdAt),
      if (paymentConfirmedAt != null)
        'paymentConfirmedAt': Timestamp.fromDate(paymentConfirmedAt!),
      if (steps.isNotEmpty)
        'steps': steps
            .map((step) => {
                  'title': step.title,
                  'date': step.date,
                  'done': step.done,
                })
            .toList(),
    };
  }

  static OrderModel fromMap(String id, Map<String, dynamic> map) {
    DateTime pickupDate = DateTime.now();
    final rawDate = map['pickupDate'];
    if (rawDate is Timestamp) {
      pickupDate = rawDate.toDate();
    } else if (rawDate is String) {
      pickupDate = DateTime.tryParse(rawDate) ?? pickupDate;
    } else if (rawDate is int) {
      pickupDate = DateTime.fromMillisecondsSinceEpoch(rawDate);
    }

    double? parseDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString());
    }

    final stepsData = map['steps'];
    final steps = <StatusStep>[];
    if (stepsData is List) {
      for (final item in stepsData) {
        if (item is Map<String, dynamic>) {
          steps.add(StatusStep(
            title: item['title']?.toString() ?? '',
            date: item['date']?.toString(),
            done: item['done'] == true,
          ));
        }
      }
    }

    // parse optional paymentConfirmedAt
    DateTime? parsedPaymentConfirmedAt() {
      final raw = map['paymentConfirmedAt'];
      if (raw == null) return null;
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw);
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw);
      return null;
    }

    return OrderModel(
      id: id,
      customerName: map['customerName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      serviceType: map['serviceType']?.toString() ?? '',
      pickupDate: pickupDate,
      pickupSlot: map['pickupSlot']?.toString() ?? '',
      status: orderStatusFromString(map['status']?.toString()),
      beratKg: parseDouble(map['beratKg']),
      totalHarga: parseDouble(map['totalHarga']),
      isPaid: map['isPaid'] == true,
      address: map['address']?.toString() ?? '',
      catatan: map['catatan']?.toString() ?? '-',
      steps: steps,
      paymentConfirmedAt: parsedPaymentConfirmedAt(),
      createdAt: () {
        final rawCreated = map['createdAt'];
        if (rawCreated is Timestamp) {
          return rawCreated.toDate();
        } else if (rawCreated is String) {
          return DateTime.tryParse(rawCreated) ?? DateTime.now();
        } else if (rawCreated is int) {
          return DateTime.fromMillisecondsSinceEpoch(rawCreated);
        }
        return DateTime.now();
      }(),
    );
  }
}
