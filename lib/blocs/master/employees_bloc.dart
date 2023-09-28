import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/master/employee.dart';

// Events
abstract class EmployeeEvent {}

class AddEmployeeEvent extends EmployeeEvent {
  final Employee employee;
  AddEmployeeEvent(this.employee);
}

class UpdateEmployeeEvent extends EmployeeEvent {
  final String employeeId;
  final Employee updatedEmployee;
  final String currentUsername;
  UpdateEmployeeEvent(this.employeeId, this.updatedEmployee, this.currentUsername);
}

class DeleteEmployeeEvent extends EmployeeEvent {
  final String employeeId;
  final String employeePassword; // Tambahkan atribut ini
  DeleteEmployeeEvent(this.employeeId, this.employeePassword);
}

class LoadEmployeesEvent extends EmployeeEvent {} // Tambahkan event ini untuk memuat data pegawai

// States
abstract class EmployeeState {}

class LoadingState extends EmployeeState {}

class SuccessState extends EmployeeState {}

class LoadedState extends EmployeeState {
  final List<Employee> employees;
  LoadedState(this.employees);
}

class ErrorState extends EmployeeState {
  final String errorMessage;
  ErrorState(this.errorMessage);
}

// BLoC
class EmployeeBloc extends Bloc<EmployeeEvent, EmployeeState> {
  late FirebaseFirestore _firestore;
  late CollectionReference employeesRef;

  EmployeeBloc() : super(LoadingState()) {
    _firestore = FirebaseFirestore.instance;
    employeesRef = _firestore.collection('employees');
  }

