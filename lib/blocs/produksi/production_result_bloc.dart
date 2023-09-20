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
  UpdateProductionResultEvent(this.productionResultId, this.updatedProductionResult);
}

class DeleteProductionResultEvent extends ProductionResultEvent {
  final String productionResultId;
  DeleteProductionResultEvent(this.productionResultId);
}

// States
abstract class ProductionResultBlocState {}

class LoadingState extends ProductionResultBlocState {}

class LoadedState extends ProductionResultBlocState {
  final List<ProductionResult> productionResultList;
  LoadedState(this.productionResultList);
}

class ErrorState extends ProductionResultBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class ProductionResultBloc extends Bloc<ProductionResultEvent, ProductionResultBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference productionResultRef;

  ProductionResultBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    productionResultRef = _firestore.collection('production_results');
  }

  @override
  Stream<ProductionResultBlocState> mapEventToState(ProductionResultEvent event) async* {
    if (event is AddProductionResultEvent) {
      yield LoadingState();
      try {
        final String nextProductionResultId = await _generateNextProductionResultId();
        final productionResultRef = _firestore.collection('production_results').doc(nextProductionResultId);

        // Buat Map data Production Result
        final Map<String, dynamic> productionResultData = {
          'id': nextProductionResultId,
          'material_usage_id': event.productionResult.materialUsageId,
          'total_produk': event.productionResult.totalProduk,
          'jumlah_produk_berhasil': event.productionResult.jumlahProdukBerhasil,
          'jumlah_produk_cacat': event.productionResult.jumlahProdukCacat,
          'satuan': event.productionResult.satuan,
          'catatan': event.productionResult.catatan,
          'status_prs': event.productionResult.statusPRS,
          'status': event.productionResult.status,
          'tanggal_pencatatan': event.productionResult.tanggalPencatatan,
          'waktu_produksi': event.productionResult.waktuProduksi,
        };

        // Tambahkan data Production Result ke Firestore
        await productionResultRef.set(productionResultData);

        final productionResultList = await _getProductionResultList();
        yield LoadedState(productionResultList);
      } catch (e) {
        yield ErrorState("Gagal menambahkan Hasil Produksi.");
      }
    } else if (event is UpdateProductionResultEvent) {
      yield LoadingState();
      try {
        final productionResultSnapshot = await productionResultRef.where('id', isEqualTo: event.productionResultId).get();
        if (productionResultSnapshot.docs.isNotEmpty) {
          final productionResultDoc = productionResultSnapshot.docs.first;
          await productionResultDoc.reference.update({
            'material_usage_id': event.updatedProductionResult.materialUsageId,
            'total_produk': event.updatedProductionResult.totalProduk,
            'jumlah_produk_berhasil': event.updatedProductionResult.jumlahProdukBerhasil,
            'jumlah_produk_cacat': event.updatedProductionResult.jumlahProdukCacat,
            'satuan': event.updatedProductionResult.satuan,
            'catatan': event.updatedProductionResult.catatan,
            'status_prs': event.updatedProductionResult.statusPRS,
            'status': event.updatedProductionResult.status,
            'tanggal_pencatatan': event.updatedProductionResult.tanggalPencatatan,
            'waktu_produksi': event.updatedProductionResult.waktuProduksi,
          });
          final productionResultList = await _getProductionResultList();
          yield LoadedState(productionResultList);
        } else {
          yield ErrorState('Data Hasil Produksi dengan ID ${event.productionResultId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah Hasil Produksi.");
      }
    } else if (event is DeleteProductionResultEvent) {
      yield LoadingState();
      try {
        // Cari dokumen dengan 'id' yang sesuai dengan event.productionResultId
        final QuerySnapshot querySnapshot = await productionResultRef.where('id', isEqualTo: event.productionResultId).get();
          
        // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        final productionResultList = await _getProductionResultList();
        yield LoadedState(productionResultList);
      } catch (e) {
        yield ErrorState("Gagal menghapus Hasil Produksi.");
      }
    }
  }

  Future<String> _generateNextProductionResultId() async {
    final QuerySnapshot snapshot = await productionResultRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int productionResultCount = 1;

    while (true) {
      final nextProductionResultId = 'PRS${productionResultCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextProductionResultId)) {
        return nextProductionResultId;
      }
      productionResultCount++;
    }
  }

  Future<List<ProductionResult>> _getProductionResultList() async {
    final QuerySnapshot snapshot = await productionResultRef.get();
    final List<ProductionResult> productionResultList = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      productionResultList.add(ProductionResult.fromJson(data));
    }
    return productionResultList;
  }
}
