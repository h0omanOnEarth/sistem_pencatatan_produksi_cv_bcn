import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_confirmation_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_konfirmasi_hasil.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/sidebar_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/filter_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListKonfirmasiProduksi extends StatefulWidget {
  static const routeName = '/produksi/proses/konfirmasi/list';

  const ListKonfirmasiProduksi({super.key});
  @override
  State<ListKonfirmasiProduksi> createState() => _ListKonfirmasiProduksiState();
}

class _ListKonfirmasiProduksiState extends State<ListKonfirmasiProduksi> {
  final CollectionReference productionResultRef = FirebaseFirestore.instance.collection('production_confirmations');
  String searchTerm = '';
  String selectedStatus ='';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String startDateText = ''; 
  String endDateText = '';   
  int startIndex = 0; 
  int itemsPerPage = 5; 
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;
   int _selectedIndex = 2;
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
        onToggleSidebar:  _toggleSidebar
      ),
      Expanded(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomAppBar(title: 'Konfirmasi Produksi', formScreen: FormKonfirmasiProduksiScreen(), routes: '${MainProduksi.routeName}?selectedIndex=2',),
                const SizedBox(height: 24.0),
                _buildSearchBar(),
                const SizedBox(height: 16.0),
                buildDateRangeSelector(),
                const SizedBox(height: 16.0),
                _buildKonfirmasiProduksiList(),
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
  Routemaster.of(context).push('${MainProduksi.routeName}?selectedIndex=$index');
}


Widget _buildMobileContent() {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppBar(title: 'Konfirmasi Produksi', formScreen: FormKonfirmasiProduksiScreen(), routes: '${MainProduksi.routeName}?selectedIndex=2',),
          const SizedBox(height: 24.0),
          _buildSearchBar(),
          const SizedBox(height: 16.0,),
          buildDateRangeSelector(),
          const SizedBox(height: 16.0),
          _buildKonfirmasiProduksiList(),
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


  Widget _buildKonfirmasiProduksiList() {
    return StreamBuilder<QuerySnapshot>(
        stream: productionResultRef.snapshots(),
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
            return const Text('Tidak ada data konfirmasi produksi.');
          } else {
            final querySnapshot = snapshot.data!;
            final itemDocs = querySnapshot.docs;

            final filteredDocs = itemDocs.where((doc) {
              final keterangan = doc['id'] as String;
              final status = doc['status_prc'] as String;
              final tanggalRencana = doc['tanggal_konfirmasi'] as Timestamp; // Tanggal Pesan

              bool isWithinDateRange = true;
              if (selectedStartDate != null && selectedEndDate != null) {
                isWithinDateRange = (tanggalRencana.toDate().isAfter(selectedStartDate!) && tanggalRencana.toDate().isBefore(selectedEndDate!));
              }

              return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                  (selectedStatus.isEmpty || status == selectedStatus) &&
                  isWithinDateRange);
            }).toList();

              // Implementasi Pagination
            final endIndex = startIndex + itemsPerPage;
            final paginatedDocs = filteredDocs.sublist(
              startIndex,
              endIndex < filteredDocs.length ? endIndex : filteredDocs.length,
            );

            // Mengatur tombol "Prev" dan "Next"
            isPrevButtonDisabled = startIndex == 0;
            isNextButtonDisabled = endIndex >= filteredDocs.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                  ListView.builder(
                  shrinkWrap: true,
                  itemCount: paginatedDocs.length,
                  itemBuilder: (context, index) {
                    final data = paginatedDocs[index].data() as Map<String, dynamic>;
                    final id = data['id'] as String;
                    final info = {
                      'Tanggal Konfirmasi': DateFormat('dd/MM/yyyy').format((data['tanggal_konfirmasi'] as Timestamp).toDate()),
                      'Total': '${data['total']} Pcs', 
                      'Catatan': data['catatan'],
                      'Status' : data['status_prc']
                    };
                    return ListCard(
                      title: id,
                      description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>FormKonfirmasiProduksiScreen(
                              productionConfirmationId: data['id'],
                              statusPrc: data['status_prc'],
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
                              content: const Text("Anda yakin ingin menghapus konfirmasi hasil produksi ini?"),
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
                                    final proResBloc = BlocProvider.of<ProductionConfirmationBloc>(context);
                                    proResBloc.add(DeleteProductionConfirmationEvent(paginatedDocs[index].id));
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
                        backgroundColor: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
                      ),
                      child: const Text("Prev",style: TextStyle(color: Colors.white),),
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
                      child: const Text("Next",style: TextStyle(color: Colors.white),),
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
        title: ('Filter Berdasarkan Status Konfirmasi Produksi'),
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
