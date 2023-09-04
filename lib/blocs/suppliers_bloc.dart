import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/supplier.dart';

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
      try {
        final String nextSupplierId = await _generateNextSupplierId();

        await FirebaseFirestore.instance.collection('suppliers').add({
          'id': nextSupplierId,
          'alamat': event.supplier.alamat,
          'email': event.supplier.email,
          'jenis_supplier': event.supplier.jenisSupplier,
          'nama': event.supplier.nama,
          'no_telepon': event.supplier.noTelepon,
          'no_telepon_kantor': event.supplier.noTeleponKantor,
        });

        yield LoadedState(await _getSuppliers());
      } catch (e) {
        yield ErrorState("Gagal menambahkan supplier.");
      }
    } else if (event is UpdateSupplierEvent) {
      yield LoadingState();
      try {
        await suppliersRef.doc(event.supplierId).update({
          'alamat': event.updatedSupplier.alamat,
          'email': event.updatedSupplier.email,
          'jenis_supplier': event.updatedSupplier.jenisSupplier,
          'nama': event.updatedSupplier.nama,
          'no_telepon': event.updatedSupplier.noTelepon,
          'no_telepon_kantor': event.updatedSupplier.noTeleponKantor,
        });

        yield LoadedState(await _getSuppliers());
      } catch (e) {
        yield ErrorState("Gagal mengupdate supplier.");
      }
    } else if (event is DeleteSupplierEvent) {
      yield LoadingState();
      try {
        await suppliersRef.doc(event.supplierId).delete();
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
