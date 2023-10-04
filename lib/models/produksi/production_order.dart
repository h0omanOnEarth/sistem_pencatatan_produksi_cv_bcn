import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_mesin_production_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_production_order.dart';

class ProductionOrder {
  String id;
  String bomId;
  int jumlahProduksiEst;
  int jumlahTenagaKerjaEst;
  int lamaWaktuEst;
  String productId;
  int status;
  String statusPro;
  DateTime tanggalProduksi;
  DateTime tanggalRencana;
  DateTime tanggalSelesai;
  String catatan;
  List<DetailProductionOrder>? detailProductionOrderList; // List tidak perlu menjadi opsional,
  List<MachineDetail>? detailMesinProductionOrderList;

  ProductionOrder({
    required this.id,
    required this.bomId,
    required this.jumlahProduksiEst,
    required this.jumlahTenagaKerjaEst,
    required this.lamaWaktuEst,
    required this.productId,
    required this.status,
    required this.statusPro,
    required this.tanggalProduksi,
    required this.tanggalRencana,
    required this.tanggalSelesai,
    required this.catatan,
    this.detailProductionOrderList = const [], // Initialize the list
    this.detailMesinProductionOrderList = const[]
  });

  factory ProductionOrder.fromJson(Map<String, dynamic> json) {
    return ProductionOrder(
      id: json['id'] as String,
      bomId: json['bom_id'] as String,
      jumlahProduksiEst: json['jumlah_produksi_est'] as int,
      jumlahTenagaKerjaEst: json['jumlah_tenaga_kerja_est'] as int,
      lamaWaktuEst: json['lama_waktu_est'] as int,
      productId: json['product_id'] as String,
      status: json['status'] as int,
      statusPro: json['status_pro'] as String,
      catatan: json['catatan'] as String,
      tanggalProduksi: DateTime.parse(json['tanggal_produksi'] as String),
      tanggalRencana: DateTime.parse(json['tanggal_rencana'] as String),
      tanggalSelesai: DateTime.parse(json['tanggal_selesai'] as String),
    );
  }

    Future<void> fetchDetaiProductionOrders() async {
    final detailProductionOrdersQuery = FirebaseFirestore.instance
        .collection('detail_production_orders')
        .where('production_order_id', isEqualTo: id);

    final detailProductionOrdersSnapshot = await detailProductionOrdersQuery.get();
    final detailProductionOrdersData = detailProductionOrdersSnapshot.docs.map((doc) {
      final data = doc.data();
      return DetailProductionOrder.fromJson(data);
    }).toList();

    detailProductionOrderList = detailProductionOrdersData;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bom_id': bomId,
      'jumlah_produksi_est': jumlahProduksiEst,
      'jumlah_tenaga_kerja_est': jumlahTenagaKerjaEst,
      'lama_waktu_est': lamaWaktuEst,
      'product_id': productId,
      'status': status,
      'status_pro': statusPro,
      'catatan': catatan,
      'tanggal_produksi': tanggalProduksi.toIso8601String(),
      'tanggal_rencana': tanggalRencana.toIso8601String(),
      'tanggal_selesai': tanggalSelesai.toIso8601String(),
      'detail_production_order': detailProductionOrderList,
    };
  }
}
