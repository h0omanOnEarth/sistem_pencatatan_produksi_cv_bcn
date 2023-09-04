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
  DeleteEmployeeEvent(this.employeeId);
}

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
          'gajiHarian': event.employee.gajiHarian,
          'gajiLemburJam': event.employee.gajiLemburJam,
          'jenisKelamin': event.employee.jenisKelamin,
          'nama': event.employee.nama,
          'nomorTelepon': event.employee.nomorTelepon,
          'password': event.employee.password,
          'posisi': event.employee.posisi,
          'status': event.employee.status,
          'tanggalMasuk': event.employee.tanggalMasuk.toIso8601String(),
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
          'gajiHarian': event.updatedEmployee.gajiHarian,
          'gajiLemburJam': event.updatedEmployee.gajiLemburJam,
          'jenisKelamin': event.updatedEmployee.jenisKelamin,
          'nama': event.updatedEmployee.nama,
          'nomorTelepon': event.updatedEmployee.nomorTelepon,
          'password': event.updatedEmployee.password,
          'posisi': event.updatedEmployee.posisi,
          'status': event.updatedEmployee.status,
          'tanggalMasuk': event.updatedEmployee.tanggalMasuk.toIso8601String(),
          'username': event.updatedEmployee.username,
        });

        yield LoadedState(await _getEmployees());
      } catch (e) {
        yield ErrorState("Gagal mengubah employee.");
      }
    } else if (event is DeleteEmployeeEvent) {
      yield LoadingState();
      try {
        await employeesRef.doc(event.employeeId).delete();
        yield LoadedState(await _getEmployees());
      } catch (e) {
        yield ErrorState("Gagal menghapus employee.");
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
