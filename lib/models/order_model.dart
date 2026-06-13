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
        return 'Berhasil Konfirmasi';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.diproses:
        return 'Dicuci';
      case OrderStatus.perluTimbang:
        return 'Disetrika';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Pembayaran';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
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
        return 'Diproses';
      case OrderStatus.perluTimbang:
        return 'Perlu Timbang';
      case OrderStatus.selesai:
        return 'Selesai';
      case OrderStatus.konfirmasiBayar:
        return 'Konfirmasi Bayar';
      case OrderStatus.konfirmasi:
        return 'Konfirmasi';
      case OrderStatus.dijemput:
        return 'Dijemput';
      case OrderStatus.dibatalkan:
        return 'Dibatalkan';
    }
  }

  static const List<OrderStatus> workflowStatuses = [
    OrderStatus.masuk,
    OrderStatus.konfirmasi,
    OrderStatus.dijemput,
    OrderStatus.diproses,
    OrderStatus.perluTimbang,
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
}
