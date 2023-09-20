import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/suppliers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_supplier.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterSupplierScreen extends StatefulWidget {
  static const routeName = '/list_master_supplier_screen';

  const ListMasterSupplierScreen({super.key});
  @override
  State<ListMasterSupplierScreen> createState() => _ListMasterSupplierScreenState();
}

class _ListMasterSupplierScreenState extends State<ListMasterSupplierScreen> {
  final CollectionReference supplierRef = FirebaseFirestore.instance.collection('suppliers');
  String searchTerm = '';
  String selectedJenis = '';
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupplierBloc(),
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
               const CustomAppBar(title: 'Supplier', formScreen: FormMasterSupplierScreen()),
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
                    stream: supplierRef.snapshots(),
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
                        return const Text('Tidak ada data supplier.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final supplierDocs = querySnapshot.docs;

                        final filterJenisDocs = supplierDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final jenis = doc['jenis_supplier'] as String;
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
                            'Jenis Supplier': data['jenis_supplier'] as String,
                            'Alamat' : data['alamat'] as String,
                            'Nomor Telepon' : data['no_telepon'] as String,
                            'Status': data['status'] == 1 ? 'Aktif' : 'Tidak Aktif',
                          };
                            return ListCard(
                              title: nama,
                              description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                               onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormMasterSupplierScreen(
                                       supplierId: data['id'], // Mengirimkan ID pelanggan
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
                                      content: const Text("Anda yakin ingin menghapus supplier ini?"),
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
                                            final supplierBloc =BlocProvider.of<SupplierBloc>(context);
                                            supplierBloc.add(DeleteSupplierEvent(data['id']));
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
                  BlocBuilder<SupplierBloc, SupplierState>(
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
          title: const Text('Filter Berdasarkan Jenis Supplier'),
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

