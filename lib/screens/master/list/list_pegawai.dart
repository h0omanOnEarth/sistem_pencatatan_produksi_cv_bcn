import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/employees_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_pegawai.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterPegawaiScreen extends StatefulWidget {
  static const routeName = '/list_master_pegawai_screen';

  const ListMasterPegawaiScreen({Key? key}) : super(key: key);

  @override
  State<ListMasterPegawaiScreen> createState() =>
      _ListMasterPegawaiScreenState();
}

class _ListMasterPegawaiScreenState extends State<ListMasterPegawaiScreen> {
  final CollectionReference employeesRef =
      FirebaseFirestore.instance.collection('employees');
  String searchTerm = '';
  String selectedPosition = '';
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
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
                  const CustomAppBar(
                    title: 'Pegawai',
                    formScreen: FormMasterPegawaiScreen(),
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: SearchBarWidget(
                          searchTerm: searchTerm,
                          onChanged: (value) {
                            setState(() {
                              searchTerm = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(
                          width:
                              16.0), // Add spacing between calendar icon and filter button
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            // Handle filter button press
                            _showFilterDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: employeesRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData ||
                          snapshot.data?.docs.isEmpty == true) {
                        return const Text('Tidak ada data pegawai.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final employeeDocs = querySnapshot.docs;

                        final filteredEmployeeDocs = employeeDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final posisi = doc['posisi'] as String;
                          return (nama.toLowerCase().contains(
                                  searchTerm.toLowerCase()) &&
                              (selectedPosition.isEmpty ||
                                  posisi == selectedPosition));
                        }).toList();

                        // Perbarui status tombol Prev dan Next
                        isPrevButtonDisabled = startIndex == 0;
                        isNextButtonDisabled =
                            startIndex + itemsPerPage >=
                                filteredEmployeeDocs.length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: (filteredEmployeeDocs.length -
                                      startIndex)
                                  .clamp(0, itemsPerPage),
                              itemBuilder: (context, index) {
                                final data =
                                    filteredEmployeeDocs[startIndex + index]
                                        .data() as Map<String, dynamic>;
                                final nama = data['nama'] as String;
                                final info = {
                                  'Alamat': data['alamat'] as String,
                                  'No Telepon': data['nomor_telepon'] as String,
                                  'Posisi': data['posisi'] as String,
                                  'Status': data['status'] == 1
                                      ? 'Aktif'
                                      : 'Tidak Aktif',
                                };
                                return ListCard(
                                  title: nama,
                                  description: info.entries
                                      .map((e) => '${e.key}: ${e.value}')
                                      .join('\n'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            FormMasterPegawaiScreen(
                                          pegawaiId: data['id'],
                                          currentUsername: data['username']
                                        ),
                                      ),
                                    );
                                  },
                                  onDeletePressed: () async {
                                    final confirmed = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Konfirmasi Hapus"),
                                          content: const Text(
                                              "Anda yakin ingin menghapus pegawai ini?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text("Batal"),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: const Text("Hapus"),
                                              onPressed: () async {
                                                final employeeBloc =
                                                    BlocProvider.of<EmployeeBloc>(
                                                        context);
                                                employeeBloc.add(
                                                    DeleteEmployeeEvent(
                                                        data['id'],
                                                        data['password']));
                                                Navigator.of(context)
                                                    .pop(true);
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
                            ),
                            const SizedBox(
                              height: 16.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                ElevatedButton(
                                  onPressed: isPrevButtonDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            startIndex -= itemsPerPage;
                                            if (startIndex < 0) {
                                              startIndex = 0;
                                            }
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                  ),
                                  child: const Text("Prev"),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                ElevatedButton(
                                  onPressed: isNextButtonDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            startIndex += itemsPerPage;
                                            if (startIndex >=
                                                filteredEmployeeDocs.length) {
                                              startIndex = filteredEmployeeDocs.length -
                                                  itemsPerPage;
                                            }
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.brown,
                                  ),
                                  child: const Text("Next"),
                                ),
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  BlocBuilder<EmployeeBloc, EmployeeState>(
                    builder: (context, state) {
                      if (state is ErrorState) {
                        return Text(state.errorMessage);
                      }
                      return const SizedBox.shrink();
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
          title: const Text('Filter Berdasarkan Posisi'),
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
        // Reset startIndex saat filter berubah
        startIndex = 0;
      });
    }
  }
}
