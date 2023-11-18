import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/master/mesin_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/sidebar_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/sidebar_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/sidebar_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterMesinScreen extends StatefulWidget {
  static const routeName = '/master/mesin/list';
  final int? mode;
  const ListMasterMesinScreen({Key? key, this.mode}) : super(key: key);

  @override
  State<ListMasterMesinScreen> createState() => _ListMasterMesinScreenState();
}

class _ListMasterMesinScreenState extends State<ListMasterMesinScreen> {
  final CollectionReference mesinRef =
      FirebaseFirestore.instance.collection('machines');
  String searchTerm = '';
  String selectedTipe = '';
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;
  int _selectedIndex = 1;
  bool _isSidebarCollapsed = false;
  String? routeName;

  @override
  void initState() {
    super.initState();
    if (widget.mode == 1) {
      routeName = '${MainAdministrasi.routeName}?selectedIndex=1';
    } else if (widget.mode == 2) {
      routeName = '${MainGudang.routeName}?selectedIndex=1';
    } else {
      routeName = '${MainProduksi.routeName}?selectedIndex=1';
    }
  }

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
        if (widget.mode == 1)
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
              onToggleSidebar: _toggleSidebar),
        if (widget.mode == 2)
          SidebarGudangWidget(
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
        if (widget.mode == 3)
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
                  CustomAppBar(
                    title: 'Mesin',
                    formScreen: FormMasterMesinScreen(),
                    routes: routeName,
                  ),
                  const SizedBox(height: 24.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  _buildMesinList(),
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
    if (widget.mode == 1) {
      Routemaster.of(context)
          .push('${MainAdministrasi.routeName}?selectedIndex=$index');
    } else if (widget.mode == 2) {
      Routemaster.of(context)
          .push('${MainGudang.routeName}?selectedIndex=$index');
    } else {
      Routemaster.of(context)
          .push('${MainProduksi.routeName}?selectedIndex=$index');
    }
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomAppBar(
              title: 'Mesin',
              formScreen: const FormMasterMesinScreen(),
              routes: routeName,
            ),
            const SizedBox(height: 24.0),
            _buildSearchBar(),
            const SizedBox(height: 16.0),
            _buildMesinList(),
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

  Widget _buildMesinList() {
    return StreamBuilder<QuerySnapshot>(
      stream: mesinRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return const Text('Tidak ada data mesin.');
        } else {
          final querySnapshot = snapshot.data!;
          final mesinDocs = querySnapshot.docs;

          final filteredTipeDocs = mesinDocs.where((doc) {
            final nama = doc['nama'] as String;
            final tipe = doc['tipe'] as String;
            final statusDoc = doc['status'] as int;
            return (nama.toLowerCase().contains(searchTerm.toLowerCase()) &&
                (selectedTipe.isEmpty || tipe == selectedTipe) &&
                statusDoc == 1);
          }).toList();

          // Perbarui status tombol Prev dan Next
          isPrevButtonDisabled = startIndex == 0;
          isNextButtonDisabled =
              startIndex + itemsPerPage >= filteredTipeDocs.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: (filteredTipeDocs.length - startIndex)
                    .clamp(0, itemsPerPage),
                itemBuilder: (context, index) {
                  final data = filteredTipeDocs[startIndex + index].data()
                      as Map<String, dynamic>;
                  final nama = data['nama'] as String;
                  final info = {
                    'id': data['id'] as String,
                    'nomor seri': data['nomor_seri'] as String,
                    'Status': data['status'] == 1 ? 'Aktif' : 'Tidak Aktif',
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
                          builder: (context) => FormMasterMesinScreen(
                            mesinId: data['id'],
                            supplierId: data['supplier_id'],
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
                                "Anda yakin ingin menghapus mesin ini?"),
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
                                  final mesinBloc =
                                      BlocProvider.of<MesinBloc>(context);
                                  mesinBloc.add(DeleteMesinEvent(data['id']));
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
              const SizedBox(height: 16.0),
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
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isNextButtonDisabled
                        ? null
                        : () {
                            setState(() {
                              startIndex += itemsPerPage;
                              if (startIndex >= filteredTipeDocs.length) {
                                startIndex =
                                    filteredTipeDocs.length - itemsPerPage;
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
          title: const Text('Filter Berdasarkan Tipe Mesin'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Penggiling');
              },
              child: const Text('Penggiling'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pencampuran');
              },
              child: const Text('Pencampuran'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pencetak');
              },
              child: const Text('Pencetak'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Sheet');
              },
              child: const Text('Sheet'),
            ),
          ],
        );
      },
    );

    if (selectedValue != null) {
      setState(() {
        selectedTipe = selectedValue;
        // Reset startIndex saat filter berubah
        startIndex = 0;
      });
    }
  }
}
