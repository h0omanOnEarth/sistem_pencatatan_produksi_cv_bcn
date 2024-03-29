import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/item_receive.dart';

// Events
abstract class ItemReceiveEvent {}

class AddItemReceiveEvent extends ItemReceiveEvent {
  final ItemReceive itemReceive;
  AddItemReceiveEvent(this.itemReceive);
}

class UpdateItemReceiveEvent extends ItemReceiveEvent {
  final String itemReceiveId;
  final ItemReceive itemReceive;
  UpdateItemReceiveEvent(this.itemReceiveId, this.itemReceive);
}

class DeleteItemReceiveEvent extends ItemReceiveEvent {
  final String itemReceiveId;
  DeleteItemReceiveEvent(this.itemReceiveId);
}

class FinishedItemReceiveEvent extends ItemReceiveEvent {
  final String itemReceiveId;
  FinishedItemReceiveEvent(this.itemReceiveId);
}

// States
abstract class ItemReceiveBlocState {}

class ItemReceiveLoadingState extends ItemReceiveBlocState {}

class SuccessState extends ItemReceiveBlocState {}

class ItemReceiveLoadedState extends ItemReceiveBlocState {
  final ItemReceive itemReceive;
  ItemReceiveLoadedState(this.itemReceive);
}

class ItemReceiveUpdatedState extends ItemReceiveBlocState {}

class ItemReceiveDeletedState extends ItemReceiveBlocState {}

class ItemReceiveErrorState extends ItemReceiveBlocState {
  final String errorMessage;
  ItemReceiveErrorState(this.errorMessage);
}

