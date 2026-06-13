import '../models/order_model.dart';

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

  static final List<OrderModel> _riwayat = [
    OrderModel(
      id: 'ORD-20260611-003',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Kering',
      pickupDate: DateTime(2026, 6, 11),
      pickupSlot: '08.00-10.00',
      status: OrderStatus.konfirmasi,
      steps: [
        StatusStep(
            title: 'Menunggu Konfirmasi', date: '10 Juni 2026', done: true),
        StatusStep(title: 'Dijemput'),
        StatusStep(title: 'Konfirmasi Pembayaran'),
        StatusStep(title: 'Dicuci'),
        StatusStep(title: 'Disetrika'),
        StatusStep(title: 'Dikirim'),
        StatusStep(title: 'Selesai'),
      ],
    ),
    OrderModel(
      id: 'ORD-20260611-001',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Kering',
      pickupDate: DateTime(2026, 6, 11),
      pickupSlot: '08.00-10.00',
      status: OrderStatus.dijemput,
      steps: [
        StatusStep(
            title: 'Berhasil Konfirmasi',
            date: '10 Juni 2026, 16.03',
            done: true),
        StatusStep(title: 'Dijemput', done: true),
        StatusStep(title: 'Konfirmasi Pembayaran'),
        StatusStep(title: 'Dicuci'),
        StatusStep(title: 'Disetrika'),
        StatusStep(title: 'Dikirim'),
        StatusStep(title: 'Selesai'),
      ],
    ),
    OrderModel(
      id: 'ORD-20260606-001',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Kering',
      beratKg: 5,
      totalHarga: 35000,
      pickupDate: DateTime(2026, 6, 6),
      pickupSlot: '08.00-10.00',
      status: OrderStatus.diproses,
      steps: [
        StatusStep(
            title: 'Berhasil Konfirmasi',
            date: '5 Juni 2026, 20.40',
            done: true),
        StatusStep(title: 'Dijemput', date: '6 Juni 2026, 08.20', done: true),
        StatusStep(
            title: 'Konfirmasi Pembayaran',
            date: '6 Juni 2026, 10.10',
            done: true),
        StatusStep(title: 'Dicuci', date: '6 Juni 2026, 11.10', done: true),
        StatusStep(title: 'Disetrika'),
        StatusStep(title: 'Dikirim'),
        StatusStep(title: 'Selesai'),
      ],
    ),
    OrderModel(
      id: 'ORD-20260604-002',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Setrika',
      pickupDate: DateTime(2026, 6, 4),
      pickupSlot: '08.00-10.00',
      status: OrderStatus.dibatalkan,
    ),
    OrderModel(
      id: 'ORD-20260604-001',
      customerName: 'Dhira',
      phone: '08132323232',
      serviceType: 'Cuci Setrika',
      beratKg: 3,
      totalHarga: 35000,
      pickupDate: DateTime(2026, 6, 4),
      pickupSlot: '08.00-10.00',
      status: OrderStatus.selesai,
    ),
  ];

  static List<OrderModel> get all => _orders;

  static List<OrderModel> get riwayat => _riwayat;

  static List<OrderModel> byStatus(OrderStatus s) =>
      _orders.where((o) => o.status == s).toList();

  static int countByStatus(OrderStatus s) => byStatus(s).length;

  static void updateStatus(OrderModel order, OrderStatus status) {
    order.status = status;
  }

  static void cancel(OrderModel order) {
    updateStatus(order, OrderStatus.dibatalkan);
  }

  static void advanceStatus(OrderModel order) {
    final next = order.nextStatus;
    if (next != null) {
      updateStatus(order, next);
    }
  }

  static void updateWeightAndConfirm(OrderModel order, double weightKg) {
    order.beratKg = weightKg;
    updateStatus(order, OrderStatus.konfirmasiBayar);
  }
}
