import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterPegawaiScreen extends StatefulWidget {
  static const routeName = '/list_master_pegawai_screen';

  const ListMasterPegawaiScreen({Key? key}) : super(key: key);

  @override
  State<ListMasterPegawaiScreen> createState() => _ListMasterPegawaiScreenState();
}

class _ListMasterPegawaiScreenState extends State<ListMasterPegawaiScreen> {
  final CollectionReference employeesRef = FirebaseFirestore.instance.collection('employees');
  String searchTerm = '';
  String selectedPosition = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => EmployeeBloc(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 80,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 8.0),
                              Align(
                                alignment: Alignment.topLeft,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.arrow_back, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 24.0),
                              const Text(
                                'Pegawai',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.20),
                              Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.brown,
                                ),
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.push(
                                        context, MaterialPageRoute(builder: (context) => FormMasterPegawaiScreen()));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0),
                  Row(
                    children: [
                      Container(
                        child: SearchBarWidget(searchTerm: searchTerm, onChanged: (value) {
                          setState(() {
                            searchTerm = value;
                          });
                        }),
                        width: screenWidth * 0.6,
                      ),
                      SizedBox(width: 16.0),
                       Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.filter_list),
                          onPressed: () {
                            // Handle filter button press
                             _showFilterDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  StreamBuilder<QuerySnapshot>(
                    stream: employeesRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                         return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey), // Ubah warna ke abu-abu
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                        return Text('Tidak ada data pegawai.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final employeeDocs = querySnapshot.docs;

                        final filteredEmployeeDocs = employeeDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final posisi = doc['posisi'] as String;
                          return (nama.toLowerCase().contains(searchTerm.toLowerCase()) &&
                              (selectedPosition.isEmpty || posisi == selectedPosition));
                        }).toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredEmployeeDocs.length,
                          itemBuilder: (context, index) {
                            final data = filteredEmployeeDocs[index].data() as Map<String, dynamic>;
                            final nama = data['nama'] as String;
                            final alamat = data['alamat'] as String;
                            return ListCard(
                              title: nama,
                              description: 'Alamat : $alamat',
                              onDeletePressed: () async {
                                final confirmed = await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Konfirmasi Hapus"),
                                      content: Text("Anda yakin ingin menghapus pegawai ini?"),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text("Batal"),
                                          onPressed: () {
                                            Navigator.of(context).pop(false);
                                          },
                                        ),
                                        TextButton(
                                          child: Text("Hapus"),
                                          onPressed: () async {
                                            final employeeBloc =BlocProvider.of<EmployeeBloc>(context);
                                            employeeBloc.add(DeleteEmployeeEvent(data['id'], data['password']));
                                            Navigator.of(context).pop(true);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed == true) {
                                  // Data telah dihapus, tidak perlu melakukan apa-apa lagi
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                  BlocBuilder<EmployeeBloc, EmployeeState>(
                    builder: (context, state) {
                      if (state is ErrorState) {
                        Text(state.errorMessage);
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Filter Berdasarkan Posisi'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Administrasi');
              },
              child: const Text('Administrasi'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Produksi');
              },
              child: const Text('Produksi'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Gudang');
              },
              child: const Text('Gudang'),
            ),
          ],
        );
      },
    );

    if (selectedValue != null) {
      setState(() {
        selectedPosition = selectedValue;
      });
    }
  }
}
