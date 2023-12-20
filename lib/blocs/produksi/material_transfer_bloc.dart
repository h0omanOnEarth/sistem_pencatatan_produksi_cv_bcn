import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/detail_material_transfer.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/material_transfer.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/emailNotificationService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/notificationService.dart';

// Events
abstract class MaterialTransferEvent {}

class AddMaterialTransferEvent extends MaterialTransferEvent {
  final MaterialTransfer materialTransfer;
  AddMaterialTransferEvent(this.materialTransfer);
}

class UpdateMaterialTransferEvent extends MaterialTransferEvent {
  final String materialTransferId;
  final MaterialTransfer materialTransfer;
  UpdateMaterialTransferEvent(this.materialTransferId, this.materialTransfer);
}

class DeleteMaterialTransferEvent extends MaterialTransferEvent {
  final String materialTransferId;
  DeleteMaterialTransferEvent(this.materialTransferId);
}

class FinishedMaterialTransferEvent extends MaterialTransferEvent {
  final String materialTransferId;
  FinishedMaterialTransferEvent(this.materialTransferId);
}

// States
abstract class MaterialTransferBlocState {}

class MaterialTransferLoadingState extends MaterialTransferBlocState {}

class SuccessState extends MaterialTransferBlocState {}

class MaterialTransferLoadedState extends MaterialTransferBlocState {
  final MaterialTransfer materialTransfer;
  MaterialTransferLoadedState(this.materialTransfer);
}

class MaterialTransferUpdatedState extends MaterialTransferBlocState {}

class MaterialTransferDeletedState extends MaterialTransferBlocState {}

class MaterialTransferErrorState extends MaterialTransferBlocState {
  final String errorMessage;
  MaterialTransferErrorState(this.errorMessage);
}

