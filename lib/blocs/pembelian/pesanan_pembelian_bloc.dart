import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_order.dart';
// Events
abstract class PurchaseOrderEvent {}

class AddPurchaseOrderEvent extends PurchaseOrderEvent {
  final PurchaseOrder purchaseOrder;
  AddPurchaseOrderEvent(this.purchaseOrder);
}

class UpdatePurchaseOrderEvent extends PurchaseOrderEvent {
  final String purchaseOrderId;
  final PurchaseOrder updatedPurchaseOrder;
  UpdatePurchaseOrderEvent(this.purchaseOrderId, this.updatedPurchaseOrder);
}

class DeletePurchaseOrderEvent extends PurchaseOrderEvent {
  final String purchaseOrderId;
  DeletePurchaseOrderEvent(this.purchaseOrderId);
}

// States
abstract class PurchaseOrderBlocState {}

class LoadingState extends PurchaseOrderBlocState {}

class SuccessState extends PurchaseOrderBlocState {}

class LoadedState extends PurchaseOrderBlocState {
  final List<PurchaseOrder> purchaseOrders;
  LoadedState(this.purchaseOrders);
}

class ErrorState extends PurchaseOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class PurchaseOrderBloc extends Bloc<PurchaseOrderEvent, PurchaseOrderBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference purchaseOrdersRef;
  final HttpsCallable purchaseOrderCallable;

  PurchaseOrderBloc() : purchaseOrderCallable = FirebaseFunctions.instance.httpsCallable('purchaseOrderValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    purchaseOrdersRef = _firestore.collection('purchase_orders');
  }

  @override
  Stream<PurchaseOrderBlocState> mapEventToState(PurchaseOrderEvent event) async* {
    if (event is AddPurchaseOrderEvent) {
      yield LoadingState();

      final hargaSatuan = event.purchaseOrder.hargaSatuan;
      final jumlah = event.purchaseOrder.jumlah;
      final keterangan = event.purchaseOrder.keterangan;
      final materialId = event.purchaseOrder.materialId;
      final satuan = event.purchaseOrder.satuan;
      final status = event.purchaseOrder.status;
      final statusPembayaran = event.purchaseOrder.statusPembayaran;
      final statusPengiriman = event.purchaseOrder.statusPengiriman;
      final supplierId = event.purchaseOrder.supplierId;
      final tanggalKirim = event.purchaseOrder.tanggalKirim;
      final tanggalPesan = event.purchaseOrder.tanggalPesan;
      final total = event.purchaseOrder.total;

    if(materialId.isNotEmpty){
      if(supplierId.isNotEmpty){
        try {
        
         final HttpsCallableResult<dynamic> result = await purchaseOrderCallable.call(<String, dynamic>{
                'hargaSatuan': hargaSatuan,
                'jumlah': jumlah,
                'total' : total
        });

        if(result.data['success'] == true){
          final String nextPurchaseOrderId = await _generateNextPurchaseOrderId();

          await FirebaseFirestore.instance.collection('purchase_orders').add({
            'id': nextPurchaseOrderId,
            'harga_satuan': hargaSatuan,
            'jumlah': jumlah,
            'keterangan': keterangan,
            'material_id': materialId,
            'satuan': satuan,
            'status': status,
            'status_pembayaran': statusPembayaran,
            'status_pengiriman': statusPengiriman,
            'supplier_id': supplierId,
            'tanggal_kirim': tanggalKirim,
            'tanggal_pesan': tanggalPesan,
            'total': total,
          });

          yield SuccessState();
        }else{
          yield ErrorState(result.data['message']);
        }

      } catch (e) {
        yield ErrorState(e.toString());
      }
      }else{
        yield ErrorState("kode supplier tidak boleh kosong");
      }
    }else{
      yield ErrorState("kode bahan tidak boleh kosong");
    }

    } else if (event is UpdatePurchaseOrderEvent) {
      yield LoadingState();
      
      final purchaseOrderSnapshot = await purchaseOrdersRef.where('id', isEqualTo: event.purchaseOrderId).get();

      if (purchaseOrderSnapshot.docs.isNotEmpty) {

        final hargaSatuan = event.updatedPurchaseOrder.hargaSatuan;
        final jumlah = event.updatedPurchaseOrder.jumlah;
        final keterangan = event.updatedPurchaseOrder.keterangan;
        final materialId = event.updatedPurchaseOrder.materialId;
        final satuan = event.updatedPurchaseOrder.satuan;
        final status = event.updatedPurchaseOrder.status;
        final statusPembayaran = event.updatedPurchaseOrder.statusPembayaran;
        final statusPengiriman = event.updatedPurchaseOrder.statusPengiriman;
        final supplierId = event.updatedPurchaseOrder.supplierId;
        final tanggalKirim = event.updatedPurchaseOrder.tanggalKirim;
        final tanggalPesan = event.updatedPurchaseOrder.tanggalPesan;
        final total = event.updatedPurchaseOrder.total;

        if(materialId.isNotEmpty){
         if(supplierId.isNotEmpty){
           try {
             final HttpsCallableResult<dynamic> result = await purchaseOrderCallable.call(<String, dynamic>{
                'hargaSatuan': hargaSatuan,
                'jumlah': jumlah,
                'total' : total
            });

            if(result.data['success']==true){
              final purchaseOrderDoc = purchaseOrderSnapshot.docs.first;
              await purchaseOrderDoc.reference.update(
                {
                  'id': event.purchaseOrderId,
                  'harga_satuan': hargaSatuan,
                  'jumlah': jumlah,
                  'keterangan': keterangan,
                  'material_id': materialId,
                  'satuan': satuan,
                  'status': status,
                  'status_pembayaran': statusPembayaran,
                  'status_pengiriman': statusPengiriman,
                  'supplier_id': supplierId,
                  'tanggal_kirim': tanggalKirim,
                  'tanggal_pesan': tanggalPesan,
                  'total': total,
                }
              );
              yield SuccessState();
            }else{
              yield ErrorState(result.data['message']);
            }

          } catch (e) {
            yield ErrorState(e.toString());
          }
         }else{
          yield ErrorState('kode supplier tidak boleh kosong');
         }
        }else{
          yield ErrorState('kode bahan tidak boleh kosong');
        }

      }else {
          yield ErrorState('Purchase Order dengan ID ${event.purchaseOrderId} tidak ditemukan.');
      }
     
    } else if (event is DeletePurchaseOrderEvent) {
      yield LoadingState();
      try {
        final purchaseOrderSnapshot = await purchaseOrdersRef.where('id', isEqualTo: event.purchaseOrderId).get();
        for (QueryDocumentSnapshot documentSnapshot in purchaseOrderSnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        yield LoadedState(await _getPurchaseOrders());
      } catch (e) {
        yield ErrorState("Gagal menghapus Purchase Order.");
      }
    }
  }

  Future<String> _generateNextPurchaseOrderId() async {
    final QuerySnapshot snapshot = await purchaseOrdersRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int purchaseOrderCount = 1;

    while (true) {
      final nextPurchaseOrderId = 'PO${purchaseOrderCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextPurchaseOrderId)) {
        return nextPurchaseOrderId;
      }
      purchaseOrderCount++;
    }
  }

  Future<List<PurchaseOrder>> _getPurchaseOrders() async {
    final QuerySnapshot snapshot = await purchaseOrdersRef.get();
    final List<PurchaseOrder> purchaseOrders = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      purchaseOrders.add(PurchaseOrder.fromJson(data));
    }
    return purchaseOrders;
  }
}
