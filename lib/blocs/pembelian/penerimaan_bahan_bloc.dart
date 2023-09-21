import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/material_receive.dart';

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

  MaterialReceiveBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    materialReceiveRef = _firestore.collection('material_receives');
  }

  @override
  Stream<MaterialReceiveBlocState> mapEventToState(MaterialReceiveEvent event) async* {
    if (event is AddMaterialReceiveEvent) {
      yield LoadingState();
      try {
        final String nextMaterialReceiveId = await _generateNextMaterialReceiveId();
        final materialReceiveRef = _firestore.collection('material_receives').doc(nextMaterialReceiveId);

        final Map<String, dynamic> materialReceiveData = {
          'id': nextMaterialReceiveId,
          'purchase_request_id': event.materialReceive.purchaseRequestId,
          'material_id': event.materialReceive.materialId,
          'supplier_id': event.materialReceive.supplierId,
          'satuan': event.materialReceive.satuan,
          'jumlah_permintaan': event.materialReceive.jumlahPermintaan,
          'jumlah_diterima': event.materialReceive.jumlahDiterima,
          'status': event.materialReceive.status,
          'catatan': event.materialReceive.catatan,
          'tanggal_penerimaan': event.materialReceive.tanggalPenerimaan,
        };

        await materialReceiveRef.set(materialReceiveData);

        final materialReceiveList = await _getMaterialReceiveList();
        yield LoadedState(materialReceiveList);
      } catch (e) {
        yield ErrorState("Gagal menambahkan Material Receive.");
      }
    } else if (event is UpdateMaterialReceiveEvent) {
      yield LoadingState();
      try {
        final materialReceiveSnapshot = await materialReceiveRef.where('id', isEqualTo: event.materialReceiveId).get();
        if (materialReceiveSnapshot.docs.isNotEmpty) {
          final materialReceiveDoc = materialReceiveSnapshot.docs.first;
          await materialReceiveDoc.reference.update({
            'purchase_request_id': event.updatedMaterialReceive.purchaseRequestId,
            'material_id': event.updatedMaterialReceive.materialId,
            'supplier_id': event.updatedMaterialReceive.supplierId,
            'satuan': event.updatedMaterialReceive.satuan,
            'jumlah_permintaan': event.updatedMaterialReceive.jumlahPermintaan,
            'jumlah_diterima': event.updatedMaterialReceive.jumlahDiterima,
            'status': event.updatedMaterialReceive.status,
            'catatan': event.updatedMaterialReceive.catatan,
            'tanggal_penerimaan': event.updatedMaterialReceive.tanggalPenerimaan,
          });
          final materialReceiveList = await _getMaterialReceiveList();
          yield LoadedState(materialReceiveList);
        } else {
          yield ErrorState('Data Material Receive dengan ID ${event.materialReceiveId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah Material Receive.");
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
