import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/bom_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_bom.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/sidebar_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListBOMScreen extends StatefulWidget {
  static const routeName = '/master/bom/list';

  const ListBOMScreen({Key? key}) : super(key: key);

  @override
  State<ListBOMScreen> createState() => _ListBOMScreenState();
}

class _ListBOMScreenState extends State<ListBOMScreen> {
  final CollectionReference productRef =
      FirebaseFirestore.instance.collection('bill_of_materials');
  String searchTerm = '';
  int selectedStatus = -1;
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;
  int _selectedIndex = 1;
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType ==
                DeviceScreenType.desktop) {
              return _buildDesktopContent();
            } else {
              return _buildMobileContent();
            }
          },
        ),
      ),
    );
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  Widget _buildDesktopContent() {
    return Row(
      children: [
        SidebarProduksiWidget(
            selectedIndex: _selectedIndex,
            onItemTapped: (index) {
              setState(() {
                _selectedIndex = index;
              });
              // Implementasi navigasi berdasarkan index terpilih
              _navigateToScreen(index, context);
            },
            isSidebarCollapsed: _isSidebarCollapsed,
            onToggleSidebar: _toggleSidebar),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomAppBar(
                    title: 'Bill of Material',
                    formScreen: FormMasterBOMScreen(),
                    routes: '${MainProduksi.routeName}?selectedIndex=1',
                  ),
                  const SizedBox(height: 24.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  _buildBomList(),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  // Fungsi navigasi berdasarkan index terpilih
  void _navigateToScreen(int index, BuildContext context) {
    Routemaster.of(context)
        .push('${MainProduksi.routeName}?selectedIndex=$index');
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomAppBar(
              title: 'Bill of Material',
              formScreen: FormMasterBOMScreen(),
              routes: '${MainProduksi.routeName}?selectedIndex=1',
            ),
            const SizedBox(height: 24.0),
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            _buildBomList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
              searchTerm: searchTerm,
              onChanged: (value) {
                setState(() {
                  searchTerm = value;
                });
              }),
        ),
        const SizedBox(
            width: 16.0), // Add spacing between calendar icon and filter button
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
    );
  }

  Widget _buildBomList() {
    return StreamBuilder<QuerySnapshot>(
      stream: productRef.orderBy('id').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.grey), // Ubah warna ke abu-abu
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return const Text('Tidak ada data bom.');
        } else {
          final querySnapshot = snapshot.data!;
          final productDocs = querySnapshot.docs;

          final filteredProductDocs = productDocs.where((doc) {
            final nama = doc['id'] as String;
            final status = doc['status_bom'] as int;
            final statusDoc = doc['status'] as int;
            return (nama.toLowerCase().contains(searchTerm.toLowerCase()) &&
                (selectedStatus.toInt() == -1 || status == selectedStatus) &&
                statusDoc == 1);
          }).toList();

          // Perbarui status tombol Prev dan Next
          isPrevButtonDisabled = startIndex == 0;
          isNextButtonDisabled =
              startIndex + itemsPerPage >= filteredProductDocs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: (filteredProductDocs.length - startIndex)
                    .clamp(0, itemsPerPage),
                itemBuilder: (context, index) {
                  final data = filteredProductDocs[startIndex + index].data()
                      as Map<String, dynamic>;
                  final nama = data['id'] as String;
                  return FutureBuilder<String>(
                    future: fetchProductName(data['product_id']),
                    builder: (context, snapshot) {
                      // if (snapshot.connectionState ==
                      //     ConnectionState.waiting) {
                      //   // Saat Future masih dalam proses, tampilkan pesan loading atau apa pun yang sesuai
                      //   // return const Center(
                      //   //   child: CircularProgressIndicator(
                      //   //     valueColor: AlwaysStoppedAnimation<Color>(Colors.grey), // Ubah warna ke abu-abu
                      //   //   ),
                      //   // );
                      // }
                      if (snapshot.hasError) {
                        // Handle jika terjadi error saat fetching data
                        return Text('Error: ${snapshot.error}');
                      } else {
                        final productName = snapshot.data;
                        final info = {
                          'Id': data['id'] as String,
                          'Id Produk': data['product_id'] as String,
                          'Nama Produk':
                              productName ?? 'Produk tidak ditemukan',
                          'Status':
                              data['status_bom'] == 1 ? 'Aktif' : 'Tidak Aktif',
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
                                  builder: (context) => FormMasterBOMScreen(
                                        bomId: filteredProductDocs[
                                                startIndex + index]
                                            .id,
                                        productId: data['product_id'],
                                      )),
                            );
                          },
                          onDeletePressed: () async {
                            final confirmed = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Konfirmasi Hapus"),
                                  content: const Text(
                                      "Anda yakin ingin menghapus BOM ini?"),
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
                                        final bomBloc =
                                            BlocProvider.of<BillOfMaterialBloc>(
                                                context);
                                        bomBloc.add(DeleteBillOfMaterialEvent(
                                            data['id']));
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
                      backgroundColor: Colors
                          .brown, // Mengubah warna latar belakang menjadi cokelat
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
                              if (startIndex >= filteredProductDocs.length) {
                                startIndex =
                                    filteredProductDocs.length - itemsPerPage;
                              }
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors
                          .brown, // Mengubah warna latar belakang menjadi cokelat
                    ),
                    child: const Text("Next"),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

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

  Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter Berdasarkan Status'),
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
        selectedStatus = (selectedValue == 'Aktif')
            ? 1
            : (selectedValue == 'Tidak Aktif')
                ? 0
                : -1;
      });
    }
  }
}
