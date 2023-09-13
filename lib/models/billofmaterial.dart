import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/detail_billofmaterial.dart';

class BillOfMaterial {
  String id;
  String productId;
  int statusBOM;
  DateTime tanggalPembuatan;
  int versiBOM;
  List<BomDetail>? detailBOMList; // List tidak perlu menjadi opsional

  BillOfMaterial({
    required this.id,
    required this.productId,
    required this.statusBOM,
    required this.tanggalPembuatan,
    required this.versiBOM,
    this.detailBOMList = const [], // Initialize the list
  });

  factory BillOfMaterial.fromJson(Map<String, dynamic> json) {
    return BillOfMaterial(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      statusBOM: json['status_bom'] as int,
      tanggalPembuatan: DateTime.parse(json['tanggal_pembuatan'] as String),
      versiBOM: json['versi_bom'] as int,
    );
  }

  Future<void> fetchBomDetails() async {
    final bomDetailsQuery = FirebaseFirestore.instance
        .collection('bom_details')
        .where('bom_id', isEqualTo: id);

    final bomDetailsSnapshot = await bomDetailsQuery.get();
    final bomDetailsData = bomDetailsSnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return BomDetail.fromJson(data);
    }).toList();

    detailBOMList = bomDetailsData;
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>>? bomDetailsJson =
        detailBOMList?.map((detail) {
          return detail.toJson();
        }).toList();

    return {
      'id': id,
      'product_id': productId,
      'status_bom': statusBOM,
      'tanggal_pembuatan': tanggalPembuatan,
      'versi_bom': versiBOM,
      'bom_details': bomDetailsJson,
    };
  }
}
