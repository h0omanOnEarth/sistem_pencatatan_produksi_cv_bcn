import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/materials_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterBahanScreen extends StatefulWidget {
  static const routeName = '/list_master_bahan_screen';

  const ListMasterBahanScreen({super.key});
  @override
  State<ListMasterBahanScreen> createState() => _ListMasterBahanScreenState();
}

class _ListMasterBahanScreenState extends State<ListMasterBahanScreen> {
  final CollectionReference materialRef = FirebaseFirestore.instance.collection('materials');
  String searchTerm = '';
  String selectedJenis = '';
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 3; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MaterialBloc(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomAppBar(title: 'Bahan', formScreen: FormMasterBahanScreen()),
                  const SizedBox(height: 24.0),
                  Row(
                    children: [
                      Expanded(
                        child: SearchBarWidget(searchTerm: searchTerm, onChanged: (value) {
                          setState(() {
                            searchTerm = value;
                          });
                        }),
                      ),
                      const SizedBox(width: 16.0), // Add spacing between calendar icon and filter button
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
                  const SizedBox(height: 16.0,),
                  StreamBuilder<QuerySnapshot>(
                    stream: materialRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey), // Ubah warna ke abu-abu
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                        return const Text('Tidak ada data bahan.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final materialDocs = querySnapshot.docs;

                        final filterJenisDocs = materialDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final jenis = doc['jenis_bahan'] as String;
                          return (nama.toLowerCase().contains(searchTerm.toLowerCase()) &&
                              (selectedJenis.isEmpty || jenis == selectedJenis));
                        }).toList();

                        // Perbarui status tombol Prev dan Next
                        isPrevButtonDisabled = startIndex == 0;
                        isNextButtonDisabled = startIndex + itemsPerPage >= filterJenisDocs.length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: (filterJenisDocs.length - startIndex).clamp(0, itemsPerPage),
                              itemBuilder: (context, index) {
                                final data = filterJenisDocs[startIndex + index].data() as Map<String, dynamic>;
                                final nama = data['nama'] as String;
                                final info = {
                                  'id' : data['id'] as String,
                                  'Jenis bahan': data['jenis_bahan'] as String,
                                  'Stok' : data['stok'] as int,
                                  'Satuan' : data['satuan'] as String,
                                  'Status': data['status'] == 1 ? 'Aktif' : 'Tidak Aktif',
                                };
                                return ListCard(
                                  title: nama,
                                  description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormMasterBahanScreen(
                                          materialId: data['id'], // Mengirimkan ID pelanggan
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
                                          content: const Text("Anda yakin ingin menghapus bahan ini?"),
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
                                                final bahanBloc = BlocProvider.of<MaterialBloc>(context);
                                                bahanBloc.add(DeleteMaterialEvent(data['id']));
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
                            ),
                            const SizedBox(height: 16.0,),
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
                                    primary: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
                                  ),
                                  child: const Text("Prev"),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: isNextButtonDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            startIndex += itemsPerPage;
                                            if (startIndex >= filterJenisDocs.length) {
                                              startIndex = filterJenisDocs.length - itemsPerPage;
                                            }
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
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
                  BlocBuilder<MaterialBloc, MaterialBlocState>(
                    builder: (context, state) {
                      if (state is ErrorState) {
                        Text(state.errorMessage);
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
          title: const Text('Filter Berdasarkan Jenis Bahan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Bahan Baku');
              },
              child: const Text('Bahan Baku'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Bahan Tambahan');
              },
              child: const Text('Bahan Tambahan'),
            ),
          ],
        );
      },
    );

    if (selectedValue != null) {
      setState(() {
        selectedJenis = selectedValue;
      });
    }
  }
}
