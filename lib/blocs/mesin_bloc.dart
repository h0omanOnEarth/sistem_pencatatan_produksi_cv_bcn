import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/machine.dart';

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
    mesinsRef = _firestore.collection('mesins');
  }

  @override
  Stream<MesinState> mapEventToState(MesinEvent event) async* {
    if (event is AddMesinEvent) {
      yield LoadingState();
      try {
        final String nextMesinId = await _generateNextMesinId();

        await mesinsRef.doc(nextMesinId).set({
          'id': nextMesinId,
          'kapasitas_produksi': event.mesin.kapasitasProduksi,
          'keterangan': event.mesin.keterangan,
          'kondisi': event.mesin.kondisi,
          'nama': event.mesin.nama,
          'nomor_seri': event.mesin.nomorSeri,
          'satuan': event.mesin.satuan,
          'status': event.mesin.status,
          'supplier_id': event.mesin.supplierId,
          'tahun_pembuatan': event.mesin.tahunPembuatan,
          'tahun_perolehan': event.mesin.tahunPerolehan,
          'tipe': event.mesin.tipe,
        });

        yield LoadedState(await _getMesins());
      } catch (e) {
        yield ErrorState("Gagal menambahkan mesin.");
      }
    } else if (event is UpdateMesinEvent) {
      yield LoadingState();
      try {
        await mesinsRef.doc(event.mesinId).update({
          'kapasitas_produksi': event.updatedMesin.kapasitasProduksi,
          'keterangan': event.updatedMesin.keterangan,
          'kondisi': event.updatedMesin.kondisi,
          'nama': event.updatedMesin.nama,
          'nomor_seri': event.updatedMesin.nomorSeri,
          'satuan': event.updatedMesin.satuan,
          'status': event.updatedMesin.status,
          'supplier_id': event.updatedMesin.supplierId,
          'tahun_pembuatan': event.updatedMesin.tahunPembuatan,
          'tahun_perolehan': event.updatedMesin.tahunPerolehan,
          'tipe': event.updatedMesin.tipe,
        });

        yield LoadedState(await _getMesins());
      } catch (e) {
        yield ErrorState("Gagal mengubah mesin.");
      }
    } else if (event is DeleteMesinEvent) {
      yield LoadingState();
      try {
        await mesinsRef.doc(event.mesinId).delete();
        yield LoadedState(await _getMesins());
      } catch (e) {
        yield ErrorState("Gagal menghapus mesin.");
      }
    }
  }

  Future<String> _generateNextMesinId() async {
    final QuerySnapshot snapshot = await mesinsRef.get();
    final int mesinCount = snapshot.docs.length;
    final String nextMesinId =
        'mesin${(mesinCount + 1).toString().padLeft(3, '0')}';
    return nextMesinId;
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
