enum OrderStatus { masuk, diproses, perluTimbang, selesai, konfirmasiBayar }

class OrderModel {
  final String id;
  final String customerName;
  final String phone;
  final String serviceType;
  final DateTime pickupDate;
  final String pickupSlot;
  OrderStatus status;
  double? beratKg;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.serviceType,
    required this.pickupDate,
    required this.pickupSlot,
    this.status = OrderStatus.masuk,
    this.beratKg,
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
    }
  }
}

// ── Dummy data ────────────────────────────────────────────────
class OrderRepository {
  static final List<OrderModel> _orders = [
    OrderModel(
      id: 'ORD-20260606-001',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Kering',
      pickupDate: DateTime(2026, 6, 5),
      pickupSlot: '08.00 - 10.00 (Pagi)',
      status: OrderStatus.diproses,
    ),
    OrderModel(
      id: 'ORD-20260606-002',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Kering',
      pickupDate: DateTime(2026, 6, 8),
      pickupSlot: '08.00 - 10.00 (Pagi)',
      status: OrderStatus.masuk,
    ),
    OrderModel(
      id: 'ORD-20260606-003',
      customerName: 'Rina',
      phone: '08211234567',
      serviceType: 'Cuci Setrika',
      pickupDate: DateTime(2026, 6, 9),
      pickupSlot: '10.00 - 12.00 (Pagi)',
      status: OrderStatus.perluTimbang,
    ),
    OrderModel(
      id: 'ORD-20260606-004',
      customerName: 'Budi',
      phone: '08567891234',
      serviceType: 'Setrika Saja',
      pickupDate: DateTime(2026, 6, 7),
      pickupSlot: '14.00 - 16.00 (Siang)',
      status: OrderStatus.konfirmasiBayar,
      beratKg: 3.5,
    ),
  ];

  static List<OrderModel> get all => _orders;

  static List<OrderModel> byStatus(OrderStatus s) =>
      _orders.where((o) => o.status == s).toList();

  static int countByStatus(OrderStatus s) => byStatus(s).length;
}
