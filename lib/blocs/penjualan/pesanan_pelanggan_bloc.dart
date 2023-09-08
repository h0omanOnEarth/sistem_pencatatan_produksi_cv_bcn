import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/pesanan_pelanggan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Events
abstract class CustomerOrderEvent {}

class AddCustomerOrderEvent extends CustomerOrderEvent {
  final CustomerOrder customerOrder;
  AddCustomerOrderEvent(this.customerOrder);
}

// States
abstract class CustomerOrderBlocState {}

class LoadingState extends CustomerOrderBlocState {}

class LoadedState extends CustomerOrderBlocState {
  final CustomerOrder customerOrder;
  LoadedState(this.customerOrder);
}

class ErrorState extends CustomerOrderBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class CustomerOrderBloc extends Bloc<CustomerOrderEvent, CustomerOrderBlocState> {
  late FirebaseFirestore _firestore;

  CustomerOrderBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
  }

  @override
  Stream<CustomerOrderBlocState> mapEventToState(CustomerOrderEvent event) async* {
    if (event is AddCustomerOrderEvent) {
      yield LoadingState();
      try {
        // Tambahkan customer order ke Firestore
        await _firestore.collection('customer_orders').add(event.customerOrder.toJson());

        // Setelah menambahkan customer order, buat detail customer order jika ada
        if (event.customerOrder.detailCustomerOrderList.isNotEmpty) {
          for (var detailCustomerOrder in event.customerOrder.detailCustomerOrderList) {
            await _firestore.collection('detail_customer_order').add(detailCustomerOrder.toJson());
          }
        }

        yield LoadedState(event.customerOrder);
      } catch (e) {
        yield ErrorState("Gagal menambahkan Customer Order.");
      }
    }
  }
}
