class KatalogModel {
  final String id;
  final String nama;
  final String satuan;
  final int harga;
  final String estimasi;
  final String deskripsi;
  final bool aktif;

  KatalogModel({
    required this.id,
    required this.nama,
    required this.satuan,
    required this.harga,
    required this.estimasi,
    required this.deskripsi,
    this.aktif = true,
  });

  factory KatalogModel.fromMap(String id, Map<String, dynamic> map) {
    return KatalogModel(
      id: id,
      nama: map['nama']?.toString() ?? 'Unknown',
      satuan: map['satuan']?.toString() ?? 'Kg',
      harga: int.tryParse(map['harga']?.toString() ?? '') ?? 0,
      estimasi: map['estimasi']?.toString() ?? '-',
      deskripsi: map['deskripsi']?.toString() ?? '-',
      aktif: map['aktif'] == true ||
          map['aktif']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'satuan': satuan,
      'harga': harga,
      'estimasi': estimasi,
      'deskripsi': deskripsi,
      'aktif': aktif,
    };
  }
}
