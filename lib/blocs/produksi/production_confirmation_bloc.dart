import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/production_confirmation.dart';

// Events
abstract class ProductionConfirmationEvent {}

class AddProductionConfirmationEvent extends ProductionConfirmationEvent {
  final ProductionConfirmation productionConfirmation;
  AddProductionConfirmationEvent(this.productionConfirmation);
}

class UpdateProductionConfirmationEvent extends ProductionConfirmationEvent {
  final String productionConfirmationId;
  final ProductionConfirmation productionConfirmation;
  UpdateProductionConfirmationEvent(
      this.productionConfirmationId, this.productionConfirmation);
}

class DeleteProductionConfirmationEvent extends ProductionConfirmationEvent {
  final String productionConfirmationId;
  DeleteProductionConfirmationEvent(this.productionConfirmationId);
}

// States
abstract class ProductionConfirmationBlocState {}

class LoadingState extends ProductionConfirmationBlocState {}

class SuccessState extends ProductionConfirmationBlocState {}

class LoadedState extends ProductionConfirmationBlocState {
  final ProductionConfirmation productionConfirmation;
  LoadedState(this.productionConfirmation);
}

class ProductionConfirmationUpdatedState extends ProductionConfirmationBlocState {}

class ProductionConfirmationDeletedState extends ProductionConfirmationBlocState {}

