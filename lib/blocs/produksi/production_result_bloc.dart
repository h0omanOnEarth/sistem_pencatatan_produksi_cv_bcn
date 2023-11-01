import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_result.dart';

// Events
abstract class ProductionResultEvent {}

class AddProductionResultEvent extends ProductionResultEvent {
  final ProductionResult productionResult;
  AddProductionResultEvent(this.productionResult);
}

class UpdateProductionResultEvent extends ProductionResultEvent {
  final String productionResultId;
  final ProductionResult updatedProductionResult;
  UpdateProductionResultEvent(
      this.productionResultId, this.updatedProductionResult);
}

class DeleteProductionResultEvent extends ProductionResultEvent {
  final String productionResultId;
  DeleteProductionResultEvent(this.productionResultId);
}

// States
abstract class ProductionResultBlocState {}

class LoadingState extends ProductionResultBlocState {}

class SuccessState extends ProductionResultBlocState {}

class LoadedState extends ProductionResultBlocState {
  final List<ProductionResult> productionResultList;
  LoadedState(this.productionResultList);
}

class ErrorState extends ProductionResultBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class ProductionResultBloc
    extends Bloc<ProductionResultEvent, ProductionResultBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference productionResultRef;
  final HttpsCallable resultValidateCallable;

  ProductionResultBloc()
      : resultValidateCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('productionResValidate'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    productionResultRef = _firestore.collection('production_results');
  }

  @override
  Stream<ProductionResultBlocState> mapEventToState(
      ProductionResultEvent event) async* {
    if (event is AddProductionResultEvent) {
      yield LoadingState();

      final materialUsageId = event.productionResult.materialUsageId;
      final totalProduk = event.productionResult.totalProduk;
      final jumlahProdukBerhasil = event.productionResult.jumlahProdukBerhasil;
      final jumlahProdukCacat = event.productionResult.jumlahProdukCacat;
      final satuan = event.productionResult.satuan;
      final catatan = event.productionResult.catatan;
      final statusPRS = event.productionResult.statusPRS;
      final status = event.productionResult.status;
      final tanggalPencatatan = event.productionResult.tanggalPencatatan;
      final waktuProduksi = event.productionResult.waktuProduksi;

      if (materialUsageId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await resultValidateCallable.call(<String, dynamic>{
            'total': totalProduk,
            'jumlahBerhasil': jumlahProdukBerhasil,
            'jumlahCacat': jumlahProdukCacat,
            'waktu': waktuProduksi,
            'materialUsageId': materialUsageId,
            'satuan': satuan,
            'mode': 'add'
          });

          if (result.data['success'] == true) {
            final String nextProductionResultId =
                await _generateNextProductionResultId();
            final productionResultRef = _firestore
                .collection('production_results')
                .doc(nextProductionResultId);

            // Buat Map data Production Result
            final Map<String, dynamic> productionResultData = {
              'id': nextProductionResultId,
              'material_usage_id': materialUsageId,
              'total_produk': totalProduk,
              'jumlah_produk_berhasil': jumlahProdukBerhasil,
              'jumlah_produk_cacat': jumlahProdukCacat,
              'satuan': satuan,
              'catatan': catatan,
              'status_prs': statusPRS,
              'status': status,
              'tanggal_pencatatan': tanggalPencatatan,
              'waktu_produksi': waktuProduksi,
            };

            // Tambahkan data Production Result ke Firestore
            await productionResultRef.set(productionResultData);
            yield SuccessState();
          } else {
            yield ErrorState(result.data['message']);
          }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      } else {
        yield ErrorState("nomor penggunaan bahan tidak boleh kosong");
      }
    } else if (event is UpdateProductionResultEvent) {
      yield LoadingState();

      final materialUsageId = event.updatedProductionResult.materialUsageId;
      final totalProduk = event.updatedProductionResult.totalProduk;
      final jumlahProdukBerhasil =
          event.updatedProductionResult.jumlahProdukBerhasil;
      final jumlahProdukCacat = event.updatedProductionResult.jumlahProdukCacat;
      final satuan = event.updatedProductionResult.satuan;
      final catatan = event.updatedProductionResult.catatan;
      final statusPRS = event.updatedProductionResult.statusPRS;
      final status = event.updatedProductionResult.status;
      final tanggalPencatatan = event.updatedProductionResult.tanggalPencatatan;
      final waktuProduksi = event.updatedProductionResult.waktuProduksi;

      if (materialUsageId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await resultValidateCallable.call(<String, dynamic>{
            'total': totalProduk,
            'jumlahBerhasil': jumlahProdukBerhasil,
            'jumlahCacat': jumlahProdukCacat,
            'waktu': waktuProduksi,
            'materialUsageId': materialUsageId,
            'satuan': satuan,
            'mode': 'edit'
          });

          if (result.data['success'] == true) {
            final productionResultSnapshot = await productionResultRef
                .where('id', isEqualTo: event.productionResultId)
                .get();
            if (productionResultSnapshot.docs.isNotEmpty) {
              final productionResultDoc = productionResultSnapshot.docs.first;
              await productionResultDoc.reference.update({
                'material_usage_id': materialUsageId,
                'total_produk': totalProduk,
                'jumlah_produk_berhasil': jumlahProdukBerhasil,
                'jumlah_produk_cacat': jumlahProdukCacat,
                'satuan': satuan,
                'catatan': catatan,
                'status_prs': statusPRS,
                'status': status,
                'tanggal_pencatatan': tanggalPencatatan,
                'waktu_produksi': waktuProduksi,
              });
              yield SuccessState();
            } else {
              yield ErrorState(
                  'Data Hasil Produksi dengan ID ${event.productionResultId} tidak ditemukan.');
            }
          } else {
            yield ErrorState(result.data['message']);
          }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      } else {
        yield ErrorState("nomor penggunaan bahan tidak boleh kosong");
      }
    } else if (event is DeleteProductionResultEvent) {
      yield LoadingState();
      try {
        final QuerySnapshot querySnapshot = await productionResultRef
            .where('id', isEqualTo: event.productionResultId)
            .get();

        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          // Ubah status produksi_orders menjadi "Dalam Proses"
          final materialUsageId =
              documentSnapshot['material_usage_id'] as String;
          final productionOrderId =
              await getProductionOrderIdFromMaterialUsageId(materialUsageId);
          if (productionOrderId != null) {
            await updateProductionOrderStatus(
                productionOrderId, 'Dalam Proses');
          }

          final jumlahProdukCacat =
              documentSnapshot['jumlah_produk_cacat'] as int;
          await decreaseProductStock('productXXX', jumlahProdukCacat);

          // Ubah status menjadi 0 pada semua dokumen yang sesuai dengan pencarian
          await documentSnapshot.reference.update({'status': 0});
        }

        yield SuccessState();
      } catch (e) {
        yield ErrorState(e.toString());
      }
    }
  }

  Future<String?> getProductionOrderIdFromMaterialUsageId(
      String materialUsageId) async {
    try {
      final materialUsageQuery = await _firestore
          .collection('material_usages')
          .doc(materialUsageId)
          .get();

      if (materialUsageQuery.exists) {
        return materialUsageQuery['production_order_id'] as String?;
      }
    } catch (e) {
      print('Error getting production order ID from material usage: $e');
    }
    return null;
  }

  Future<void> updateProductionOrderStatus(
      String productionOrderId, String newStatus) async {
    try {
      final productionOrderDoc = await _firestore
          .collection('production_orders')
          .doc(productionOrderId)
          .get();
      if (productionOrderDoc.exists) {
        await productionOrderDoc.reference.update({'status_pro': newStatus});
      }
    } catch (e) {
      print('Error updating production order status: $e');
    }
  }

  Future<void> decreaseProductStock(String productId, int amount) async {
    try {
      final productQuery = await _firestore
          .collection('products')
          .where('id', isEqualTo: productId)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;
        final currentStock = productDoc['stok'] as int;
        final newStock = currentStock - amount;
        await productDoc.reference.update({'stok': newStock});
      }
    } catch (e) {
      print('Error decreasing product stock: $e');
    }
  }

  Future<String> _generateNextProductionResultId() async {
    final QuerySnapshot snapshot = await productionResultRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int productionResultCount = 1;

    while (true) {
      final nextProductionResultId =
          'PRS${productionResultCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextProductionResultId)) {
        return nextProductionResultId;
      }
      productionResultCount++;
    }
  }

  // Future<List<ProductionResult>> _getProductionResultList() async {
  //   final QuerySnapshot snapshot = await productionResultRef.get();
  //   final List<ProductionResult> productionResultList = [];
  //   for (final doc in snapshot.docs) {
  //     final data = doc.data() as Map<String, dynamic>;
  //     productionResultList.add(ProductionResult.fromJson(data));
  //   }
  //   return productionResultList;
  // }
}
