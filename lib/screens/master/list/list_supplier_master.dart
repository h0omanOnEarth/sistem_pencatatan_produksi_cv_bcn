import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/suppliers_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/sidebar_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_supplier.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterSupplierScreen extends StatefulWidget {
  static const routeName = '/master/supplier/list';

  const ListMasterSupplierScreen({Key? key}) : super(key: key);

  @override
  State<ListMasterSupplierScreen> createState() =>
      _ListMasterSupplierScreenState();
}

class _ListMasterSupplierScreenState extends State<ListMasterSupplierScreen> {
  final CollectionReference supplierRef = FirebaseFirestore.instance.collection('suppliers');
  String searchTerm = '';
  String selectedJenis = '';
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;
  int _selectedIndex = 1;
  bool _isSidebarCollapsed = false; 
  bool isDesktop = false;

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
            isDesktop = true;
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
      SidebarAdministrasiWidget(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // Implementasi navigasi berdasarkan index terpilih
          _navigateToScreen(index, context);
        },
        isSidebarCollapsed: _isSidebarCollapsed,
        onToggleSidebar:  _toggleSidebar
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomAppBar(title: 'Supplier', formScreen: FormMasterSupplierScreen(), routes: '${MainAdministrasi.routeName}?selectedIndex=1', routeName: FormMasterSupplierScreen.routeName),
                const SizedBox(height: 24.0),
                _buildSearchBar(),
                const SizedBox(height: 16.0),
                buildSupplierList(),
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
  Routemaster.of(context).push('${MainAdministrasi.routeName}?selectedIndex=$index');
}


Widget _buildMobileContent() {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppBar(title: 'Supplier', formScreen: FormMasterSupplierScreen(), routes: '${MainAdministrasi.routeName}?selectedIndex=1',),
          const SizedBox(height: 24.0),
          _buildSearchBar(),
          const SizedBox(height: 16.0,),
          buildSupplierList()
        ],
      ),
    ),
  );
}

  Widget _buildSearchBar() {
    return Row(
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
    );
  }

Widget buildSupplierList() {
  return StreamBuilder<QuerySnapshot>(
      stream: supplierRef.snapshots(),
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
          return const Text('Tidak ada data supplier.');
        } else {
          final querySnapshot = snapshot.data!;
          final supplierDocs = querySnapshot.docs;

          final filterJenisDocs = supplierDocs.where((doc) {
            final nama = doc['nama'] as String;
            final jenis = doc['jenis_supplier'] as String;
            return (nama.toLowerCase().contains(
                    searchTerm.toLowerCase()) &&
                (selectedJenis.isEmpty || jenis == selectedJenis));
          }).toList();

          // Perbarui status tombol Prev dan Next
          isPrevButtonDisabled = startIndex == 0;
          isNextButtonDisabled =
              startIndex + itemsPerPage >=
                  filterJenisDocs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: (filterJenisDocs.length -
                        startIndex)
                    .clamp(0, itemsPerPage),
                itemBuilder: (context, index) {
                  final data =
                      filterJenisDocs[startIndex + index]
                          .data() as Map<String, dynamic>;
                  final nama = data['nama'] as String;
                  final info = {
                    'id': data['id'] as String,
                    'Jenis Supplier':
                        data['jenis_supplier'] as String,
                    'Alamat': data['alamat'] as String,
                    'Nomor Telepon':
                        data['no_telepon'] as String,
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
                      if(isDesktop==true){
                        Routemaster.of(context).push('${FormMasterSupplierScreen.routeName}?supplierId=${data['id']}');
                      }else{
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FormMasterSupplierScreen(
                            supplierId: data['id'],
                          ),
                        ),
                      );
                      }
                    },
                    onDeletePressed: () async {
                      final confirmed = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Konfirmasi Hapus"),
                            content: const Text(
                                "Anda yakin ingin menghapus supplier ini?"),
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
                                  final supplierBloc =
                                      BlocProvider.of<
                                              SupplierBloc>(
                                          context);
                                  supplierBloc.add(
                                      DeleteSupplierEvent(
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
                                  filterJenisDocs.length) {
                                startIndex =
                                    filterJenisDocs.length -
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
        // Reset startIndex saat filter berubah
        startIndex = 0;
      });
    }
  }
}
