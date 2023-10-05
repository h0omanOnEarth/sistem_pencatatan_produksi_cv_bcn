import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/material_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';

// Events
abstract class MaterialReceiveEvent {}

class AddMaterialReceiveEvent extends MaterialReceiveEvent {
  final MaterialReceive materialReceive;
  AddMaterialReceiveEvent(this.materialReceive);
}

class UpdateMaterialReceiveEvent extends MaterialReceiveEvent {
  final String materialReceiveId;
  final MaterialReceive updatedMaterialReceive;
  UpdateMaterialReceiveEvent(this.materialReceiveId, this.updatedMaterialReceive);
}

class DeleteMaterialReceiveEvent extends MaterialReceiveEvent {
  final String materialReceiveId;
  DeleteMaterialReceiveEvent(this.materialReceiveId);
}

// States
abstract class MaterialReceiveBlocState {}

class LoadingState extends MaterialReceiveBlocState {}

class SuccessState extends MaterialReceiveBlocState {}

class LoadedState extends MaterialReceiveBlocState {
  final List<MaterialReceive> materialReceiveList;
  LoadedState(this.materialReceiveList);
}

class ErrorState extends MaterialReceiveBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MaterialReceiveBloc extends Bloc<MaterialReceiveEvent, MaterialReceiveBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference materialReceiveRef;
  final HttpsCallable purchaseReqCallable;
  final notificationService = NotificationService();

  MaterialReceiveBloc() : purchaseReqCallable = FirebaseFunctions.instance.httpsCallable('materialRecValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    materialReceiveRef = _firestore.collection('material_receives');
  }

  @override
  Stream<MaterialReceiveBlocState> mapEventToState(MaterialReceiveEvent event) async* {
    if (event is AddMaterialReceiveEvent) {
      yield LoadingState();

      final purchaseRequestId = event.materialReceive.purchaseRequestId;
      final materialId = event.materialReceive.materialId;
      final supplierId = event.materialReceive.supplierId;
      final jumlahPermintaan =event.materialReceive.jumlahPermintaan;
      final jumlahDiterima = event.materialReceive.jumlahDiterima;

      if(purchaseRequestId.isNotEmpty){
        if(materialId.isNotEmpty){
          if(supplierId.isNotEmpty){
          try {
            final HttpsCallableResult<dynamic> result = await purchaseReqCallable.call(<String, dynamic>{
              'jumlahPermintaan': jumlahPermintaan,
              'jumlahDiterima': jumlahDiterima,
              'materialId': materialId,
              'purchaseReqId': purchaseRequestId
            });

            if(result.data['success'] == true){
              final String nextMaterialReceiveId = await _generateNextMaterialReceiveId();
              final materialReceiveRef = _firestore.collection('material_receives').doc(nextMaterialReceiveId);

              final Map<String, dynamic> materialReceiveData = {
                'id': nextMaterialReceiveId,
                'purchase_request_id': purchaseRequestId,
                'material_id': materialId,
                'supplier_id': supplierId,
                'satuan': event.materialReceive.satuan,
                'jumlah_permintaan': jumlahPermintaan,
                'jumlah_diterima': jumlahDiterima,
                'status': event.materialReceive.status,
                'catatan': event.materialReceive.catatan,
                'tanggal_penerimaan': event.materialReceive.tanggalPenerimaan,
              };

              await materialReceiveRef.set(materialReceiveData);

              yield SuccessState();
            }else{
              yield ErrorState(result.data['message']);
            }
           
          } catch (e) {
            yield ErrorState(e.toString());
          }
          }else{
            ErrorState("kode supplier tidak boleh kosong");
          }
        }else{
          yield ErrorState("kode bahan tidak boleh kosong");
        }
      }else{
        yield ErrorState("nomor permintaan pembelian tidak boleh kosong\n harus melakukan permintaan pembelian terlebih dahulu");
      }
    } else if (event is UpdateMaterialReceiveEvent) {
      yield LoadingState();

      final purchaseRequestId = event.updatedMaterialReceive.purchaseRequestId;
      final materialId = event.updatedMaterialReceive.materialId;
      final supplierId = event.updatedMaterialReceive.supplierId;
      final jumlahPermintaan =event.updatedMaterialReceive.jumlahPermintaan;
      final jumlahDiterima = event.updatedMaterialReceive.jumlahDiterima;

      if(purchaseRequestId.isNotEmpty){
        if(materialId.isNotEmpty){
          if(supplierId.isNotEmpty){
          try {
            final HttpsCallableResult<dynamic> result = await purchaseReqCallable.call(<String, dynamic>{
              'jumlahPermintaan': jumlahPermintaan,
              'jumlahDiterima': jumlahDiterima,
              'materialId': materialId,
              'purchaseReqId': purchaseRequestId
            });

            if(result.data['success'] == true){
            final materialReceiveSnapshot = await materialReceiveRef.where('id', isEqualTo: event.materialReceiveId).get();
            if (materialReceiveSnapshot.docs.isNotEmpty) {
              final materialReceiveDoc = materialReceiveSnapshot.docs.first;
              await materialReceiveDoc.reference.update({
                'purchase_request_id':purchaseRequestId,
                'material_id': materialId,
                'supplier_id': supplierId,
                'satuan': event.updatedMaterialReceive.satuan,
                'jumlah_permintaan': jumlahPermintaan,
                'jumlah_diterima': jumlahDiterima,
                'status': event.updatedMaterialReceive.status,
                'catatan': event.updatedMaterialReceive.catatan,
                'tanggal_penerimaan': event.updatedMaterialReceive.tanggalPenerimaan,
              });
              yield SuccessState();
            } else {
              yield ErrorState('Data Material Receive dengan ID ${event.materialReceiveId} tidak ditemukan.');
            }
            }else{
              result.data['message'];
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
      }else{
        yield ErrorState("nomor permintaan pembelian tidak boleh kosong");
      }
    } else if (event is DeleteMaterialReceiveEvent) {
      yield LoadingState();
      try {
        final QuerySnapshot querySnapshot = await materialReceiveRef.where('id', isEqualTo: event.materialReceiveId).get();
          
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        final materialReceiveList = await _getMaterialReceiveList();
        yield LoadedState(materialReceiveList);
      } catch (e) {
        yield ErrorState("Gagal menghapus Material Receive.");
      }
    }
  }

  Future<String> _generateNextMaterialReceiveId() async {
    final QuerySnapshot snapshot = await materialReceiveRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialReceiveCount = 1;

    while (true) {
      final nextMaterialReceiveId = 'MRV${materialReceiveCount.toString().padLeft(6, '0')}';
      if (!existingIds.contains(nextMaterialReceiveId)) {
        return nextMaterialReceiveId;
      }
      materialReceiveCount++;
    }
  }

  Future<List<MaterialReceive>> _getMaterialReceiveList() async {
    final QuerySnapshot snapshot = await materialReceiveRef.get();
    final List<MaterialReceive> materialReceiveList = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      materialReceiveList.add(MaterialReceive.fromJson(data));
    }
    return materialReceiveList;
  }
}
