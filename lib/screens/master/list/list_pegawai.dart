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
                        width: screenWidth * 0.75,
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
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  // Tampilkan daftar pegawai dengan StreamBuilder
                  StreamBuilder<QuerySnapshot>(
                    stream: employeesRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                        return Text('Tidak ada data pegawai.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final employeeDocs = querySnapshot.docs;
                        final filteredEmployeeDocs = searchTerm.isEmpty
                            ? employeeDocs
                            : employeeDocs.where((doc) {
                                final nama = doc['nama'] as String;
                                return nama.toLowerCase().contains(searchTerm.toLowerCase());
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
                                // Tampilkan dialog konfirmasi
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
                                            Navigator.of(context).pop(false); // Tidak jadi menghapus
                                          },
                                        ),
                                        TextButton(
                                          child: Text("Hapus"),
                                          onPressed: () async {
                                            // Hapus data dari Firestore
                                            await employeesRef.doc(filteredEmployeeDocs[index].id).delete();
                                            Navigator.of(context).pop(true); // Menghapus
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
}
