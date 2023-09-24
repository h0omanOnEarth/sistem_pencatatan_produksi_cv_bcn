class DetailItemReceive {
  String id;
  String itemReceiveId;
  int jumlahDus;
  int jumlahPcs;
  String productId;
  int status;

  DetailItemReceive({
    required this.id,
    required this.itemReceiveId,
    required this.jumlahDus,
    required this.jumlahPcs,
    required this.productId,
    required this.status,
  });

  factory DetailItemReceive.fromJson(Map<String, dynamic> json) {
    return DetailItemReceive(
      id: json['id'] ?? '',
      itemReceiveId: json['item_receive_id'] ?? '',
      jumlahDus: json['jumlah_dus'] ?? 0,
      jumlahPcs: json['jumlah_pcs'] ?? 0,
      productId: json['product_id'] ?? '',
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'item_receive_id': itemReceiveId,
      'jumlah_dus': jumlahDus,
      'jumlah_pcs': jumlahPcs,
      'product_id': productId,
      'status': status,
    };
  }
}
