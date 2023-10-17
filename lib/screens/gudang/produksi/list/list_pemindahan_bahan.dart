import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_transfer_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/form/form_pemindahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/sidebar_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/filter_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/listCardFinishedDelete.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPemindahanBahan extends StatefulWidget {
  static const routeName = '/gudang/produksi/pemindahan/list';

  const ListPemindahanBahan({super.key});
  @override
  State<ListPemindahanBahan> createState() => _ListPemindahanBahanState();
}

class _ListPemindahanBahanState extends State<ListPemindahanBahan> {
  final CollectionReference purchaseReqRef = FirebaseFirestore.instance.collection('material_transfers');
  String searchTerm = '';
  String selectedStatus ='';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String startDateText = ''; // Tambahkan variabel untuk menampilkan tanggal filter
  String endDateText = '';   // Tambahkan variabel untuk menampilkan tanggal filter
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;
  int _selectedIndex = 4;
  bool _isSidebarCollapsed = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.desktop) {
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
          onToggleSidebar:  _toggleSidebar
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomAppBar(title: 'Pemindahan Bahan', formScreen: FormPemindahanBahan(), routes: '${MainGudang.routeName}?selectedIndex=4',),
                  const SizedBox(height: 24.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  buildDateRangeSelector(),
                  const SizedBox(height: 16.0),
                  _buildMaterialTransferList(),
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
    Routemaster.of(context).push('${MainGudang.routeName}?selectedIndex=$index');
  }


Widget _buildMobileContent() {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppBar(title: 'Pemindahan Bahan', formScreen: FormPemindahanBahan(), routes: '${MainGudang.routeName}?selectedIndex=4',),
          const SizedBox(height: 24.0),
          _buildSearchBar(),
          const SizedBox(height: 16.0,),
          buildDateRangeSelector(),
          const SizedBox(height: 16.0),
          _buildMaterialTransferList(),
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

  Widget buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
        child:  DatePickerButton(
        label: 'Tanggal Mulai',
        selectedDate: selectedStartDate,
        onDateSelected: (newDate) {
          setState(() {
            selectedStartDate = newDate;
          });
        },
        ),),
        const SizedBox(width: 16.0),
        Expanded(
        child: DatePickerButton(
        label: 'Tanggal Selesai',
        selectedDate: selectedEndDate,
        onDateSelected: (newDate) {
          setState(() {
            selectedEndDate = newDate;
          });
        },
          ), 
        )
      ],
    );
  }


  Widget _buildMaterialTransferList() {
    return StreamBuilder<QuerySnapshot>(
    stream: purchaseReqRef.snapshots(),
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
        return const Text('Tidak ada data pemindahan bahan');
      } else {
        final querySnapshot = snapshot.data!;
        final itemDocs = querySnapshot.docs;

        final filteredDocs = itemDocs.where((doc) {
          final keterangan = doc['id'] as String;
          final status = doc['status_mtr'] as String;
          final tanggalPembuatan = doc['tanggal_pemindahan'] as Timestamp; // Tanggal Pesan

          bool isWithinDateRange = true;
          if (selectedStartDate != null && selectedEndDate != null) {
            isWithinDateRange = (tanggalPembuatan.toDate().isAfter(selectedStartDate!) && tanggalPembuatan.toDate().isBefore(selectedEndDate!));
          }

          return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
              (selectedStatus.isEmpty || status == selectedStatus) &&
              isWithinDateRange);
        }).toList();

        // Perbarui status tombol Prev dan Next
        isPrevButtonDisabled = startIndex == 0;
        isNextButtonDisabled = startIndex + itemsPerPage >= filteredDocs.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: (filteredDocs.length - startIndex).clamp(0, itemsPerPage),
              itemBuilder: (context, index) {
                final data = filteredDocs[startIndex + index].data() as Map<String, dynamic>;
                final id = data['id'] as String;
                final info = {
                  'ID Permintaan Bahan' : data['material_request_id'],
                  'Tanggal Pemindahan': DateFormat('dd/MM/yyyy').format((data['tanggal_pemindahan'] as Timestamp).toDate()), 
                  'Catatan': data['catatan'],
                  'Status': data['status_mtr'],
                };
                return ListCardFinishedDelete(
                  title: id,
                  description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FormPemindahanBahan(
                          materialRequestId: data['material_request_id'],
                          materialTransferId: data['id'],
                          statusMtr: data['status_mtr'],
                        )
                      ),
                    );
                  },
                  onDeletePressed: () async {
                    final confirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Konfirmasi Hapus"),
                          content: const Text("Anda yakin ingin menghapus pemindahan bahan ini?"),
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
                                final materialTransferBloc = BlocProvider.of<MaterialTransferBloc>(context);
                                materialTransferBloc.add(DeleteMaterialTransferEvent(filteredDocs[startIndex + index].id));
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
                  onFinished: () async {
                      final confirmed = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Konfirmasi Menyelesaikan"),
                          content: const Text("Anda yakin ingin menyelesaikan pemindahan bahan ini?"),
                          actions: <Widget>[
                            TextButton(
                              child: const Text("Batal"),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                            TextButton(
                              child: const Text("Selesaikan"),
                              onPressed: () async {
                                final materialTransferBloc = BlocProvider.of<MaterialTransferBloc>(context);
                                materialTransferBloc.add(FinishedMaterialTransferEvent(filteredDocs[startIndex + index].id));
                                Navigator.of(context).pop(true);
                              },
                            ),
                          ],
                        );
                      },
                    );

                    if (confirmed == true) {
                    }
                  },
                  status: data['status_mtr'],
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
                    backgroundColor: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
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
                      if (startIndex >= filteredDocs.length) {
                        startIndex = filteredDocs.length - itemsPerPage;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
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
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          title: ('Filter Berdasarkan Status Pemindahan Bahan'),
          onFilterSelected: (selectedStatus) {
            setState(() {
              this.selectedStatus = selectedStatus!;
            });
          },
        );
      },
  );
}

}