// BLoC
class ItemReceiveBloc extends Bloc<ItemReceiveEvent, ItemReceiveBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable itemReceiveCallable;

  ItemReceiveBloc()
      : itemReceiveCallable =
            FirebaseFunctions.instanceFor(region: "asia-southeast2")
                .httpsCallable('itemReceiveValidation'),
        super(ItemReceiveLoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ItemReceiveBlocState> mapEventToState(ItemReceiveEvent event) async* {
    if (event is AddItemReceiveEvent) {
      yield ItemReceiveLoadingState();

      final productionConfirmationId =
          event.itemReceive.productionConfirmationId;
      final products = event.itemReceive.detailItemReceiveList;

      if (productionConfirmationId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await itemReceiveCallable.call(<String, dynamic>{
            'products': products.map((product) => product.toJson()).toList(),
            'productionConfirmationId': productionConfirmationId,
            'mode': 'add'
          });

          if (result.data['success'] == true) {
            final nextItemReceiveId = await _generateNextItemReceiveId();
            final itemReceiveRef =
                _firestore.collection('item_receives').doc(nextItemReceiveId);
            final Map<String, dynamic> itemReceiveData = {
              'id': nextItemReceiveId,
              'production_confirmation_id':
                  event.itemReceive.productionConfirmationId,
              'status': event.itemReceive.status,
              'status_irc': event.itemReceive.statusIrc,
              'tanggal_penerimaan': event.itemReceive.tanggalPenerimaan,
              'catatan': event.itemReceive.catatan,
            };
            await itemReceiveRef.set(itemReceiveData);
            final detailItemReceiveRef =
                itemReceiveRef.collection('detail_item_receives');
            if (event.itemReceive.detailItemReceiveList.isNotEmpty) {
              int detailCount = 1;
              for (var detailItemReceive
                  in event.itemReceive.detailItemReceiveList) {
                final nextDetailItemReceiveId =
                    '$nextItemReceiveId${'D${detailCount.toString().padLeft(3, '0')}'}';
                await detailItemReceiveRef.add({
                  'id': nextDetailItemReceiveId,
                  'item_receive_id': nextItemReceiveId,
                  'jumlah_dus': detailItemReceive.jumlahDus,
                  'jumlah_konfirmasi': detailItemReceive.jumlahKonfirmasi,
                  'product_id': detailItemReceive.productId,
                  'status': detailItemReceive.status,
                });
                detailCount++;
              }
            }

            yield SuccessState();
          } else {
            yield ItemReceiveErrorState(result.data['message']);
          }
        } catch (e) {
          yield ItemReceiveErrorState(e.toString());
        }
      } else {
        yield ItemReceiveErrorState(
            "nomor konfirmasi produksi tidak boleh kosong");
      }
    } else if (event is UpdateItemReceiveEvent) {
      yield ItemReceiveLoadingState();

      final productionConfirmationId =
          event.itemReceive.productionConfirmationId;
      final products = event.itemReceive.detailItemReceiveList;

      if (productionConfirmationId.isNotEmpty) {
        try {
          final HttpsCallableResult<dynamic> result =
              await itemReceiveCallable.call(<String, dynamic>{
            'products': products.map((material) => material.toJson()).toList(),
            'productionConfirmationId': productionConfirmationId,
            'mode': 'edit'
          });

          if (result.data['success'] == true) {
            final itemReceiveToUpdateRef =
                _firestore.collection('item_receives').doc(event.itemReceiveId);

            final Map<String, dynamic> itemReceiveData = {
              'id': event.itemReceiveId,
              'production_confirmation_id':
                  event.itemReceive.productionConfirmationId,
              'status': event.itemReceive.status,
              'status_irc': event.itemReceive.statusIrc,
              'tanggal_penerimaan': event.itemReceive.tanggalPenerimaan,
              'catatan': event.itemReceive.catatan,
            };

            await itemReceiveToUpdateRef.set(itemReceiveData);

            final detailItemReceiveCollectionRef =
                itemReceiveToUpdateRef.collection('detail_item_receives');
            final detailItemReceiveDocs =
                await detailItemReceiveCollectionRef.get();
            for (var doc in detailItemReceiveDocs.docs) {
              await doc.reference.delete();
            }

            if (event.itemReceive.detailItemReceiveList.isNotEmpty) {
              int detailCount = 1;
              for (var detailItemReceive
                  in event.itemReceive.detailItemReceiveList) {
                final nextDetailItemReceiveId =
                    'D${detailCount.toString().padLeft(3, '0')}';
                final detailId = event.itemReceiveId + nextDetailItemReceiveId;

                await detailItemReceiveCollectionRef.add({
                  'id': detailId,
                  'item_receive_id': event.itemReceiveId,
                  'jumlah_dus': detailItemReceive.jumlahDus,
                  'jumlah_konfirmasi': detailItemReceive.jumlahKonfirmasi,
                  'product_id': detailItemReceive.productId,
                  'status': detailItemReceive.status,
                });
                detailCount++;
              }
            }

            yield SuccessState();
          } else {
            yield ItemReceiveErrorState(result.data['message']);
          }
        } catch (e) {
          yield ItemReceiveErrorState(e.toString());
        }
      } else {
        yield ItemReceiveErrorState(
            "nomor konfirmasi produksi tidak boleh kosong");
      }
    } else if (event is DeleteItemReceiveEvent) {
      yield ItemReceiveLoadingState();
      try {
        final itemReceiveToDeleteRef =
            _firestore.collection('item_receives').doc(event.itemReceiveId);
        final detailItemReceiveCollectionRef =
            itemReceiveToDeleteRef.collection('detail_item_receives');
        final detailItemReceiveDocs =
            await detailItemReceiveCollectionRef.get();

        // Mengubah status item receive menjadi 0
        await itemReceiveToDeleteRef.update({'status': 0});

        for (var doc in detailItemReceiveDocs.docs) {
          final productId = doc['product_id'] as String;
          final quantity = doc['jumlah_konfirmasi'] as int;

          final productRef = _firestore
              .collection('products')
              .where('id', isEqualTo: productId);
          productRef.get().then((querySnapshot) {
            for (var productDoc in querySnapshot.docs) {
              final currentStock = productDoc['stok'] as int;
              final newStock = currentStock - quantity;
              productDoc.reference.update({'stok': newStock});
            }
          });

          // Mengubah status detail_item_receives menjadi 0
          doc.reference.update({'status': 0});
        }

        // Mengubah status production_confirmations yang sesuai
        final itemReceiveData =
            (await itemReceiveToDeleteRef.get()).data() as Map<String, dynamic>;
        final productionConfirmationId =
            itemReceiveData['production_confirmation_id'] as String;
        final productionConfirmationRef = _firestore
            .collection('production_confirmations')
            .doc(productionConfirmationId);
        await productionConfirmationRef.update({'status_prc': 'Dalam Proses'});

        yield SuccessState();
      } catch (e) {
        yield ItemReceiveErrorState("Failed to delete Item Receive.");
      }
    } else if (event is FinishedItemReceiveEvent) {
      yield ItemReceiveLoadingState();
      try {
        final itemReceiveRef =
            _firestore.collection('item_receives').doc(event.itemReceiveId);

        await itemReceiveRef.update({
          'status_irc': 'Selesai',
        });

        yield SuccessState();
      } catch (e) {
        yield ItemReceiveErrorState("Failed to finish Material Transform");
      }
    }
  }

  Future<String> _generateNextItemReceiveId() async {
    final itemReceivesRef = _firestore.collection('item_receives');
    final QuerySnapshot snapshot = await itemReceivesRef.get();
    final List<String> existingIds =
        snapshot.docs.map((doc) => doc['id'] as String).toList();
    int itemReceiveCount = 1;

    while (true) {
      final nextItemReceiveId =
          'IRC${itemReceiveCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextItemReceiveId)) {
        return nextItemReceiveId;
      }
      itemReceiveCount++;
    }
  }
}
