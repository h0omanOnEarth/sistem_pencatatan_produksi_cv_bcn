import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/supplier.dart';

// Events
abstract class SupplierEvent {}

class SelectSupplierEvent extends SupplierEvent {
  final String supplierId;
  SelectSupplierEvent(this.supplierId);
}

class AddSupplierEvent extends SupplierEvent {
  final Supplier supplier;
  AddSupplierEvent(this.supplier);
}

class UpdateSupplierEvent extends SupplierEvent {
  final String supplierId;
  final Supplier updatedSupplier;
  UpdateSupplierEvent(this.supplierId, this.updatedSupplier);
}

class DeleteSupplierEvent extends SupplierEvent {
  final String supplierId;
  DeleteSupplierEvent(this.supplierId);
}

class LoadSuppliersEvent extends SupplierEvent {}

// States
abstract class SupplierState {}

abstract class EmployeeState {}

class SuccessState extends SupplierState {}

class LoadingState extends SupplierState {}

class LoadedState extends SupplierState {
  final List<Supplier> suppliers;
  LoadedState(this.suppliers);
}

class ErrorState extends SupplierState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

class SupplierSelectionState extends SupplierState {
  final String selectedSupplierId;
  SupplierSelectionState(this.selectedSupplierId);
}

// BLoC
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  late FirebaseFirestore _firestore;
  late CollectionReference suppliersRef;

  String _selectedSupplierId = ""; // Simpan ID supplier yang dipilih

  SupplierBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    suppliersRef = _firestore.collection('suppliers');
    // Panggil _loadSuppliers saat konstruktor dipanggil
    _loadSuppliers();
  }

  void _loadSuppliers() {
    add(LoadSuppliersEvent()); // Tambahkan event untuk memuat data pemasok
  }

  @override
  Stream<SupplierState> mapEventToState(SupplierEvent event) async* {
    if (event is LoadSuppliersEvent) {
      yield LoadingState();
      try {
        final suppliers = await _getSuppliers();
        yield LoadedState(suppliers);
      } catch (e) {
        yield ErrorState("Gagal memuat data pemasok.");
      }
    }

    if (event is SelectSupplierEvent) {
      _selectedSupplierId = event.supplierId;
      yield SupplierSelectionState(_selectedSupplierId);
    }

    if (event is AddSupplierEvent) {
      yield LoadingState();

      final alamat = event.supplier.alamat;
      final email = event.supplier.email;
      final jenisSupplier = event.supplier.jenisSupplier;
      final nama = event.supplier.nama;
      final noTelp = event.supplier.noTelepon;
      final noTelpKantor = event.supplier.noTeleponKantor;
      final status = event.supplier.status;

      if (alamat.isNotEmpty &&
          email.isNotEmpty &&
          jenisSupplier.isNotEmpty &&
          nama.isNotEmpty &&
          noTelp.isNotEmpty &&
          noTelpKantor.isNotEmpty) {
        try {
          final HttpsCallable callable =
              FirebaseFunctions.instanceFor(region: "asia-southeast2")
                  .httpsCallable('supplierAdd');
          final HttpsCallableResult<dynamic> result = await callable
              .call(<String, dynamic>{
            'telp': noTelp,
            'telpKantor': noTelpKantor,
            'email': email
          });

          if (result.data['success'] == true) {
            final String nextSupplierId = await _generateNextSupplierId();

            await FirebaseFirestore.instance.collection('suppliers').add({
              'id': nextSupplierId,
              'alamat': alamat,
              'email': email,
              'jenis_supplier': jenisSupplier,
              'nama': nama,
              'no_telepon': noTelp,
              'no_telepon_kantor': noTelpKantor,
              'status': status
            });

            yield SuccessState();
          } else {
            yield ErrorState(result.data['message']);
          }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      } else {
        yield ErrorState("Harap isi semua field!");
      }
    } else if (event is UpdateSupplierEvent) {
      yield LoadingState();

      final supplierSnapshot =
          await suppliersRef.where('id', isEqualTo: event.supplierId).get();
      if (supplierSnapshot.docs.isNotEmpty) {
        final alamat = event.updatedSupplier.alamat;
        final email = event.updatedSupplier.email;
        final jenisSupplier = event.updatedSupplier.jenisSupplier;
        final nama = event.updatedSupplier.nama;
        final noTelp = event.updatedSupplier.noTelepon;
        final noTelpKantor = event.updatedSupplier.noTeleponKantor;
        final status = event.updatedSupplier.status;

        if (alamat.isNotEmpty &&
            email.isNotEmpty &&
            jenisSupplier.isNotEmpty &&
            nama.isNotEmpty &&
            noTelp.isNotEmpty &&
            noTelpKantor.isNotEmpty) {
          try {
            final HttpsCallable callable =
                FirebaseFunctions.instanceFor(region: "asia-southeast2")
                    .httpsCallable('supplierAdd');
            final HttpsCallableResult<dynamic> result = await callable
                .call(<String, dynamic>{
              'telp': noTelp,
              'telpKantor': noTelpKantor,
              'email': email
            });

            if (result.data['success'] == true) {
              final supplierDoc = supplierSnapshot.docs.first;
              await supplierDoc.reference.update({
                'alamat': alamat,
                'email': email,
                'jenis_supplier': jenisSupplier,
                'nama': nama,
                'no_telepon': noTelp,
                'no_telepon_kantor': noTelpKantor,
                'status': status
              });

              yield SuccessState();
            } else {
              yield ErrorState(result.data['message']);
            }
          } catch (e) {
            yield ErrorState("Gagal mengupdate supplier.");
          }
        } else {
          yield ErrorState("Harap isi semua field");
        }
      } else {
        // Handle jika data pelanggan dengan ID tersebut tidak ditemukan
        yield ErrorState(
            'Data produk dengan ID ${event.supplierId} tidak ditemukan.');
      }
    } else if (event is DeleteSupplierEvent) {
      yield LoadingState();
      try {
        QuerySnapshot querySnapshot =
            await suppliersRef.where('id', isEqualTo: event.supplierId).get();

        // Perbarui status dokumen menjadi 0 daripada menghapus
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.update({'status': 0});
        }

        yield LoadedState(await _getSuppliers());
      } catch (e) {
        yield ErrorState("Gagal menghapus supplier.");
      }
    }
  }

  Future<String> _generateNextSupplierId() async {
    final QuerySnapshot snapshot = await suppliersRef.get();
    final int supplierCount = snapshot.docs.length;
    final String nextSupplierId =
        'supplier${(supplierCount + 1).toString().padLeft(3, '0')}';
    return nextSupplierId;
  }

  Future<List<Supplier>> _getSuppliers() async {
    final QuerySnapshot snapshot = await suppliersRef.get();
    final List<Supplier> suppliers = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      suppliers.add(Supplier.fromJson(data));
    }
    return suppliers;
  }

  String get selectedSupplierId => _selectedSupplierId;
}
