import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/customer.dart';

// Events
abstract class CustomerEvent {}

class AddCustomerEvent extends CustomerEvent {
  final Customer customer;
  AddCustomerEvent(this.customer);
}

class UpdateCustomerEvent extends CustomerEvent {
  final String customerId;
  final Customer updatedCustomer;
  UpdateCustomerEvent(this.customerId, this.updatedCustomer);
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;
  DeleteCustomerEvent(this.customerId);
}

// States
abstract class CustomerBlocState {}

class LoadingState extends CustomerBlocState {}

class LoadedState extends CustomerBlocState {
  final List<Customer> customers;
  LoadedState(this.customers);
}

class ErrorState extends CustomerBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class CustomerBloc extends Bloc<CustomerEvent, CustomerBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference customersRef;

  CustomerBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    customersRef = _firestore.collection('customers');
  }

  @override
  Stream<CustomerBlocState> mapEventToState(CustomerEvent event) async* {
    if (event is AddCustomerEvent) {
      yield LoadingState();
      try {
        final String nextCustomerId = await _generateNextCustomerId();

        await FirebaseFirestore.instance.collection('customers').add({
          'id': nextCustomerId,
          'nama': event.customer.nama,
          'alamat': event.customer.alamat,
          'nomor_telepon': event.customer.nomorTelepon,
          'nomor_telepon_kantor': event.customer.nomorTeleponKantor,
          'email': event.customer.email,
          'status': event.customer.status,
        });

        yield LoadedState(await _getCustomers());
      } catch (e) {
        yield ErrorState("Gagal menambahkan customer.");
      }
    } else if (event is UpdateCustomerEvent) {
      yield LoadingState();
      try {
        final customerSnapshot = await customersRef.where('id', isEqualTo: event.customerId).get();
        if (customerSnapshot.docs.isNotEmpty) {
          final customerDoc = customerSnapshot.docs.first;
          await customerDoc.reference.update({
            'nama': event.updatedCustomer.nama,
            'alamat': event.updatedCustomer.alamat,
            'nomor_telepon': event.updatedCustomer.nomorTelepon,
            'nomor_telepon_kantor': event.updatedCustomer.nomorTeleponKantor,
            'email': event.updatedCustomer.email,
            'status': event.updatedCustomer.status,
          });
           final customers = await _getCustomers(); // Memuat data pemasok setelah pembaruan
           yield LoadedState(customers);
        } else {
          // Handle jika data pelanggan dengan ID tersebut tidak ditemukan
          yield ErrorState('Data pelanggan dengan ID ${event.customerId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah customer.");
      }
    } else if (event is DeleteCustomerEvent) {
      yield LoadingState();
      try {
        // Cari dokumen dengan 'id' yang sesuai dengan event.mesinId
          QuerySnapshot querySnapshot = await customersRef.where('id', isEqualTo: event.customerId).get();
          
          // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
          for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
            await documentSnapshot.reference.delete();
          }
        yield LoadedState(await _getCustomers());
      } catch (e) {
        yield ErrorState("Gagal menghapus customer.");
      }
    }
  }

Future<String> _generateNextCustomerId() async {
  final QuerySnapshot snapshot = await customersRef.get();
  final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
  int customerCount = 1;

  while (true) {
    final nextCustomerId = 'customer${customerCount.toString().padLeft(3, '0')}';
    if (!existingIds.contains(nextCustomerId)) {
      return nextCustomerId;
    }
    customerCount++;
  }
}

  Future<List<Customer>> _getCustomers() async {
    final QuerySnapshot snapshot = await customersRef.get();
    final List<Customer> customers = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      customers.add(Customer.fromJson(data));
    }
    return customers;
  }
  
}
