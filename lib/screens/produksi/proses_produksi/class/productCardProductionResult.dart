class ProductCardDataProductionResult {
  String nomorHasilProduksi;
  String kodeBarang;
  String namaBarang;
  String jumlahHasil;
  String satuan;
  String jumlahKonfirmasi;
  String selectedDropdownValue = '';

  ProductCardDataProductionResult({
    required this.nomorHasilProduksi,
    required this.kodeBarang,
    required this.namaBarang,
    required this.jumlahHasil,
    required this.satuan,
    required this.jumlahKonfirmasi,
    this.selectedDropdownValue = '',
  });
}