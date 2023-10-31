import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/pembelian/purchase_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';

// Events
abstract class PurchaseRequestEvent {}

class AddPurchaseRequestEvent extends PurchaseRequestEvent {
  final PurchaseRequest purchaseRequest;
  AddPurchaseRequestEvent(this.purchaseRequest);
}

class UpdatePurchaseRequestEvent extends PurchaseRequestEvent {
  final String purchaseRequestId;
  final PurchaseRequest updatedPurchaseRequest;
  UpdatePurchaseRequestEvent(
      this.purchaseRequestId, this.updatedPurchaseRequest);
}

class DeletePurchaseRequestEvent extends PurchaseRequestEvent {
  final String purchaseRequestId;
  DeletePurchaseRequestEvent(this.purchaseRequestId);
}

// States
abstract class PurchaseRequestBlocState {}

class LoadingState extends PurchaseRequestBlocState {}

class SuccessState extends PurchaseRequestBlocState {}

class LoadedState extends PurchaseRequestBlocState {
  final List<PurchaseRequest> purchaseRequestList;
  LoadedState(this.purchaseRequestList);
}

class ErrorState extends PurchaseRequestBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class PurchaseRequestBloc
    extends Bloc<PurchaseRequestEvent, PurchaseRequestBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference purchaseRequestRef;
  final HttpsCallable purchaseReqCallable;
  final notificationService = NotificationService();

  PurchaseRequestBloc()
      : purchaseReqCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('purchaseReqValidation'),
        super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    purchaseRequestRef = _firestore.collection('purchase_requests');
  }

  @override
  Stream<PurchaseRequestBlocState> mapEventToState(
      PurchaseRequestEvent event) async* {
    if (event is AddPurchaseRequestEvent) {
      yield LoadingState();

      final materialId = event.purchaseRequest.materialId;
      final jumlah = event.purchaseRequest.jumlah;

      if (materialId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await purchaseReqCallable.call(<String, dynamic>{
            'jumlah': jumlah,
          });

          if (result.data['success'] == true) {
            final String nextPurchaseRequestId =
                await _generateNextPurchaseRequestId();
            final purchaseRequestRef = _firestore
                .collection('purchase_requests')
                .doc(nextPurchaseRequestId);

            final Map<String, dynamic> purchaseRequestData = {
              'id': nextPurchaseRequestId,
              'catatan': event.purchaseRequest.catatan,
              'jumlah': jumlah,
              'material_id': materialId,
              'satuan': event.purchaseRequest.satuan,
              'status': event.purchaseRequest.status,
              'status_prq': event.purchaseRequest.statusPrq,
              'tanggal_permintaan': event.purchaseRequest.tanggalPermintaan,
            };

            await purchaseRequestRef.set(purchaseRequestData);

            await notificationService.addNotification(
                'Terdapat permintaan pembelian bahan baru $nextPurchaseRequestId untuk $materialId',
                'Administrasi');

            yield SuccessState();
          } else {
            yield ErrorState(result.data['message']);
          }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      } else {
        yield ErrorState("kode bahan tidak boleh kosong");
      }
    } else if (event is UpdatePurchaseRequestEvent) {
      yield LoadingState();
      final materialId = event.updatedPurchaseRequest.materialId;
      final jumlah = event.updatedPurchaseRequest.jumlah;
      final statusPrq = event.updatedPurchaseRequest.statusPrq;

      if (materialId.isNotEmpty) {
        if (statusPrq.isNotEmpty && statusPrq != "Selesai") {
          try {
            final HttpsCallableResult<dynamic> result =
                await purchaseReqCallable.call(<String, dynamic>{
              'jumlah': jumlah,
            });

            if (result.data['success'] == true) {
              final purchaseRequestSnapshot = await purchaseRequestRef
                  .where('id', isEqualTo: event.purchaseRequestId)
                  .get();
              if (purchaseRequestSnapshot.docs.isNotEmpty) {
                final purchaseRequestDoc = purchaseRequestSnapshot.docs.first;
                await purchaseRequestDoc.reference.update({
                  'catatan': event.updatedPurchaseRequest.catatan,
                  'jumlah': jumlah,
                  'material_id': materialId,
                  'satuan': event.updatedPurchaseRequest.satuan,
                  'status': event.updatedPurchaseRequest.status,
                  'status_prq': event.updatedPurchaseRequest.statusPrq,
                  'tanggal_permintaan':
                      event.updatedPurchaseRequest.tanggalPermintaan,
                });
                yield SuccessState();
              } else {
                yield ErrorState(
                    'Data Purchase Request dengan ID ${event.purchaseRequestId} tidak ditemukan.');
              }
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState(e.toString());
          }
        } else {
          yield ErrorState(
              "permintaan pembelian yang telah selesai\ntidak dapat diubah");
        }
      } else {
        yield ErrorState("kode bahan tidak boleh kosong");
      }
    } else if (event is DeletePurchaseRequestEvent) {
      yield LoadingState();
      try {
        final QuerySnapshot querySnapshot = await purchaseRequestRef
            .where('id', isEqualTo: event.purchaseRequestId)
            .get();

        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          // Perbarui status menjadi 0
          await documentSnapshot.reference.update({'status': 0});
        }
        yield SuccessState();
      } catch (e) {
        yield ErrorState("Gagal menghapus Purchase Request.");
      }
    }
  }

  Future<String> _generateNextPurchaseRequestId() async {
    final QuerySnapshot snapshot = await purchaseRequestRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int purchaseRequestCount = 1;

    while (true) {
      final nextPurchaseRequestId =
          'PRQ${purchaseRequestCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextPurchaseRequestId)) {
        return nextPurchaseRequestId;
      }
      purchaseRequestCount++;
    }
  }

  Future<List<PurchaseRequest>> _getPurchaseRequestList() async {
    final QuerySnapshot snapshot = await purchaseRequestRef.get();
    final List<PurchaseRequest> purchaseRequestList = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      purchaseRequestList.add(PurchaseRequest.fromJson(data));
    }
    return purchaseRequestList;
  }
}
