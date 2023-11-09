import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_perintah_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/sidebar_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/filter_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListProductionOrder extends StatefulWidget {
  static const routeName = '/produksi/proses/perintah/list';

  const ListProductionOrder({super.key});
  @override
  State<ListProductionOrder> createState() => _ListProductionOrderState();
}

class _ListProductionOrderState extends State<ListProductionOrder> {
  final CollectionReference productionOrderRef =
      FirebaseFirestore.instance.collection('production_orders');
  String searchTerm = '';
  String selectedStatus = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String startDateText = '';
  String endDateText = '';
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 5; // Jumlah data per halaman
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
                    title: 'Perintah Produksi',
                    formScreen: FormPerintahProduksiScreen(),
                    routes: '${MainProduksi.routeName}?selectedIndex=2',
                  ),
                  const SizedBox(height: 24.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  buildDateRangeSelector(),
                  const SizedBox(height: 16.0),
                  _buildProductionOrderList(),
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
              title: 'Perintah Produksi',
              formScreen: FormPerintahProduksiScreen(),
              routes: '${MainProduksi.routeName}?selectedIndex=2',
            ),
            const SizedBox(height: 24.0),
            _buildSearchBar(),
            const SizedBox(
              height: 16.0,
            ),
            buildDateRangeSelector(),
            const SizedBox(height: 16.0),
            _buildProductionOrderList(),
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

  Widget buildDateRangeSelector() {
    return Row(
      children: [
        Expanded(
          child: DatePickerButton(
            label: 'Tanggal Mulai',
            selectedDate: selectedStartDate,
            onDateSelected: (newDate) {
              setState(() {
                selectedStartDate = newDate;
              });
            },
          ),
        ),
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

  Widget _buildProductionOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: productionOrderRef
          .orderBy('tanggal_rencana', descending: true)
          .snapshots(),
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
          return const Text('Tidak ada data perintah produksi.');
        } else {
          final querySnapshot = snapshot.data!;
          final itemDocs = querySnapshot.docs;

          // Anda perlu mendapatkan data 'material_usages' dari Firestore
          final materialUsagesRef =
              FirebaseFirestore.instance.collection('material_usages');

          return StreamBuilder<QuerySnapshot>(
            stream: materialUsagesRef.snapshots(),
            builder: (context, materialUsagesSnapshot) {
              if (materialUsagesSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                );
              } else if (materialUsagesSnapshot.hasError) {
                return Text('Error: ${materialUsagesSnapshot.error}');
              } else if (!materialUsagesSnapshot.hasData ||
                  materialUsagesSnapshot.data?.docs.isEmpty == true) {
                return const Text('Tidak ada data material usages.');
              } else {
                final materialUsagesQuerySnapshot =
                    materialUsagesSnapshot.data!;
                final materialUsagesDocs = materialUsagesQuerySnapshot.docs;

                final filteredDocs = itemDocs.where((doc) {
                  final keterangan = doc['id'] as String;
                  final status = doc['status_pro'] as String;
                  final tanggalRencana = doc['tanggal_rencana'] as Timestamp;
                  final tanggalProduksi = doc['tanggal_produksi'] as Timestamp;
                  final statusDoc = doc['status'] as int;

                  bool isWithinDateRange = true;
                  if (selectedStartDate != null && selectedEndDate != null) {
                    isWithinDateRange = (tanggalRencana
                                .toDate()
                                .isAfter(selectedStartDate!) &&
                            tanggalRencana
                                .toDate()
                                .isBefore(selectedEndDate!)) ||
                        (tanggalProduksi.toDate().isAfter(selectedStartDate!) &&
                            tanggalProduksi
                                .toDate()
                                .isBefore(selectedEndDate!));
                  }

                  return (keterangan
                          .toLowerCase()
                          .contains(searchTerm.toLowerCase()) &&
                      (selectedStatus.isEmpty || status == selectedStatus) &&
                      isWithinDateRange &&
                      statusDoc == 1);
                }).toList();

                // Implementasi Pagination
                final endIndex = startIndex + itemsPerPage;
                final paginatedDocs = filteredDocs.sublist(
                  startIndex,
                  endIndex < filteredDocs.length
                      ? endIndex
                      : filteredDocs.length,
                );

                // Mengatur tombol "Prev" dan "Next"
                isPrevButtonDisabled = startIndex == 0;
                isNextButtonDisabled = endIndex >= filteredDocs.length;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: paginatedDocs.length,
                      itemBuilder: (context, index) {
                        final data =
                            paginatedDocs[index].data() as Map<String, dynamic>;
                        final id = data['id'] as String;
                        // Dapatkan batch yang sesuai dengan produksi
                        final batch = findBatch(materialUsagesDocs, data['id']);
                        // Dapatkan nilai progress bar
                        final progressBarValue = calculateProgressBarValue(
                            materialUsagesDocs,
                            data['id'],
                            batch,
                            data['status_pro']);

                        final info = {
                          'ID Produk': data['product_id'],
                          'ID BOM': data['bom_id'],
                          'Tanggal Perintah Produksi': DateFormat('dd/MM/yyyy')
                              .format((data['tanggal_rencana'] as Timestamp)
                                  .toDate()),
                          'Tanggal Produksi': DateFormat('dd/MM/yyyy').format(
                              (data['tanggal_produksi'] as Timestamp).toDate()),
                          'Catatan': data['catatan'],
                          'Status': data['status_pro'],
                          'Current Batch': batch
                        };
                        return ListCard(
                          title: id,
                          description: info.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join('\n'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FormPerintahProduksiScreen(
                                  productionOrderId: data['id'],
                                  productId: data['product_id'],
                                  statusPro: data['status_pro'],
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
                                      "Anda yakin ingin menghapus perintah produksi ini?"),
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
                                        final productionOrderBloc = BlocProvider
                                            .of<ProductionOrderBloc>(context);
                                        productionOrderBloc.add(
                                            DeleteProductionOrderEvent(
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
                          status: data['status_pro'],
                          progressBarValue: progressBarValue,
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
                                    if (startIndex >= filteredDocs.length) {
                                      startIndex =
                                          filteredDocs.length - itemsPerPage;
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
      },
    );
  }

  String findBatch(List<QueryDocumentSnapshot> materialUsagesDocs,
      String productionOrderId) {
    if (materialUsagesDocs.any((usage) =>
        usage['production_order_id'] == productionOrderId &&
        usage['batch'] == 'Pencetakan')) {
      return 'Pencetakan'; // Jika batch 'Pencetakan' ada, progress bar 90%
    } else if (materialUsagesDocs.any((usage) =>
        usage['production_order_id'] == productionOrderId &&
        usage['batch'] == 'Sheet')) {
      return 'Sheet'; // Jika batch 'Sheet' ada, progress bar 50%
    } else {
      return 'Pencampuran'; // Jika keduanya tidak ada, progress bar 0%
    }
  }

  double calculateProgressBarValue(
      List<QueryDocumentSnapshot> materialUsagesDocs,
      String productionOrderId,
      String productionOrderBatch,
      String productionOrderStatus) {
    if (materialUsagesDocs.any((usage) =>
            usage['production_order_id'] == productionOrderId &&
            usage['batch'] == 'Pencetakan') &&
        productionOrderStatus == "Dalam Proses") {
      return 0.9; // Jika batch 'Pencetakan' ada, progress bar 90%
    } else if (materialUsagesDocs.any((usage) =>
            usage['production_order_id'] == productionOrderId &&
            usage['batch'] == 'Sheet') &&
        productionOrderStatus == "Dalam Proses") {
      return 0.6; // Jika batch 'Sheet' ada, progress bar 60%
    } else if (productionOrderStatus == "Selesai") {
      return 1.0;
    } else {
      return 0.3; // Jika keduanya tidak ada, progress bar 30%
    }
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          title: ('Filter Berdasarkan Status Perintah Produksi'),
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
