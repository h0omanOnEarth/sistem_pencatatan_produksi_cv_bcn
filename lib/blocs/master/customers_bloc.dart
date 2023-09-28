import 'package:cloud_functions/cloud_functions.dart';
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

class SuccessState extends CustomerBlocState {}

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

      final nama = event.customer.nama;
      final alamat =  event.customer.alamat;
      final noTelepon = event.customer.nomorTelepon;
      final noTeleponKantor = event.customer.nomorTeleponKantor;
      final email = event.customer.email;
      final status = event.customer.status;

      if(nama.isNotEmpty && alamat.isNotEmpty && noTelepon.isNotEmpty && noTeleponKantor.isNotEmpty && email.isNotEmpty){
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('supplierAdd');
            final HttpsCallableResult<dynamic> result =
            await callable.call(<String, dynamic>{
              'telp': noTelepon,
              'telpKantor': noTeleponKantor,
              'email': email
            });

            if (result.data['success'] == true) {
              final String nextCustomerId = await _generateNextCustomerId();

              await FirebaseFirestore.instance.collection('customers').add({
                'id': nextCustomerId,
                'nama': nama,
                'alamat': alamat,
                'nomor_telepon': noTelepon,
                'nomor_telepon_kantor': noTeleponKantor,
                'email': email,
                'status': status,
              });

              yield LoadingState();
              yield SuccessState();
            }else{
              yield ErrorState(result.data['message']);
            }
           
          } catch (e) {
            yield ErrorState("Gagal menambahkan customer.");
          }
      }else{
        yield ErrorState("Harap isi semua field!");
      }
   
    } else if (event is UpdateCustomerEvent) {
      yield LoadingState();
      final customerSnapshot = await customersRef.where('id', isEqualTo: event.customerId).get();
        if (customerSnapshot.docs.isNotEmpty) {
          final nama = event.updatedCustomer.nama;
          final alamat =  event.updatedCustomer.alamat;
          final noTelepon = event.updatedCustomer.nomorTelepon;
          final noTeleponKantor = event.updatedCustomer.nomorTeleponKantor;
          final email = event.updatedCustomer.email;
          final status = event.updatedCustomer.status;

          if(nama.isNotEmpty && alamat.isNotEmpty && noTelepon.isNotEmpty && noTeleponKantor.isNotEmpty && email.isNotEmpty){
            try {
               final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('supplierAdd');
                final HttpsCallableResult<dynamic> result =
                await callable.call(<String, dynamic>{
                  'telp': noTelepon,
                  'telpKantor': noTeleponKantor,
                  'email': email
                });

                if (result.data['success'] == true) {
                  final customerDoc = customerSnapshot.docs.first;
                  await customerDoc.reference.update({
                    'nama': nama,
                    'alamat': alamat,
                    'nomor_telepon': noTelepon,
                    'nomor_telepon_kantor': noTeleponKantor,
                    'email': email,
                    'status': status,
                  });
                  yield LoadingState();
                  yield SuccessState();
                }else{
                  yield ErrorState(result.data['message']);
                }
            } catch (e) {
              yield ErrorState(e.toString());
            }
           }else{
            yield ErrorState("Harap isi semua field!");
           }
        }else {
          // Handle jika data pelanggan dengan ID tersebut tidak ditemukan
          yield ErrorState('Data pelanggan dengan ID ${event.customerId} tidak ditemukan.');
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
