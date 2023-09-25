import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/customer_order_return.dart';

// Events
abstract class CustomerOrderReturnEvent {}

class AddCustomerOrderReturnEvent extends CustomerOrderReturnEvent {
  final CustomerOrderReturn customerOrderReturn;
  AddCustomerOrderReturnEvent(this.customerOrderReturn);
}

class UpdateCustomerOrderReturnEvent extends CustomerOrderReturnEvent {
  final String customerOrderReturnId;
  final CustomerOrderReturn customerOrderReturn;
  UpdateCustomerOrderReturnEvent(this.customerOrderReturnId, this.customerOrderReturn);
}

class DeleteCustomerOrderReturnEvent extends CustomerOrderReturnEvent {
  final String customerOrderReturnId;
  DeleteCustomerOrderReturnEvent(this.customerOrderReturnId);
}

// States
abstract class CustomerOrderReturnBlocState {}

class CustomerOrderReturnLoadingState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnLoadedState extends CustomerOrderReturnBlocState {
  final CustomerOrderReturn customerOrderReturn;
  CustomerOrderReturnLoadedState(this.customerOrderReturn);
}

class CustomerOrderReturnUpdatedState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnDeletedState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnErrorState extends CustomerOrderReturnBlocState {
  final String errorMessage;
  CustomerOrderReturnErrorState(this.errorMessage);
}

// BLoC
class CustomerOrderReturnBloc extends Bloc<CustomerOrderReturnEvent, CustomerOrderReturnBlocState> {
  late FirebaseFirestore _firestore;