class ErrorState extends ProductionConfirmationBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class ProductionConfirmationBloc
    extends Bloc<ProductionConfirmationEvent, ProductionConfirmationBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable proConfCallable;

  ProductionConfirmationBloc() : proConfCallable = FirebaseFunctions.instance.httpsCallable('productionConfirmationValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ProductionConfirmationBlocState> mapEventToState(
      ProductionConfirmationEvent event) async* {
    if (event is AddProductionConfirmationEvent) {
      yield LoadingState();

      final confirmations = event.productionConfirmation.detailProductionConfirmations;
      if(confirmations.isNotEmpty){
         try {
          final HttpsCallableResult<dynamic> result = await proConfCallable.call(<String, dynamic>{
              'confirmations': confirmations.map((confirmation) => confirmation.toJson()).toList(),
            });

           if (result.data['success'] == true) {
             // Generate a new production confirmation ID (or use an existing one if you have it)
            final nextProductionConfirmationId =
                await _generateNextProductionConfirmationId();

            // Create a reference to the production confirmation document using the appropriate ID
            final productionConfirmationRef = _firestore
                .collection('production_confirmations')
                .doc(nextProductionConfirmationId);

            // Set the production confirmation data
            final Map<String, dynamic> productionConfirmationData = {
              'id': nextProductionConfirmationId,
              'catatan': event.productionConfirmation.catatan,
              'status': event.productionConfirmation.status,
              'status_prc': event.productionConfirmation.statusPrc,
              'tanggal_konfirmasi': event.productionConfirmation.tanggalKonfirmasi,
              'total': event.productionConfirmation.total
            };

            // Add the production confirmation data to Firestore
            await productionConfirmationRef.set(productionConfirmationData);

            // Create a reference to the 'details' subcollection within the production confirmation document
            final detailsRef =
                productionConfirmationRef.collection('detail_production_confirmations');

            if (event.productionConfirmation.detailProductionConfirmations.isNotEmpty) {
              int detailCount = 1;
              for (var detail
                  in event.productionConfirmation.detailProductionConfirmations) {
                final nextDetailId =
                    '$nextProductionConfirmationId${'D${detailCount.toString().padLeft(3, '0')}'}';

                // Add the detail document to the 'details' collection
                await detailsRef.add({
                  'id': nextDetailId,
                  'production_confirmation_id': nextProductionConfirmationId,
                  'jumlah_konfirmasi': detail.jumlahKonfirmasi,
                  'production_result_id': detail.productionResultId,
                  'satuan' : detail.satuan,
                  'product_id' : detail.productId
                });
                detailCount++;
              }
            }
            yield SuccessState();
           }else{
            yield ErrorState(result.data['message']);
           }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      }else{
        yield ErrorState("detail konfirmasi tidak boleh kosong");
      }
    } else if (event is UpdateProductionConfirmationEvent) {
      yield LoadingState();
      final confirmations = event.productionConfirmation.detailProductionConfirmations;
      if(confirmations.isNotEmpty){
         try {
           final HttpsCallableResult<dynamic> result = await proConfCallable.call(<String, dynamic>{
              'confirmations': confirmations.map((material) => material.toJson()).toList(),
            });

           if (result.data['success'] == true) {
             // Get a reference to the production confirmation document to be updated
            final productionConfirmationToUpdateRef = _firestore
                .collection('production_confirmations')
                .doc(event.productionConfirmationId);

            // Set the new production confirmation data
            final Map<String, dynamic> productionConfirmationData = {
              'id': event.productionConfirmationId,
              'catatan': event.productionConfirmation.catatan,
              'status': event.productionConfirmation.status,
              'status_prc': event.productionConfirmation.statusPrc,
              'tanggal_konfirmasi': event.productionConfirmation.tanggalKonfirmasi,
              'total': event.productionConfirmation.total
            };

            // Update the production confirmation data within the existing document
            await productionConfirmationToUpdateRef
                .set(productionConfirmationData);

            // // Delete all documents within the 'details' subcollection first
            // final detailsCollectionRef = productionConfirmationToUpdateRef.collection('detail_production_confirmations');
            // final detailsDocs = await detailsCollectionRef.get();
            // for (var doc in detailsDocs.docs) {
            //   await doc.reference.delete();
            // }

            // // Add the new detail documents to the 'details' subcollection
            // if (event.productionConfirmation.detailProductionConfirmations.isNotEmpty) {
            //   int detailCount = 1;
            //   for (var detail in event.productionConfirmation.detailProductionConfirmations) {
            //     final nextDetailId =
            //         'D${detailCount.toString().padLeft(3, '0')}';
            //     final detailId = event.productionConfirmationId + nextDetailId;

            //     // Add the detail documents to the 'details' collection
            //     await detailsCollectionRef.add({
            //       'id': detailId,
            //       'production_confirmation_id': event.productionConfirmationId,
            //       'jumlah_konfirmasi': detail.jumlahKonfirmasi,
            //       'production_result_id': detail.productionResultId,
            //       'satuan' : detail.satuan,
            //       'product_id' : detail.productId
            //     });
            //     detailCount++;
            //   }
            // }

            yield SuccessState();
           }else{
            result.data['message'];
           }
  
          } catch (e) {
            yield ErrorState(e.toString());
          }
      }else{
        yield ErrorState("detail konfirmasi tidak boleh kosong");
      }
    } else if (event is DeleteProductionConfirmationEvent) {
      yield LoadingState();
      try {
        // Get a reference to the production confirmation document to be deleted
        final productionConfirmationToDeleteRef = _firestore
            .collection('production_confirmations')
            .doc(event.productionConfirmationId);

        // Get a reference to the 'details' subcollection within the production confirmation document
        final detailsCollectionRef =
            productionConfirmationToDeleteRef.collection('detail_production_confirmations');

        // Delete all documents within the 'details' subcollection
        final detailsDocs = await detailsCollectionRef.get();
        for (var doc in detailsDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents within the subcollection, delete the production confirmation document itself
        await productionConfirmationToDeleteRef.delete();

        yield ProductionConfirmationDeletedState();
      } catch (e) {
        yield ErrorState("Failed to delete Production Confirmation.");
      }
    }
  }

  Future<String> _generateNextProductionConfirmationId() async {
    final productionConfirmationsRef =
        _firestore.collection('production_confirmations');
    final QuerySnapshot snapshot = await productionConfirmationsRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int productionConfirmationCount = 1;

    while (true) {
      final nextProductionConfirmationId =
          'PRC${productionConfirmationCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextProductionConfirmationId)) {
        return nextProductionConfirmationId;
      }
      productionConfirmationCount++;
    }
  }
}
