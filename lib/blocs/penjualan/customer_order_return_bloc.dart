import 'package:cloud_functions/cloud_functions.dart';
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

class FinishedCustomerOrderReturnEvent extends CustomerOrderReturnEvent {
  final String customerOrderReturnId;
  FinishedCustomerOrderReturnEvent(this.customerOrderReturnId);
}

// States
abstract class CustomerOrderReturnBlocState {}

class CustomerOrderReturnLoadingState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnLoadedState extends CustomerOrderReturnBlocState {
  final CustomerOrderReturn customerOrderReturn;
  CustomerOrderReturnLoadedState(this.customerOrderReturn);
}

class SuccessState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnUpdatedState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnDeletedState extends CustomerOrderReturnBlocState {}

class CustomerOrderReturnErrorState extends CustomerOrderReturnBlocState {
  final String errorMessage;
  CustomerOrderReturnErrorState(this.errorMessage);
}

// BLoC
class CustomerOrderReturnBloc extends Bloc<CustomerOrderReturnEvent, CustomerOrderReturnBlocState> {
  late FirebaseFirestore _firestore;
  final HttpsCallable customerOrderReturnCallable;

  CustomerOrderReturnBloc() : customerOrderReturnCallable = FirebaseFunctions.instance.httpsCallable('customerOrderReturnValidation'), super(CustomerOrderReturnLoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<CustomerOrderReturnBlocState> mapEventToState(CustomerOrderReturnEvent event) async* {
    if (event is AddCustomerOrderReturnEvent) {
      yield CustomerOrderReturnLoadingState();

      final invoiceId = event.customerOrderReturn.invoiceId;
      final products = event.customerOrderReturn.detailCustomerOrderReturnList;

      if(invoiceId.isNotEmpty){
      try {
        final HttpsCallableResult<dynamic> result = await customerOrderReturnCallable.call(<String, dynamic>{
          'products': products.map((product) => product.toJson()).toList(),
          'invoiceId': invoiceId,
          'mode': 'add'
        });

        if (result.data['success'] == true) {
          final nextCustomerOrderReturnId = await _generateNextCustomerOrderReturnId();
          final customerOrderReturnRef = _firestore.collection('customer_order_returns').doc(nextCustomerOrderReturnId);
          final Map<String, dynamic> customerOrderReturnData = {
              'alasan_pengembalian': event.customerOrderReturn.alasanPengembalian,
              'catatan': event.customerOrderReturn.catatan,
              'id': nextCustomerOrderReturnId,
              'invoice_id': invoiceId,
              'status_cor': event.customerOrderReturn.statusCor,
              'status': event.customerOrderReturn.status,
              'tanggal_pengembalian': event.customerOrderReturn.tanggalPengembalian,
            };
            await customerOrderReturnRef.set(customerOrderReturnData);
            final detailCustomerOrderReturnRef = customerOrderReturnRef.collection('detail_customer_order_returns');
            if (event.customerOrderReturn.detailCustomerOrderReturnList.isNotEmpty) {
              int detailCount = 1;
              for (var detailCustomerOrderReturn in event.customerOrderReturn.detailCustomerOrderReturnList) {
                final nextDetailCustomerOrderReturnId = '$nextCustomerOrderReturnId${'D${detailCount.toString().padLeft(3, '0')}'}';
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
          yield SuccessState();
        }else{
          yield CustomerOrderReturnErrorState(result.data['message']);
        }
        } catch (e) {
          yield CustomerOrderReturnErrorState(e.toString());
        }
      }else{
        yield CustomerOrderReturnErrorState("nomor faktur tidak boleh kosong");
      }
    } else if (event is UpdateCustomerOrderReturnEvent) {
      yield CustomerOrderReturnLoadingState();

      final invoiceId = event.customerOrderReturn.invoiceId;
      final products = event.customerOrderReturn.detailCustomerOrderReturnList;

      if(invoiceId.isNotEmpty){
         try {
          final HttpsCallableResult<dynamic> result = await customerOrderReturnCallable.call(<String, dynamic>{
          'products': products.map((product) => product.toJson()).toList(),
          'invoiceId': invoiceId,
          'mode': 'edit'
        });

          if (result.data['success'] == true) {
            final customerOrderReturnToUpdateRef = _firestore.collection('customer_order_returns').doc(event.customerOrderReturnId);
            final Map<String, dynamic> customerOrderReturnData = {
              'alasan_pengembalian': event.customerOrderReturn.alasanPengembalian,
              'catatan': event.customerOrderReturn.catatan,
              'id': event.customerOrderReturnId,
              'invoice_id': event.customerOrderReturn.invoiceId,
              'status_cor': event.customerOrderReturn.statusCor,
              'status': event.customerOrderReturn.status,
              'tanggal_pengembalian': event.customerOrderReturn.tanggalPengembalian,
            };
            await customerOrderReturnToUpdateRef.set(customerOrderReturnData);
            final detailCustomerOrderReturnCollectionRef =
                customerOrderReturnToUpdateRef.collection('detail_customer_order_returns');
            final detailCustomerOrderReturnDocs = await detailCustomerOrderReturnCollectionRef.get();
            for (var doc in detailCustomerOrderReturnDocs.docs) {
              await doc.reference.delete();
            }
            if (event.customerOrderReturn.detailCustomerOrderReturnList.isNotEmpty) {
              int detailCount = 1;
              for (var detailCustomerOrderReturn in event.customerOrderReturn.detailCustomerOrderReturnList) {
                final nextDetailCustomerOrderReturnId = 'D${detailCount.toString().padLeft(3, '0')}';
                final detailId = event.customerOrderReturnId + nextDetailCustomerOrderReturnId;
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
          yield SuccessState();
          }else{
            yield CustomerOrderReturnErrorState(result.data['message']);
          }
        } catch (e) {
          yield CustomerOrderReturnErrorState(e.toString());
        }
      }else{
        yield CustomerOrderReturnErrorState("nomor faktur tidak boleh kosong");
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
    }else if(event is FinishedCustomerOrderReturnEvent){
      yield CustomerOrderReturnLoadingState();
      try {
       
        final customerOrderReturnRef = _firestore.collection('customer_order_returns').doc(event.customerOrderReturnId);

        await customerOrderReturnRef.update({
          'status_cor': 'Selesai',
        });

        yield SuccessState();
      } catch (e) {
        yield CustomerOrderReturnErrorState("Failed to finsihed customer order return");
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