// BLoC
class MaterialTransferBloc
    extends Bloc<MaterialTransferEvent, MaterialTransferBlocState> {
  late FirebaseFirestore _firestore;
  final notificationService = NotificationService();
  final HttpsCallable materialTransferCallable;

  MaterialTransferBloc()
      : materialTransferCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('materialTransferValidation'),
        super(MaterialTransferLoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<MaterialTransferBlocState> mapEventToState(
      MaterialTransferEvent event) async* {
    if (event is AddMaterialTransferEvent) {
      yield MaterialTransferLoadingState();

      final materialRequestId = event.materialTransfer.materialRequestId;
      final materials = event.materialTransfer.detailList;

      if (materialRequestId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await materialTransferCallable.call(<String, dynamic>{
            'materials':
                materials.map((material) => material.toJson()).toList(),
            'materialRequestId': materialRequestId,
          });

          if (result.data['success'] == true) {
            final nextMaterialTransferId =
                await _generateNextMaterialTransferId();

            // Create a reference to the material transfer document using the appropriate ID
            final materialTransferRef = _firestore
                .collection('material_transfers')
                .doc(nextMaterialTransferId);

            // Set the material transfer data
            final Map<String, dynamic> materialTransferData = {
              'id': nextMaterialTransferId,
              'material_request_id': materialRequestId,
              'status_mtr': event.materialTransfer.statusMtr,
              'tanggal_pemindahan': event.materialTransfer.tanggalPemindahan,
              'catatan': event.materialTransfer.catatan,
              'status': event.materialTransfer.status,
            };

            // Add the material transfer data to Firestore
            await materialTransferRef.set(materialTransferData);

            // Create a reference to the 'detail_material_transfers' subcollection within the material transfer document
            final detailMaterialTransferRef =
                materialTransferRef.collection('detail_material_transfers');

            if (event.materialTransfer.detailList.isNotEmpty) {
              int detailCount = 1;
              for (var detailMaterialTransfer
                  in event.materialTransfer.detailList) {
                final nextDetailMaterialTransferId =
                    '$nextMaterialTransferId${'D${detailCount.toString().padLeft(3, '0')}'}';

                // Add the detail material transfer document to the 'detail_material_transfers' collection
                await detailMaterialTransferRef.add({
                  'id': nextDetailMaterialTransferId,
                  'material_transfer_id': nextMaterialTransferId,
                  'jumlah_bom': detailMaterialTransfer.jumlahBom,
                  'material_id': detailMaterialTransfer.materialId,
                  'satuan': detailMaterialTransfer.satuan,
                  'status': detailMaterialTransfer.status,
                  'stok': detailMaterialTransfer.stok,
                });
                detailCount++;
              }
            }

            await notificationService.addNotification(
                'Terdapat pemindahan bahan baru $nextMaterialTransferId untuk ${event.materialTransfer.materialRequestId}',
                'Produksi');

            EmailNotificationService.sendNotification(
              'Pemindahan Bahan Baru',
              _createEmailMessage(
                  nextMaterialTransferId,
                  materialRequestId,
                  event.materialTransfer.catatan,
                  event.materialTransfer.tanggalPemindahan,
                  materials),
              'Produksi',
            );

            yield SuccessState();
          } else {
            yield MaterialTransferErrorState(result.data['message']);
          }
        } catch (e) {
          yield MaterialTransferErrorState(e.toString());
        }
      } else {
        yield MaterialTransferErrorState(
            'nomor permintaan bahan tidak boleh kosong');
      }
    } else if (event is UpdateMaterialTransferEvent) {
      yield MaterialTransferLoadingState();
      final materialRequestId = event.materialTransfer.materialRequestId;
      final materials = event.materialTransfer.detailList;

      if (materialRequestId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await materialTransferCallable.call(<String, dynamic>{
            'materials':
                materials.map((material) => material.toJson()).toList(),
            'materialRequestId': materialRequestId,
          });

          if (result.data['success'] == true) {
            // Get a reference to the material transfer document to be updated
            final materialTransferToUpdateRef = _firestore
                .collection('material_transfers')
                .doc(event.materialTransferId);

            // Set the new material transfer data
            final Map<String, dynamic> materialTransferData = {
              'id': event.materialTransferId,
              'material_request_id': event.materialTransfer.materialRequestId,
              'status_mtr': event.materialTransfer.statusMtr,
              'tanggal_pemindahan': event.materialTransfer.tanggalPemindahan,
              'catatan': event.materialTransfer.catatan,
              'status': event.materialTransfer.status,
            };

            // Update the material transfer data within the existing document
            await materialTransferToUpdateRef.set(materialTransferData);

            // Delete all documents within the 'detail_material_transfers' subcollection first
            final detailMaterialTransferCollectionRef =
                materialTransferToUpdateRef
                    .collection('detail_material_transfers');
            final detailMaterialTransferDocs =
                await detailMaterialTransferCollectionRef.get();
            for (var doc in detailMaterialTransferDocs.docs) {
              await doc.reference.delete();
            }

            // Add the new detail material transfer documents to the 'detail_material_transfers' subcollection
            if (event.materialTransfer.detailList.isNotEmpty) {
              int detailCount = 1;
              for (var detailMaterialTransfer
                  in event.materialTransfer.detailList) {
                final nextDetailMaterialTransferId =
                    'D${detailCount.toString().padLeft(3, '0')}';
                final detailId =
                    event.materialTransferId + nextDetailMaterialTransferId;

                // Add the detail material transfer documents to the 'detail_material_transfers' collection
                await detailMaterialTransferCollectionRef.add({
                  'id': detailId,
                  'material_transfer_id': event.materialTransferId,
                  'jumlah_bom': detailMaterialTransfer.jumlahBom,
                  'material_id': detailMaterialTransfer.materialId,
                  'satuan': detailMaterialTransfer.satuan,
                  'status': detailMaterialTransfer.status,
                  'stok': detailMaterialTransfer.stok,
                });
                detailCount++;
              }
            }
            yield SuccessState();
          } else {
            yield MaterialTransferErrorState(result.data['message']);
          }
        } catch (e) {
          yield MaterialTransferErrorState(e.toString());
        }
      } else {
        yield MaterialTransferErrorState(
            "nomor permintaan bahan tidak boleh kosong");
      }
    } else if (event is DeleteMaterialTransferEvent) {
      yield MaterialTransferLoadingState();
      try {
        // Get a reference to the material transfer document to be deleted
        final materialTransferToDeleteRef = _firestore
            .collection('material_transfers')
            .doc(event.materialTransferId);

        // Get a reference to the 'detail_material_transfers' subcollection within the material transfer document
        final detailMaterialTransferCollectionRef =
            materialTransferToDeleteRef.collection('detail_material_transfers');

        final detailMaterialTransferDocs =
            await detailMaterialTransferCollectionRef.get();

        // Loop through each document in the subcollection
        for (var doc in detailMaterialTransferDocs.docs) {
          // Get the data of the detail material transfer
          final detailMaterialTransferData = doc.data();
          final materialId =
              detailMaterialTransferData['material_id'] as String;
          final quantity = detailMaterialTransferData['jumlah_bom'] as int;

          // Update the status of the detail material transfer document to 0
          await doc.reference.update({'status': 0});

          // Get a reference to the material to update the stock
          final materialRef = _firestore
              .collection('materials')
              .where('id', isEqualTo: materialId);

          // Get the current stock of the material
          final materialQuery = await materialRef.get();
          final materialDoc = materialQuery.docs.first;
          final currentStock = materialDoc['stok'] as int;

          // Update the stock by adding the quantity back
          final newStock = currentStock + quantity;

          // Update the stock of the material
          await materialDoc.reference.update({'stok': newStock});
        }

        // Update the status of the material transfer document itself to 0
        await materialTransferToDeleteRef.update({'status': 0});

        yield SuccessState();
      } catch (e) {
        yield MaterialTransferErrorState("Failed to delete Material Transfer.");
      }
    } else if (event is FinishedMaterialTransferEvent) {
      yield MaterialTransferLoadingState();
      try {
        final materialTransferRef = _firestore
            .collection('material_transfers')
            .doc(event.materialTransferId);

        await materialTransferRef.update({
          'status_mtr': 'Selesai',
        });

        yield SuccessState();
      } catch (e) {
        yield MaterialTransferErrorState("Failed to finish Material Transfer");
      }
    }
  }

  Future<String> _generateNextMaterialTransferId() async {
    final materialTransfersRef = _firestore.collection('material_transfers');
    final QuerySnapshot snapshot = await materialTransfersRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int materialTransferCount = 1;

    while (true) {
      final nextMaterialTransferId =
          'MTR${materialTransferCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextMaterialTransferId)) {
        return nextMaterialTransferId;
      }
      materialTransferCount++;
    }
  }

  String _createEmailMessage(
    String nextMaterialTransferId,
    String materialRequestId,
    String catatan,
    DateTime tanggalPemindahan,
    List<MaterialTransferDetail> materials,
  ) {
    final StringBuffer message = StringBuffer();

    message
        .write('Pemindahan Bahan $nextMaterialTransferId baru ditambahkan<br>');
    message.write('<br>Detail Pemindahan Bahan:<br>');
    message.write('MATERIAL REQUEST ID: $materialRequestId<br>');
    message.write('Catatan: $catatan<br>');
    message.write('Tanggal Pemindahan: $tanggalPemindahan<br>');

    message.write('<br>Materials:<br>');
    for (final material in materials) {
      message.write('- Material ID: ${material.materialId}<br>');
      message.write('  Jumlah : ${material.jumlahBom}<br>');
      message.write('  Satuan: ${material.satuan}<br>');
      message.write('<br>');
    }

    return message.toString();
  }
}
