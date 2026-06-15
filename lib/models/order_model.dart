import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus {
  masuk,
  diproses,
  perluTimbang,
  selesai,
  konfirmasiBayar,
  konfirmasi,
  dijemput,
  dibatalkan,
}

extension OrderStatusX on OrderStatus {
  String get stepTitle {
    switch (this) {
      case OrderStatus.masuk:
        return 'Menunggu Konfirmasi';
      case OrderStatus.konfirmasi:

        return 'Dicuci & Disetrika';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.diproses:
        return 'Diambil';
      case OrderStatus.perluTimbang:
        return 'Timbang';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Pembayaran';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  String get statusLabel {
    switch (this) {
      case OrderStatus.masuk:
        return 'Order Masuk';
      case OrderStatus.diproses:
        return 'Diambil';
      case OrderStatus.perluTimbang:
        return 'Perlu Timbang';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Bayar';
      case OrderStatus.konfirmasi:
        return 'Dicuci & Disetrika';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }
}

String orderStatusToString(OrderStatus status) {
  switch (status) {
    case OrderStatus.masuk:
      return 'masuk';
    case OrderStatus.diproses:
      return 'diproses';
    case OrderStatus.perluTimbang:
      return 'perluTimbang';
    case OrderStatus.selesai:
      return 'selesai';
    case OrderStatus.konfirmasiBayar:
      return 'konfirmasiBayar';
    case OrderStatus.konfirmasi:
      return 'konfirmasi';
    case OrderStatus.dijemput:
      return 'dijemput';
    case OrderStatus.dibatalkan:
      return 'dibatalkan';
  }
}

OrderStatus orderStatusFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'diproses':
    case 'diambil':
      return OrderStatus.diproses;
    case 'perlu timbang':
    case 'perlu_timbang':
    case 'perluTimbang':
      return OrderStatus.perluTimbang;
    case 'selesai':
      return OrderStatus.selesai;
    case 'konfirmasi bayar':
    case 'konfirmasibayar':
    case 'konfirmasiBayar':
      return OrderStatus.konfirmasiBayar;
    case 'konfirmasi':
    case 'dicuci & disetrika':
    case 'dicuci':
    case 'disetrika':
      return OrderStatus.konfirmasi;
    case 'dijemput':
      return OrderStatus.dijemput;
    case 'dibatalkan':
      return OrderStatus.dibatalkan;
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
  OrderStatus status;
  double? beratKg;
  double? totalHarga;
  String address;
  String catatan;
  List<StatusStep> steps;

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
    this.address = 'Jl. Mawar No. 105',
    this.catatan = '-',
    this.steps = const [],
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.masuk:
        return 'Order Masuk';
      case OrderStatus.diproses:
        return 'Diambil';
      case OrderStatus.perluTimbang:
        return 'Perlu Timbang';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Bayar';
      case OrderStatus.konfirmasi:
        return 'Dicuci & Disetrika';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  static const List<OrderStatus> workflowStatuses = [
    OrderStatus.masuk,
    OrderStatus.diproses,
    OrderStatus.perluTimbang,
    OrderStatus.konfirmasi,
    OrderStatus.konfirmasiBayar,
    OrderStatus.selesai,
  ];

  int get workflowIndex => workflowStatuses.indexOf(status);

  double get workflowProgress {
    final index = workflowIndex;
    if (index < 0) return 0;
    return (index + 1) / workflowStatuses.length;
  }

  OrderStatus? get nextStatus {
    if (status == OrderStatus.dijemput) {
      return OrderStatus.diproses;
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
      'address': address,
      'catatan': catatan,
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
      address: map['address']?.toString() ?? '',
      catatan: map['catatan']?.toString() ?? '-',
      steps: steps,
    );
  }
}
