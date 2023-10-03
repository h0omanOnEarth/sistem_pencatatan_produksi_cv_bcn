import 'package:cloud_functions/cloud_functions.dart';
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

class SuccessState extends DLOHBlocState {}

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
  final HttpsCallable dlohValidationCallable;

  DLOHBloc() : dlohValidationCallable = FirebaseFunctions.instance.httpsCallable('dlohValidation'), super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    dlohRef = _firestore.collection('direct_labor_overhead_costs');
  }

  @override
  Stream<DLOHBlocState> mapEventToState(DLOHEvent event) async* {
    if (event is AddDLOHEvent) {
      yield LoadingState();
      
      final materialUsageId = event.dloh.materialUsageId;
      final catatan = event.dloh.catatan;
      final status = event.dloh.status;
      final jumlahTenagaKerja = event.dloh.jumlahTenagaKerja;
      final jumlahJamTenagaKerja = event.dloh.jumlahJamTenagaKerja;
      final biayaTenagaKerja = event.dloh.biayaTenagaKerja;
      final biayaOverhead = event.dloh.biayaOverhead;
      final upahTenagaKerjaPerjam = event.dloh.upahTenagaKerjaPerjam;
      final subtotal = event.dloh.subtotal;
      final tanggalPencatatan = event.dloh.tanggalPencatatan;

      if(materialUsageId.isNotEmpty){
         try {
          final HttpsCallableResult<dynamic> result = await dlohValidationCallable.call(<String, dynamic>{
           'jumlahTenagaKerja': jumlahTenagaKerja,
           'jumlahJamTenagaKerja': jumlahJamTenagaKerja,
           'biayaTenagaKerja': biayaTenagaKerja,
           'upahTenagaKerjaPerjam': upahTenagaKerjaPerjam,
           'subtotal': subtotal
          });

          if (result.data['success'] == true) {
            final String nextDLOHId = await _generateNextDLOHId();
            final DLOHRef = _firestore.collection('direct_labor_overhead_costs').doc(nextDLOHId);

              final Map<String, dynamic> dlohData = {
              'id': nextDLOHId,
              'material_usage_id': materialUsageId,
              'catatan': catatan,
              'status': status,
              'jumlah_tenaga_kerja': jumlahTenagaKerja,
              'jumlah_jam_tenaga_kerja': jumlahJamTenagaKerja,
              'biaya_tenaga_kerja': biayaTenagaKerja,
              'biaya_overhead': biayaOverhead,
              'upah_tenaga_kerja_perjam': upahTenagaKerjaPerjam,
              'subtotal': subtotal,
              'tanggal_pencatatan': tanggalPencatatan,
            };

            // Add the material request data to Firestore
            await DLOHRef.set(dlohData);
            yield SuccessState();
          }else{
            yield ErrorState(result.data['message']);
          }
      } catch (e) {
        yield ErrorState(e.toString());
      }
      }else{
        yield ErrorState("nomor penggunaan bahan tidak boleh kosong");
      }
    } else if (event is UpdateDLOHEvent) {
      yield LoadingState();

      final materialUsageId = event.updatedDLOH.materialUsageId;
      final catatan = event.updatedDLOH.catatan;
      final status = event.updatedDLOH.status;
      final jumlahTenagaKerja = event.updatedDLOH.jumlahTenagaKerja;
      final jumlahJamTenagaKerja = event.updatedDLOH.jumlahJamTenagaKerja;
      final biayaTenagaKerja = event.updatedDLOH.biayaTenagaKerja;
      final biayaOverhead = event.updatedDLOH.biayaOverhead;
      final upahTenagaKerjaPerjam = event.updatedDLOH.upahTenagaKerjaPerjam;
      final subtotal = event.updatedDLOH.subtotal;
      final tanggalPencatatan = event.updatedDLOH.tanggalPencatatan;

      if(materialUsageId.isNotEmpty){
        try {
           final HttpsCallableResult<dynamic> result = await dlohValidationCallable.call(<String, dynamic>{
           'jumlahTenagaKerja': jumlahTenagaKerja,
           'jumlahJamTenagaKerja': jumlahJamTenagaKerja,
           'biayaTenagaKerja': biayaTenagaKerja,
           'upahTenagaKerjaPerjam': upahTenagaKerjaPerjam,
           'subtotal': subtotal
          });

          if (result.data['success'] == true) {
            final dlohSnapshot = await dlohRef.where('id', isEqualTo: event.dlohId).get();
            if (dlohSnapshot.docs.isNotEmpty) {
              final dlohDoc = dlohSnapshot.docs.first;
              await dlohDoc.reference.update({
                'material_usage_id': materialUsageId,
                'catatan': catatan,
                'status': status,
                'jumlah_tenaga_kerja': jumlahTenagaKerja,
                'jumlah_jam_tenaga_kerja': jumlahJamTenagaKerja,
                'biaya_tenaga_kerja': biayaTenagaKerja,
                'biaya_overhead': biayaOverhead,
                'upah_tenaga_kerja_perjam': upahTenagaKerjaPerjam,
                'subtotal': subtotal,
                'tanggal_pencatatan': tanggalPencatatan,
              });
              yield SuccessState();
            } else {
              yield ErrorState('Data DLOH dengan ID ${event.dlohId} tidak ditemukan.');
            }
          }else{
            yield ErrorState(result.data['message']);
          }
        } catch (e) {
          yield ErrorState(e.toString());
        }
      }else{
        yield ErrorState("nomor penggunaan bahan tidak boleh kosong");
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
