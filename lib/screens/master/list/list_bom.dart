import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/bom_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListBOMScreen extends StatefulWidget {
  static const routeName = '/list_bom_screen';

  const ListBOMScreen({Key? key}) : super(key: key);

  @override
  State<ListBOMScreen> createState() => _ListBOMScreenState();
}

class _ListBOMScreenState extends State<ListBOMScreen> {
  final CollectionReference productRef =
      FirebaseFirestore.instance.collection('bill_of_materials');
  String searchTerm = '';
  int selectedStatus = -1;

  Future<String> fetchProductName(String productId) async {
    final customerQuery = await FirebaseFirestore.instance
        .collection('products')
        .where('id', isEqualTo: productId)
        .get();

    if (customerQuery.docs.isNotEmpty) {
      final customerDocument = customerQuery.docs.first;
      return customerDocument['nama'] as String;
    } else {
      // Jika dokumen tidak ditemukan, Anda bisa mengembalikan nilai default atau melemparkan pengecualian sesuai kebutuhan.
      throw Exception('Produk dengan ID $productId tidak ditemukan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>  BillOfMaterialBloc(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                const CustomAppBar(title: 'Bill of Material', formScreen: FormMasterBOMScreen()),
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
                    stream: productRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey), // Ubah warna ke abu-abu
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData ||
                          snapshot.data?.docs.isEmpty == true) {
                        return const Text('Tidak ada data bom.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final productDocs = querySnapshot.docs;

                        final filteredProductDocs = productDocs.where((doc) {
                          final nama = doc['id'] as String;
                          final status = doc['status_bom'] as int;
                          return (nama.toLowerCase().contains(
                                  searchTerm.toLowerCase()) &&
                              (selectedStatus.toInt() == -1 ||
                                  status == selectedStatus));
                        }).toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredProductDocs.length,
                          itemBuilder: (context, index) {
                            final data =
                                filteredProductDocs[index].data() as Map<
                                    String, dynamic>;
                            final nama = data['id'] as String;
                            return FutureBuilder<String>(
                              future: fetchProductName(data['product_id']),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  // Saat Future masih dalam proses, tampilkan pesan loading atau apa pun yang sesuai
                                    return const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey), // Ubah warna ke abu-abu
                                  ),
                                );
                                } else if (snapshot.hasError) {
                                  // Handle jika terjadi error saat fetching data
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final productName = snapshot.data;
                                  final info = {
                                    'Id': data['id'] as String,
                                    'Id Produk': data['product_id'] as String,
                                    'Nama Produk':
                                        productName ?? 'Produk tidak ditemukan',
                                    'Status': data['status_bom'] == 1
                                        ? 'Aktif'
                                        : 'Tidak Aktif',
                                  };

                                  return ListCard(
                                    title: nama,
                                    description: info.entries
                                        .map((e) =>
                                            '${e.key}: ${e.value}')
                                        .join('\n'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                             FormMasterBOMScreen(
                                              bomId: filteredProductDocs[index].id,
                                              productId: data['product_id'],
                                             )
                                        ),
                                      );
                                    },
                                    onDeletePressed: () async {
                                      final confirmed = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text(
                                                "Konfirmasi Hapus"),
                                            content: const Text(
                                                "Anda yakin ingin menghapus BOM ini?"),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text("Batal"),
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                              ),
                                              TextButton(
                                                child: const Text("Hapus"),
                                                onPressed: () async {
                                                  final bomBloc =
                                                      BlocProvider.of<
                                                          BillOfMaterialBloc>(
                                                          context);
                                                  bomBloc.add(
                                                      DeleteBillOfMaterialEvent(
                                                          data['id']));
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
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                  BlocBuilder<BillOfMaterialBloc, BillOfMaterialBlocState>(
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
