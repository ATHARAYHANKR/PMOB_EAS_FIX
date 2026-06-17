class BookingModel {
  final String id;
  final String customerId;
  final String katalogId;
  final String katalogNama;
  final int harga;
  final String satuan;
  final String alamat;
  final DateTime tanggalJemput;
  final DateTime tanggalSelesai;
  final String sesiJemput;
  final String catatan;
  final String status;
  final DateTime createdAt;

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
    this.status = 'pending',
    required this.createdAt,
  });

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
