import 'detail_item_receive.dart'; // Import kelas DetailItemReceive yang telah dibuat sebelumnya
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemReceive {
  String id;
  String productionConfirmationId;
  int status;
  DateTime tanggalPenerimaan;
  String catatan;
  List<DetailItemReceive> detailItemReceiveList;

  ItemReceive({
    required this.id,
    required this.productionConfirmationId,
    required this.status,
    required this.tanggalPenerimaan,
    this.catatan = '',
    this.detailItemReceiveList = const [],
  });

  factory ItemReceive.fromFirestore(DocumentSnapshot document) {
    final data = document.data() as Map<String, dynamic>;
    final List<dynamic> detailItems = data['detail_item_receive_list'] ?? [];
    final List<DetailItemReceive> detailItemReceives = detailItems
        .map((detailItem) => DetailItemReceive.fromJson(detailItem))
        .toList();

    return ItemReceive(
      id: document.id,
      productionConfirmationId: data['production_confirmation_id'] ?? '',
      status: data['status'] ?? 0,
      tanggalPenerimaan: (data['tanggal_penerimaan'] as Timestamp).toDate(),
      catatan: data['catatan'] ?? '',
      detailItemReceiveList: detailItemReceives,
    );
  }

  Map<String, dynamic> toJson() {
    final List<Map<String, dynamic>> detailItemReceiveJsonList =
        detailItemReceiveList.map((detailItem) => detailItem.toJson()).toList();

    return {
      'production_confirmation_id': productionConfirmationId,
      'status': status,
      'tanggal_penerimaan': Timestamp.fromDate(tanggalPenerimaan),
      'catatan': catatan,
      'detail_item_receive_list': detailItemReceiveJsonList,
    };
  }
}
