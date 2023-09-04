import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:sistem_manajemen_produksi_cv_bcn/models/employee.dart';

// Events
abstract class EmployeeEvent {}

class AddEmployeeEvent extends EmployeeEvent {
  final Employee employee;
  AddEmployeeEvent(this.employee);
}

class UpdateEmployeeEvent extends EmployeeEvent {
  final String employeeId;
  final Employee updatedEmployee;
  UpdateEmployeeEvent(this.employeeId, this.updatedEmployee);
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
      try {
        final String nextEmployeeId = await _generateNextEmployeeId();

        // Langkah 1: Sign up dengan Firebase Auth
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: event.employee.email,
          password: event.employee.password,
        );

        //Langkah 2 : Add data to Firestore employees
        await employeesRef.add({
          'id': nextEmployeeId,
          'alamat': event.employee.alamat,
          'email': event.employee.email,
          'gaji_harian': event.employee.gajiHarian,
          'gaji_lembur_jam': event.employee.gajiLemburJam,
          'jenis_kelamin': event.employee.jenisKelamin,
          'nama': event.employee.nama,
          'nomor_telepon': event.employee.nomorTelepon,
          'password': event.employee.password,
          'posisi': event.employee.posisi,
          'status': event.employee.status,
          'tanggal_masuk': event.employee.tanggalMasuk.toIso8601String(),
          'username': event.employee.username,
        });

        yield LoadedState(await _getEmployees());
      } catch (e) {
        yield ErrorState("Gagal menambahkan employee.");
      }
    } else if (event is UpdateEmployeeEvent) {
      yield LoadingState();
      try {
        await employeesRef.doc(event.employeeId).update({
          'alamat': event.updatedEmployee.alamat,
          'email': event.updatedEmployee.email,
          'gaji_harian': event.updatedEmployee.gajiHarian,
          'gaji_lembur_jam': event.updatedEmployee.gajiLemburJam,
          'jenis_kelamin': event.updatedEmployee.jenisKelamin,
          'nama': event.updatedEmployee.nama,
          'nomor_telepon': event.updatedEmployee.nomorTelepon,
          'password': event.updatedEmployee.password,
          'posisi': event.updatedEmployee.posisi,
          'status': event.updatedEmployee.status,
          'tanggal_masuk': event.updatedEmployee.tanggalMasuk.toIso8601String(),
          'username': event.updatedEmployee.username,
        });

        yield LoadedState(await _getEmployees());
      } catch (e) {
        yield ErrorState("Gagal mengubah employee.");
      }
    } else if (event is DeleteEmployeeEvent) {
      yield LoadingState();
        try {
          // Cari dokumen dengan 'id' yang sesuai dengan event.employeeId
          QuerySnapshot querySnapshot = await employeesRef.where('id', isEqualTo: event.employeeId).get();
          
          // Hapus semua dokumen yang sesuai dengan pencarian (biasanya hanya satu dokumen)
          for (QueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
            final employeeEmail = documentSnapshot.get('email') as String;
            
            // Hapus akun Firebase Authentication dengan email yang sesuai
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: employeeEmail,
              password: event.employeePassword, // Password karyawan yang sesuai
            );

            await FirebaseAuth.instance.currentUser!.delete();
            
            // Hapus dokumen Firestore setelah menghapus akun Firebase Authentication
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
    final int employeeCount = snapshot.docs.length;
    final String nextEmployeeId =
        'employee${(employeeCount + 1).toString().padLeft(3, '0')}';
    return nextEmployeeId;
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
