import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/products_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_barang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterBarangScreen extends StatefulWidget {
  static const routeName = '/list_master_barang_screen';

  const ListMasterBarangScreen({super.key});
  @override
  State<ListMasterBarangScreen> createState() => _ListMasterBarangScreenState();
}

class _ListMasterBarangScreenState extends State<ListMasterBarangScreen> {
  final CollectionReference productRef = FirebaseFirestore.instance.collection('products');
  String searchTerm = '';
  int selectedStatus = -1;
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
     return BlocProvider(
      create: (context) => ProductBloc(),
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
                              'Barang',
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
                                    Navigator.push(context,MaterialPageRoute( builder: (context) => FormMasterBarangScreen()),
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
                    stream: productRef.snapshots(),
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
                        return const Text('Tidak ada data barang.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final productDocs = querySnapshot.docs;

                        final filteredProductDocs = productDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final status = doc['status'] as int;
                          return (nama.toLowerCase().contains(searchTerm.toLowerCase()) &&
                              (selectedStatus.toInt() == -1 || status == selectedStatus));
                        }).toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredProductDocs.length,
                          itemBuilder: (context, index) {
                            final data = filteredProductDocs[index].data() as Map<String, dynamic>;
                            final nama = data['nama'] as String;
                            final info = {
                            'Id': data['id'] as String,
                            'Jenis': data['jenis'] as String,
                            'Stok': data['stok'] as int,
                            'Satuan': data['satuan'] as String,
                            'Status': data['status'] == 1 ? 'Aktif' : 'Tidak Aktif',
                          };
                            return ListCard(
                              title: nama,
                              description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormMasterBarangScreen(
                                       productId: data['id'], // Mengirimkan ID pelanggan
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
                                      content: const Text("Anda yakin ingin menghapus pelanggan ini?"),
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
                                            final productBloc =BlocProvider.of<ProductBloc>(context);
                                            productBloc.add(DeleteProductEvent(data['id']));
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
                  BlocBuilder<ProductBloc, ProductBlocState>(
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
    )
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
                Navigator.pop(context, 'Aktif');
              },
              child: const Text('Aktif'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Tidak Aktif');
              },
              child: const Text('Tidak Aktif'),
            ),
          ],
        );
      },
    );

    if (selectedValue != null) {
      setState(() {
        selectedStatus = (selectedValue == 'Aktif') ? 1 : (selectedValue == 'Tidak Aktif') ? 0 : -1;
      });
    }
  }

}

