import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/materials_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterBahanScreen extends StatefulWidget {
  static const routeName = '/list_master_bahan_screen';

  const ListMasterBahanScreen({super.key});
  @override
  State<ListMasterBahanScreen> createState() => _ListMasterBahanScreenState();
}

class _ListMasterBahanScreenState extends State<ListMasterBahanScreen> {
  int _currentPage = 1;
  int _totalPages = 10; // Change this to the total number of pages
  final CollectionReference materialRef = FirebaseFirestore.instance.collection('materials');
  String searchTerm = '';
  String selectedJenis = '';
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
                              'Bahan',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth*0.20),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.brown,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                color: Colors.white,
                                onPressed: () {
                                    Navigator.push(context,MaterialPageRoute( builder: (context) => FormMasterBahanScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0), // Add spacing between header and cards
                  // Search Bar and Filter Button
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
                            SizedBox(width: 16.0), // Add spacing between search bar and filter button
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
                // Create 6 cards
                SizedBox(height: 16.0,),
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

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filterJenisDocs.length,
                          itemBuilder: (context, index) {
                            final data = filterJenisDocs[index].data() as Map<String, dynamic>;
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
                                            final bahanBloc =BlocProvider.of<MaterialBloc>(context);
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
                // Pagination Row
                buildPaginationRow(),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

Widget buildPaginationRow() {
  int startIndex = (_currentPage - 1).clamp(1, _totalPages - 4);
  int endIndex = (_currentPage + 1).clamp(startIndex + 2, _totalPages);

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_currentPage > 2) buildPageIndicator(_currentPage - 2),
        if (_currentPage > 1) buildPageIndicator(_currentPage - 1),
        buildPageIndicator(_currentPage),
        if (_currentPage < _totalPages) buildPageIndicator(_currentPage + 1),
        if (_currentPage < _totalPages - 1) buildPageIndicator(_currentPage + 2),
      ],
    ),
  );
}


Widget buildPageIndicator(int pageNumber) {
  bool isSelected = pageNumber == _currentPage;

  return GestureDetector(
    onTap: () {
      setState(() {
        _currentPage = pageNumber;
      });
    },
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: 32.0,
      height: 32.0,
      decoration: BoxDecoration(
        shape: BoxShape.rectangle, // Set to rectangle
        borderRadius: BorderRadius.circular(16.0), // Add border radius
        color: isSelected ? const Color.fromRGBO(59, 51, 51, 1) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.transparent : Colors.grey,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
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

