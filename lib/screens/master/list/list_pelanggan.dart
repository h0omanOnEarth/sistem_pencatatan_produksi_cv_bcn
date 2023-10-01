import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/customers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterPelangganScreen extends StatefulWidget {
  static const routeName = '/list_master_pelanggan_screen';

  const ListMasterPelangganScreen({Key? key}) : super(key: key);

  @override
  State<ListMasterPelangganScreen> createState() =>
      _ListMasterPelangganScreenState();
}

class _ListMasterPelangganScreenState extends State<ListMasterPelangganScreen> {
  final CollectionReference customerRef =
      FirebaseFirestore.instance.collection('customers');
  String searchTerm = '';
  int selectedStatus = -1;
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerBloc(),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomAppBar(
                    title: 'Pelanggan',
                    formScreen: FormMasterPelangganScreen(),
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
                    stream: customerRef.snapshots(),
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
                        return const Text('Tidak ada data pelanggan.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final customerDocs = querySnapshot.docs;

                        final filteredCustomerDocs = customerDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final status = doc['status'] as int;
                          return (nama.toLowerCase().contains(
                                  searchTerm.toLowerCase()) &&
                              (selectedStatus == -1 || status == selectedStatus));
                        }).toList();

                        // Perbarui status tombol Prev dan Next
                        isPrevButtonDisabled = startIndex == 0;
                        isNextButtonDisabled =
                            startIndex + itemsPerPage >=
                                filteredCustomerDocs.length;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: (filteredCustomerDocs.length -
                                      startIndex)
                                  .clamp(0, itemsPerPage),
                              itemBuilder: (context, index) {
                                final data =
                                    filteredCustomerDocs[startIndex + index]
                                        .data() as Map<String, dynamic>;
                                final nama = data['nama'] as String;
                                final info = {
                                  'Id': data['id'] as String,
                                  'Alamat': data['alamat'] as String,
                                  'No Telepon': data['nomor_telepon'] as String,
                                  'email': data['email'] as String,
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
                                            FormMasterPelangganScreen(
                                          customerId: data['id'],
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
                                              "Anda yakin ingin menghapus pelanggan ini?"),
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
                                                final customerBloc =
                                                    BlocProvider.of<CustomerBloc>(
                                                        context);
                                                customerBloc.add(
                                                    DeleteCustomerEvent(
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
                                                filteredCustomerDocs.length) {
                                              startIndex =
                                                  filteredCustomerDocs.length -
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
                  BlocBuilder<CustomerBloc, CustomerBlocState>(
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
        // Reset startIndex saat filter berubah
        startIndex = 0;
      });
    }
  }
}