  CustomerOrderReturnBloc() : super(CustomerOrderReturnLoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<CustomerOrderReturnBlocState> mapEventToState(CustomerOrderReturnEvent event) async* {
    if (event is AddCustomerOrderReturnEvent) {
      yield CustomerOrderReturnLoadingState();
      try {
        // Generate a new customer order return ID (or use an existing one if you have it)
        final nextCustomerOrderReturnId = await _generateNextCustomerOrderReturnId();

        // Create a reference to the customer order return document using the appropriate ID
        final customerOrderReturnRef = _firestore.collection('customer_order_returns').doc(nextCustomerOrderReturnId);

        // Set customer order return data
        final Map<String, dynamic> customerOrderReturnData = {
          'alasan_pengembalian': event.customerOrderReturn.alasanPengembalian,
          'catatan': event.customerOrderReturn.catatan,
          'id': nextCustomerOrderReturnId,
          'invoice_id': event.customerOrderReturn.invoiceId,
          'status_cor': event.customerOrderReturn.statusCor,
          'status': event.customerOrderReturn.status,
          'tanggal_pengembalian': event.customerOrderReturn.tanggalPengembalian,
        };

        // Add customer order return data to Firestore
        await customerOrderReturnRef.set(customerOrderReturnData);

        // Create a reference to the subcollection 'detail_customer_order_returns' within the customer order return document
        final detailCustomerOrderReturnRef = customerOrderReturnRef.collection('detail_customer_order_returns');

        if (event.customerOrderReturn.detailCustomerOrderReturnList.isNotEmpty) {
          int detailCount = 1;
          for (var detailCustomerOrderReturn in event.customerOrderReturn.detailCustomerOrderReturnList) {
            final nextDetailCustomerOrderReturnId = '$nextCustomerOrderReturnId${'D${detailCount.toString().padLeft(3, '0')}'}';

            // Add detail customer order return document to the 'detail_customer_order_returns' collection
            await detailCustomerOrderReturnRef.doc(nextDetailCustomerOrderReturnId).set({
              'id': nextDetailCustomerOrderReturnId,
              'customer_order_return_id': nextCustomerOrderReturnId,
              'jumlah_pengembalian': detailCustomerOrderReturn.jumlahPengembalian,
              'jumlah_pesanan': detailCustomerOrderReturn.jumlahPesanan,
              'product_id': detailCustomerOrderReturn.productId,
              'status': detailCustomerOrderReturn.status,
            });
            detailCount++;
          }
        }

        yield CustomerOrderReturnLoadedState(event.customerOrderReturn);
      } catch (e) {
        yield CustomerOrderReturnErrorState("Failed to add Customer Order Return.");
      }
    } else if (event is UpdateCustomerOrderReturnEvent) {
      yield CustomerOrderReturnLoadingState();
      try {
        // Get a reference to the customer order return document to be updated
        final customerOrderReturnToUpdateRef =
            _firestore.collection('customer_order_returns').doc(event.customerOrderReturnId);

        // Set new customer order return data
        final Map<String, dynamic> customerOrderReturnData = {
          'alasan_pengembalian': event.customerOrderReturn.alasanPengembalian,
          'catatan': event.customerOrderReturn.catatan,
          'id': event.customerOrderReturnId,
          'invoice_id': event.customerOrderReturn.invoiceId,
          'status_cor': event.customerOrderReturn.statusCor,
          'status': event.customerOrderReturn.status,
          'tanggal_pengembalian': event.customerOrderReturn.tanggalPengembalian,
        };

        // Update the customer order return data in the existing document
        await customerOrderReturnToUpdateRef.set(customerOrderReturnData);

        // Delete all documents in the 'detail_customer_order_returns' subcollection first
        final detailCustomerOrderReturnCollectionRef =
            customerOrderReturnToUpdateRef.collection('detail_customer_order_returns');
        final detailCustomerOrderReturnDocs = await detailCustomerOrderReturnCollectionRef.get();
        for (var doc in detailCustomerOrderReturnDocs.docs) {
          await doc.reference.delete();
        }

        // Add new detail customer order return documents to the 'detail_customer_order_returns' subcollection
        if (event.customerOrderReturn.detailCustomerOrderReturnList.isNotEmpty) {
          int detailCount = 1;
          for (var detailCustomerOrderReturn in event.customerOrderReturn.detailCustomerOrderReturnList) {
            final nextDetailCustomerOrderReturnId = 'D${detailCount.toString().padLeft(3, '0')}';
            final detailId = event.customerOrderReturnId + nextDetailCustomerOrderReturnId;

            // Add detail customer order return document to the 'detail_customer_order_returns' collection
            await detailCustomerOrderReturnCollectionRef.doc(detailId).set({
              'id': detailId,
              'customer_order_return_id': detailCustomerOrderReturn.customerOrderReturnId,
              'jumlah_pengembalian': detailCustomerOrderReturn.jumlahPengembalian,
              'jumlah_pesanan': detailCustomerOrderReturn.jumlahPesanan,
              'product_id': detailCustomerOrderReturn.productId,
              'status': detailCustomerOrderReturn.status,
            });
            detailCount++;
          }
        }

        yield CustomerOrderReturnUpdatedState();
      } catch (e) {
        yield CustomerOrderReturnErrorState("Failed to update Customer Order Return.");
      }
    } else if (event is DeleteCustomerOrderReturnEvent) {
      yield CustomerOrderReturnLoadingState();
      try {
        // Get a reference to the customer order return document to be deleted
        final customerOrderReturnToDeleteRef =
            _firestore.collection('customer_order_returns').doc(event.customerOrderReturnId);

        // Get a reference to the 'detail_customer_order_returns' subcollection within the customer order return document
        final detailCustomerOrderReturnCollectionRef =
            customerOrderReturnToDeleteRef.collection('detail_customer_order_returns');

        // Delete all documents in the 'detail_customer_order_returns' subcollection
        final detailCustomerOrderReturnDocs = await detailCustomerOrderReturnCollectionRef.get();
        for (var doc in detailCustomerOrderReturnDocs.docs) {
          await doc.reference.delete();
        }

        // After deleting all documents in the subcollection, delete the customer order return document itself
        await customerOrderReturnToDeleteRef.delete();

        yield CustomerOrderReturnDeletedState();
      } catch (e) {
        yield CustomerOrderReturnErrorState("Failed to delete Customer Order Return.");
      }
    }
  }

  Future<String> _generateNextCustomerOrderReturnId() async {
    final customerOrderReturnsRef = _firestore.collection('customer_order_returns');
    final QuerySnapshot snapshot = await customerOrderReturnsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int customerOrderReturnCount = 1;

    while (true) {
      final nextCustomerOrderReturnId = 'COR${customerOrderReturnCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextCustomerOrderReturnId)) {
        return nextCustomerOrderReturnId;
      }
      customerOrderReturnCount++;
    }
  }
}
