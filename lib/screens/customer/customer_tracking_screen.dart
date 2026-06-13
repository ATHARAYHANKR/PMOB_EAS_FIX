import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

class CustomerTrackingScreen extends StatelessWidget {
  const CustomerTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activeOrder = OrderRepository.all.firstWhere(
      (o) => o.status != OrderStatus.selesai,
      orElse: () => OrderRepository.all.first,
    );

    final steps = _stepsFor(activeOrder.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tracking Laundry',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  )),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activeOrder.id,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        )),
                    Text(activeOrder.serviceType,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.black45,
                        )),
                    const SizedBox(height: 16),
                    ...List.generate(steps.length, (i) {
                      final step = steps[i];
                      final isLast = i == steps.length - 1;
                      return _buildStepRow(step, isLast);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(_TrackingStep step, bool isLast) {
    final color = step.done ? const Color(0xFF2E7D32) : Colors.black26;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: step.done ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                alignment: Alignment.center,
                child: step.done
                    ? const Icon(Icons.check_rounded,
                        size: 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: color.withAlpha(step.done ? 255 : 60),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: step.done ? Colors.black87 : Colors.black45,
                      )),
                  const SizedBox(height: 2),
                  Text(step.subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black45,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TrackingStep> _stepsFor(OrderStatus status) {
    const order = [
      OrderStatus.masuk,
      OrderStatus.diproses,
      OrderStatus.perluTimbang,
      OrderStatus.konfirmasiBayar,
      OrderStatus.selesai,
    ];
    final currentIndex = order.indexOf(status);

    final all = [
      _TrackingStep(
          title: 'Order Diterima',
          subtitle: 'Order kamu telah diterima oleh CleanGo'),
      _TrackingStep(
          title: 'Dijemput & Diproses',
          subtitle: 'Laundry sedang dicuci dan diproses'),
      _TrackingStep(
          title: 'Penimbangan',
          subtitle: 'Laundry sedang ditimbang & disetrika'),
      _TrackingStep(
          title: 'Konfirmasi Pembayaran',
          subtitle: 'Menunggu konfirmasi pembayaran'),
      _TrackingStep(
          title: 'Selesai & Dikirim',
          subtitle: 'Laundry telah selesai dan siap diambil'),
    ];

    for (int i = 0; i < all.length; i++) {
      all[i].done = i <= currentIndex;
    }
    return all;
  }
}

class _TrackingStep {
  final String title;
  final String subtitle;
  bool done;
  _TrackingStep({
    required this.title,
    required this.subtitle,
  }) : done = false;
}
