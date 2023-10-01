import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/machine.dart';

// Events
abstract class MesinEvent {}

class AddMesinEvent extends MesinEvent {
  final Mesin mesin;
  AddMesinEvent(this.mesin);
}

class UpdateMesinEvent extends MesinEvent {
  final String mesinId;
  final Mesin updatedMesin;
  UpdateMesinEvent(this.mesinId, this.updatedMesin);
}

class DeleteMesinEvent extends MesinEvent {
  final String mesinId;
  DeleteMesinEvent(this.mesinId);
}

// States
abstract class MesinState {}

class LoadingState extends MesinState {}

class SuccessState extends MesinState {}

class LoadedState extends MesinState {
  final List<Mesin> mesins;
  LoadedState(this.mesins);
}

class ErrorState extends MesinState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class MesinBloc extends Bloc<MesinEvent, MesinState> {
  late FirebaseFirestore _firestore;
  late CollectionReference mesinsRef;

  MesinBloc() : super(LoadingState()){
    _firestore = FirebaseFirestore.instance;
    mesinsRef = _firestore.collection('machines');
  }

  @override
  Stream<MesinState> mapEventToState(MesinEvent event) async* {
    if (event is AddMesinEvent) {
      yield LoadingState();

       final kapasitasProduksi = event.mesin.kapasitasProduksi;
       final keterangan = event.mesin.keterangan;
       final kondisi = event.mesin.kondisi;
       final nama = event.mesin.nama;
       final nomorSeri = event.mesin.nomorSeri;
       final satuan = event.mesin.satuan;
       final status = event.mesin.status;
       final supplierId = event.mesin.supplierId;
       final tahunPembuatan = event.mesin.tahunPembuatan;
       final tahunPerolehan = event.mesin.tahunPerolehan;
       final tipe = event.mesin.tipe;

       if(nama.isNotEmpty){
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('mesinValidation');
            final HttpsCallableResult<dynamic> result =
            await callable.call(<String, dynamic>{
              'nama':nama,
              'kapasitasProduksi': kapasitasProduksi,
              'nomorSeri': nomorSeri,
              'tahunDapat': tahunPembuatan,
              'tahunProduksi': tahunPembuatan,
              'supplier': supplierId
            });

             if (result.data['success'] == true) {
                final String nextMesinId = await _generateNextMesinId();
                await FirebaseFirestore.instance
                    .collection('machines')
                    .add({
                        'id': nextMesinId,
                        'kapasitas_produksi': kapasitasProduksi,
                        'keterangan': keterangan,
                        'kondisi': kondisi,
                        'nama': nama,
                        'nomor_seri': nomorSeri,
                        'satuan': satuan,
                        'status': status,
                        'supplier_id': supplierId,
                        'tahun_pembuatan': tahunPembuatan,
                        'tahun_perolehan': tahunPerolehan,
                        'tipe': tipe,
                });

                yield SuccessState();

             }else{
              yield ErrorState(result.data['message']);
             }

          } catch (e) {
            yield ErrorState(e.toString());
          }
       }else{
        yield ErrorState("Nama wajib diisi");
       }
    } else if (event is UpdateMesinEvent) {
      yield LoadingState();
      final mesinSnapshot = await mesinsRef.where('id', isEqualTo: event.mesinId).get();
      if (mesinSnapshot.docs.isNotEmpty) {
        
       final kapasitasProduksi = event.updatedMesin.kapasitasProduksi;
       final keterangan = event.updatedMesin.keterangan;
       final kondisi = event.updatedMesin.kondisi;
       final nama = event.updatedMesin.nama;
       final nomorSeri = event.updatedMesin.nomorSeri;
       final satuan = event.updatedMesin.satuan;
       final status = event.updatedMesin.status;
       final supplierId = event.updatedMesin.supplierId;
       final tahunPembuatan = event.updatedMesin.tahunPembuatan;
       final tahunPerolehan = event.updatedMesin.tahunPerolehan;
       final tipe = event.updatedMesin.tipe;

       if(nama.isNotEmpty){
          try {
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('mesinValidation');
            final HttpsCallableResult<dynamic> result =
            await callable.call(<String, dynamic>{
              'nama':nama,
              'kapasitasProduksi': kapasitasProduksi,
              'nomorSeri': nomorSeri,
              'tahunDapat': tahunPembuatan,
              'tahunProduksi': tahunPembuatan,
              'supplier': supplierId
            });

             if (result.data['success'] == true) {
                final mesinDoc = mesinSnapshot.docs.first;
                await mesinDoc.reference.update({
                  'kapasitas_produksi': kapasitasProduksi,
                  'keterangan': keterangan,
                  'kondisi': kondisi,
                  'nama': nama,
                  'nomor_seri': nomorSeri,
                  'satuan': satuan,
                  'status': status,
                  'supplier_id': supplierId,
                  'tahun_pembuatan': tahunPembuatan,
                  'tahun_perolehan': tahunPerolehan,
                  'tipe': tipe,
                });
                
                yield SuccessState();
             }else{
               yield ErrorState(result.data['message']);
             }

        } catch (e) {
          yield ErrorState(e.toString());
        }
       }else{
          yield ErrorState("Nama wajib diisi");
       }

      }else {
        // Handle jika data pelanggan dengan ID tersebut tidak ditemukan
        yield ErrorState('Data mesin dengan ID ${event.mesinId} tidak ditemukan.');
      }

    } else if (event is DeleteMesinEvent) {
      yield LoadingState();
      try {
        // Cari dokumen dengan 'id' yang sesuai dengan event.mesinId
          QuerySnapshot querySnapshot = await mesinsRef.where('id', isEqualTo: event.mesinId).get();
          
          // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
          for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
            await documentSnapshot.reference.delete();
          }
        yield LoadedState(await _getMesins());
      } catch (e) {
        yield ErrorState("Gagal menghapus mesin.");
      }
    }
  }

  Future<String> _generateNextMesinId() async {
    final QuerySnapshot snapshot = await mesinsRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int customerCount = 1;

    while (true) {
      final nextCustomerId = 'mesin${customerCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextCustomerId)) {
        return nextCustomerId;
      }
      customerCount++;
    }
  }

  Future<List<Mesin>> _getMesins() async {
    final QuerySnapshot snapshot = await mesinsRef.get();
    final List<Mesin> mesins = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      mesins.add(Mesin.fromJson(data));
    }
    return mesins;
  }
}
