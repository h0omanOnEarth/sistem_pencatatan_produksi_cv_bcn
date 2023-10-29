import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerOrderReturnService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>?> getDetailCustOrderReturn(
      String custOrderReturnId) async {
    try {
      final detailCorQuery = await firestore
          .collection('customer_order_returns')
          .doc(custOrderReturnId)
          .collection('detail_customer_order_returns')
          .get();

      if (detailCorQuery.docs.isNotEmpty) {
        final List<Map<String, dynamic>> detailCustOrderReturns = [];

        for (final doc in detailCorQuery.docs) {
          final detailCustOrderReturnData = doc.data();

          // Pastikan data yang dibutuhkan tersedia sebelum menambahkannya
          if (detailCustOrderReturnData['jumlah_pengembalian'] != null &&
              detailCustOrderReturnData['jumlah_pesanan'] != null) {
            detailCustOrderReturns.add({
              'id': doc.id,
              'product_id': detailCustOrderReturnData['product_id'],
              'jumlahPengembalian':
                  detailCustOrderReturnData['jumlah_pengembalian'] as int,
              'jumlahPesanan':
                  detailCustOrderReturnData['jumlah_pesanan'] as int,
            });
          }
        }

        return detailCustOrderReturns;
      } else {
        return null; // Kembalikan null jika dokumen detail_shipments tidak ditemukan
      }
    } catch (e) {
      print('Error getting customer order return info: $e');
      return null; // Kembalikan null jika terjadi kesalahan
    }
  }
}
