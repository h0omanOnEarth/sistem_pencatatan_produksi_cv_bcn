import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/produksi/dloh.dart';

// Events
abstract class DLOHEvent {}

class AddDLOHEvent extends DLOHEvent {
  final DLOH dloh;
  AddDLOHEvent(this.dloh);
}

class UpdateDLOHEvent extends DLOHEvent {
  final String dlohId;
  final DLOH updatedDLOH;
  UpdateDLOHEvent(this.dlohId, this.updatedDLOH);
}

class DeleteDLOHEvent extends DLOHEvent {
  final String dlohId;
  DeleteDLOHEvent(this.dlohId);
}

// States
abstract class DLOHBlocState {}

class LoadingState extends DLOHBlocState {}

class LoadedState extends DLOHBlocState {
  final List<DLOH> dlohList;
  LoadedState(this.dlohList);
}

class ErrorState extends DLOHBlocState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class DLOHBloc extends Bloc<DLOHEvent, DLOHBlocState> {
  late FirebaseFirestore _firestore;
  late CollectionReference dlohRef;

  DLOHBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    dlohRef = _firestore.collection('direct_labor_overhead_costs');
  }

  @override
  Stream<DLOHBlocState> mapEventToState(DLOHEvent event) async* {
    if (event is AddDLOHEvent) {
      yield LoadingState();
      try {
        final String nextDLOHId = await _generateNextDLOHId();
         final DLOHRef = _firestore.collection('direct_labor_overhead_costs').doc(nextDLOHId);

          final Map<String, dynamic> dlohData = {
          'id': nextDLOHId,
          'material_usage_id': event.dloh.materialUsageId,
          'catatan': event.dloh.catatan,
          'status': event.dloh.status,
          'jumlah_tenaga_kerja': event.dloh.jumlahTenagaKerja,
          'jumlah_jam_tenaga_kerja': event.dloh.jumlahJamTenagaKerja,
          'biaya_tenaga_kerja': event.dloh.biayaTenagaKerja,
          'biaya_overhead': event.dloh.biayaOverhead,
          'upah_tenaga_kerja_perjam': event.dloh.upahTenagaKerjaPerjam,
          'subtotal': event.dloh.subtotal,
          'tanggal_pencatatan': event.dloh.tanggalPencatatan,
        };

        // Add the material request data to Firestore
        await DLOHRef.set(dlohData);

        yield LoadedState(await _getDLOHList());
      } catch (e) {
        yield ErrorState("Gagal menambahkan DLOH.");
      }
    } else if (event is UpdateDLOHEvent) {
      yield LoadingState();
      try {
        final dlohSnapshot = await dlohRef.where('id', isEqualTo: event.dlohId).get();
        if (dlohSnapshot.docs.isNotEmpty) {
          final dlohDoc = dlohSnapshot.docs.first;
          await dlohDoc.reference.update({
            'material_usage_id': event.updatedDLOH.materialUsageId,
            'catatan': event.updatedDLOH.catatan,
            'status': event.updatedDLOH.status,
            'jumlah_tenaga_kerja': event.updatedDLOH.jumlahTenagaKerja,
            'jumlah_jam_tenaga_kerja': event.updatedDLOH.jumlahJamTenagaKerja,
            'biaya_tenaga_kerja': event.updatedDLOH.biayaTenagaKerja,
            'biaya_overhead': event.updatedDLOH.biayaOverhead,
            'upah_tenaga_kerja_perjam': event.updatedDLOH.upahTenagaKerjaPerjam,
            'subtotal': event.updatedDLOH.subtotal,
            'tanggal_pencatatan': event.updatedDLOH.tanggalPencatatan,
          });
          final dlohList = await _getDLOHList(); 
          yield LoadedState(dlohList);
        } else {
          yield ErrorState('Data DLOH dengan ID ${event.dlohId} tidak ditemukan.');
        }
      } catch (e) {
        yield ErrorState("Gagal mengubah DLOH.");
      }
    } else if (event is DeleteDLOHEvent) {
      yield LoadingState();
      try {
        // Cari dokumen dengan 'id' yang sesuai dengan event.dlohId
        final QuerySnapshot querySnapshot = await dlohRef.where('id', isEqualTo: event.dlohId).get();
          
        // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
        for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.delete();
        }
        final dlohList = await _getDLOHList(); 
        yield LoadedState(dlohList);
      } catch (e) {
        yield ErrorState("Gagal menghapus DLOH.");
      }
    }
  }

  Future<String> _generateNextDLOHId() async {
    final QuerySnapshot snapshot = await dlohRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int dlohCount = 1;

    while (true) {
      final nextDLOHId = 'DLOH${dlohCount.toString().padLeft(5, '0')}';
      if (!existingIds.contains(nextDLOHId)) {
        return nextDLOHId;
      }
      dlohCount++;
    }
  }

  Future<List<DLOH>> _getDLOHList() async {
    final QuerySnapshot snapshot = await dlohRef.get();
    final List<DLOH> dlohList = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      dlohList.add(DLOH.fromMap(data));
    }
    return dlohList;
  }
}