  @override
  Stream<EmployeeState> mapEventToState(EmployeeEvent event) async* {
    if (event is AddEmployeeEvent) {
      yield LoadingState();
        final alamat = event.employee.alamat;
        final email = event.employee.email;
        final gajiHarian = event.employee.gajiHarian;
        final gajiLemburJam = event.employee.gajiLemburJam;
        final jenisKelamin = event.employee.jenisKelamin;
        final nama = event.employee.nama;
        final nomorTelepon = event.employee.nomorTelepon;
        final posisi = event.employee.posisi;
        final status = event.employee.status;
        final tanggalMasuk = event.employee.tanggalMasuk;
        final username = event.employee.username;
        final password = event.employee.password;

        if(alamat.isNotEmpty && email.isNotEmpty && jenisKelamin.isNotEmpty && nama.isNotEmpty && nomorTelepon.isNotEmpty && posisi.isNotEmpty  && username.isNotEmpty && password.isNotEmpty){

          try{
            final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('pegawaiAdd');
            final HttpsCallableResult<dynamic> result =
            await callable.call(<String, dynamic>{
              'email': email,
              'password': password,
              'username': username,
              'telp': nomorTelepon,
              'gajiHarian': gajiHarian,
              'gajiLembur': gajiLemburJam,
              'status':status
            });

            if (result.data['success'] == true) {
              final String nextEmployeeId = await _generateNextEmployeeId();

              //Langkah 2: Add data to Firestore employees
              await employeesRef.add({
                'id': nextEmployeeId,
                'alamat': alamat,
                'email': email,
                'gaji_harian': gajiHarian.toInt(),
                'gaji_lembur_jam': gajiLemburJam.toInt(),
                'jenis_kelamin': jenisKelamin,
                'nama': nama,
                'nomor_telepon': nomorTelepon,
                'posisi': posisi,
                'status': status,
                'tanggal_masuk': tanggalMasuk,
                'username': username,
              });

              await FirebaseAuth.instance.createUserWithEmailAndPassword(
                email: email,
                password: password,
              );
              yield LoadingState();
              yield SuccessState();
          } else {
            yield ErrorState(result.data['message']);
          }
          }catch(e){
            yield ErrorState(e.toString());
          }          
        }else{
          yield ErrorState("Harap isi semua field!");
        }

    } else if (event is UpdateEmployeeEvent) {
      yield LoadingState();
        final employeeSnapshot = await employeesRef.where('id', isEqualTo: event.employeeId).get();
        if (employeeSnapshot.docs.isNotEmpty) {

            final alamat = event.updatedEmployee.alamat;
            final gajiHarian = event.updatedEmployee.gajiHarian;
            final gajiLemburJam = event.updatedEmployee.gajiLemburJam;
            final jenisKelamin = event.updatedEmployee.jenisKelamin;
            final nama = event.updatedEmployee.nama;
            final nomorTelepon = event.updatedEmployee.nomorTelepon;
            final posisi = event.updatedEmployee.posisi;
            final status = event.updatedEmployee.status;
            final tanggalMasuk = event.updatedEmployee.tanggalMasuk;
            final username = event.updatedEmployee.username;
            final currentUsername = event.currentUsername;

            if(alamat.isNotEmpty && jenisKelamin.isNotEmpty && nama.isNotEmpty && nomorTelepon.isNotEmpty && posisi.isNotEmpty  && username.isNotEmpty){
              try{
                  final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('pegawaiUpdate');
                  final HttpsCallableResult<dynamic> result =
                  await callable.call(<String, dynamic>{
                    'username': username,
                    'telp': nomorTelepon,
                    'gajiHarian': gajiHarian,
                    'gajiLembur': gajiLemburJam,
                    'status':status,
                    'currentUser': currentUsername
                  });

                 if (result.data['success'] == true) {
                    final employeeDoc = employeeSnapshot.docs.first;
                    final Map<String, dynamic> updatedData = {
                      'alamat': alamat,
                      'gaji_harian': gajiHarian,
                      'gaji_lembur_jam': gajiLemburJam,
                      'jenis_kelamin': jenisKelamin,
                      'nama': nama,
                      'nomor_telepon': nomorTelepon,
                      'posisi': posisi,
                      'status': status,
                      'tanggal_masuk': tanggalMasuk,
                      'username': username
                    };
                
                    // Langkah 2: Perbarui data pegawai di Firestore
                    await employeeDoc.reference.update(updatedData);
                    yield LoadingState();
                    yield SuccessState();
                 }else{
                    yield ErrorState(result.data['message']);
                 }
            }catch(e){
              yield ErrorState(e.toString());
            }

           }else{
               yield ErrorState("Harap isi semua field!");
           }

        } else {
          // Handle jika data pegawai dengan ID tersebut tidak ditemukan
          yield ErrorState('Data pegawai dengan ID ${event.employeeId} tidak ditemukan.');
        }
    } else if (event is DeleteEmployeeEvent) {
      yield LoadingState();
      try {
          // Cari dokumen dengan 'id' yang sesuai dengan event.employeeId
          QuerySnapshot querySnapshot = await employeesRef.where('id', isEqualTo: event.employeeId).get();
          
          // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
          for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
            // Hapus dokumen Firestore
            await documentSnapshot.reference.delete();
          }
         
          yield LoadedState(await _getEmployees());
        } catch (e) {
          yield ErrorState("Gagal menghapus employee.");
        }
    } else if (event is LoadEmployeesEvent) { // Tambahkan kondisi untuk memuat data pegawai
      yield LoadingState();
      try {
        yield LoadedState(await _getEmployees());
      } catch (e) {
        yield ErrorState("Gagal memuat data employee.");
      }
    }
  }

  Future<String> _generateNextEmployeeId() async {
    final QuerySnapshot snapshot = await employeesRef.get();
    final List<String> existingIds = snapshot.docs.map((doc) => doc['id'] as String).toList();
    int employeeCount = 1;

    while (true) {
      final nextEmployeeId = 'employee${employeeCount.toString().padLeft(3, '0')}';
      if (!existingIds.contains(nextEmployeeId)) {
        return nextEmployeeId;
      }
      employeeCount++;
    }
  }

  Future<List<Employee>> _getEmployees() async {
    final QuerySnapshot snapshot = await employeesRef.get();
    final List<Employee> employees = [];
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      employees.add(Employee.fromJson(data));
    }
    return employees;
  }
}
