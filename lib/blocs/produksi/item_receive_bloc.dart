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

// States
abstract class ItemReceiveBlocState {}

class ItemReceiveLoadingState extends ItemReceiveBlocState {}

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
class ItemReceiveBloc
    extends Bloc<ItemReceiveEvent, ItemReceiveBlocState> {
  late FirebaseFirestore _firestore;

  ItemReceiveBloc() : super(ItemReceiveLoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<ItemReceiveBlocState> mapEventToState(
      ItemReceiveEvent event) async* {
    if (event is AddItemReceiveEvent) {
      yield ItemReceiveLoadingState();
      try {
        // Generate a new item receive ID (or use an existing one if you have it)
        final nextItemReceiveId = await _generateNextItemReceiveId();

        // Create a reference to the item receive document using the appropriate ID
        final itemReceiveRef =
            _firestore.collection('item_receives').doc(nextItemReceiveId);

        // Set the item receive data
        final Map<String, dynamic> itemReceiveData = {
          'id': nextItemReceiveId,
          'production_confirmation_id': event.itemReceive.productionConfirmationId,
          'status': event.itemReceive.status,
          'status_irc': event.itemReceive.statusIrc,
          'tanggal_penerimaan': event.itemReceive.tanggalPenerimaan,
          'catatan': event.itemReceive.catatan,
        };

        // Add the item receive data to Firestore
        await itemReceiveRef.set(itemReceiveData);

        // Create a reference to the 'detail_item_receives' subcollection within the item receive document
        final detailItemReceiveRef =
            itemReceiveRef.collection('detail_item_receives');

        if (event.itemReceive.detailItemReceiveList.isNotEmpty) {
          int detailCount = 1;
          for (var detailItemReceive
              in event.itemReceive.detailItemReceiveList) {
            final nextDetailItemReceiveId =
                '$nextItemReceiveId${'D${detailCount.toString().padLeft(3, '0')}'}';

            // Add the detail item receive document to the 'detail_item_receives' collection
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

        yield ItemReceiveLoadedState(event.itemReceive);
      } catch (e) {
        yield ItemReceiveErrorState("Failed to add Item Receive.");
      }
    } else if (event is UpdateItemReceiveEvent) {
      yield ItemReceiveLoadingState();
      try {
        // Get a reference to the item receive document to be updated
        final itemReceiveToUpdateRef =
            _firestore.collection('item_receives').doc(event.itemReceiveId);

        // Set the new item receive data
        final Map<String, dynamic> itemReceiveData = {
          'id': event.itemReceiveId,
          'production_confirmation_id': event.itemReceive.productionConfirmationId,
          'status': event.itemReceive.status,
          'status_irc': event.itemReceive.statusIrc,
          'tanggal_penerimaan': event.itemReceive.tanggalPenerimaan,
          'catatan': event.itemReceive.catatan,
        };

        // Update the item receive data within the existing document
        await itemReceiveToUpdateRef.set(itemReceiveData);

        // Delete all documents within the 'detail_item_receives' subcollection first
        final detailItemReceiveCollectionRef =
            itemReceiveToUpdateRef.collection('detail_item_receives');
        final detailItemReceiveDocs =
            await detailItemReceiveCollectionRef.get();
        for (var doc in detailItemReceiveDocs.docs) {
          await doc.reference.delete();
        }

        // Add the new detail item receive documents to the 'detail_item_receives' subcollection
        if (event.itemReceive.detailItemReceiveList.isNotEmpty) {
          int detailCount = 1;
          for (var detailItemReceive
              in event.itemReceive.detailItemReceiveList) {
            final nextDetailItemReceiveId =
                'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.itemReceiveId + nextDetailItemReceiveId;

            // Add the detail item receive documents to the 'detail_item_receives' collection
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

        yield ItemReceiveUpdatedState();
      } catch (e) {
        yield ItemReceiveErrorState("Failed to update Item Receive.");
      }
    } else if (event is DeleteItemReceiveEvent) {
      yield ItemReceiveLoadingState();
      try {
        // Get a reference to the item receive document to be deleted
        final itemReceiveToDeleteRef =
            _firestore.collection('item_receives').doc(event.itemReceiveId);

        // Get a reference to the 'detail_item_receives' subcollection within the item receive document
        final detailItemReceiveCollectionRef =
            itemReceiveToDeleteRef.collection('detail_item_receives');

        // Delete all documents within the 'detail_item_receives' subcollection
        final detailItemReceiveDocs =
            await detailItemReceiveCollectionRef.get();
        for (var doc in detailItemReceiveDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents within the subcollection, delete the item receive document itself
        await itemReceiveToDeleteRef.delete();

        yield ItemReceiveDeletedState();
      } catch (e) {
        yield ItemReceiveErrorState("Failed to delete Item Receive.");
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
