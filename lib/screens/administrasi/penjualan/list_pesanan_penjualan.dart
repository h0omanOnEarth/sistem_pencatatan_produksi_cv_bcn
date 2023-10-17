import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/pesanan_pelanggan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/form_pesanan_penjualan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/sidebar_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/filter_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPesananPelanggan extends StatefulWidget {
  static const routeName = '/administrasi/penjualan/pesanan/list';

  const ListPesananPelanggan({super.key});
  @override
  State<ListPesananPelanggan> createState() => _ListPesananPelangganState();
}

class _ListPesananPelangganState extends State<ListPesananPelanggan> {
  final CollectionReference customerOrderRef = FirebaseFirestore.instance.collection('customer_orders');
  String searchTerm = '';
  String selectedStatus = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String startDateText = ''; // Tambahkan variabel untuk menampilkan tanggal filter
  String endDateText = '';   // Tambahkan variabel untuk menampilkan tanggal filter
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
                const CustomAppBar(title: 'Pesanan Pelanggan', formScreen: FormPesananPelangganScreen(), routes: '${MainAdministrasi.routeName}?selectedIndex=3',),
                const SizedBox(height: 24.0),
                _buildSearchBar(),
                const SizedBox(height: 16.0),
                buildDateRangeSelector(),
                const SizedBox(height: 16.0),
                _buildCustomerOrderList(),
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
  // final mainAdminsitrasiScreen = MainAdministrasi(selectedIndex: index);
  // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => mainAdminsitrasiScreen));
  Routemaster.of(context).push('${MainAdministrasi.routeName}?selectedIndex=$index');
}


Widget _buildMobileContent() {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppBar(title: 'Pesanan Pelanggan', formScreen: FormPesananPelangganScreen(), routes: '${MainAdministrasi.routeName}?selectedIndex=3',),
          const SizedBox(height: 24.0),
          _buildSearchBar(),
          const SizedBox(height: 16.0,),
          buildDateRangeSelector(),
          const SizedBox(height: 16.0),
          _buildCustomerOrderList(),
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
        const SizedBox(width: 16.0), 
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

  Widget _buildCustomerOrderList() {
    return  StreamBuilder<QuerySnapshot>(
      stream: customerOrderRef.snapshots(),
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
          return const Text('Tidak ada data pesanan.');
        } else {
          final querySnapshot = snapshot.data!;
          final itemDocs = querySnapshot.docs;

          final filteredDocs = itemDocs.where((doc) {
            final id = doc['id'] as String;
            final status = doc['status_pesanan'] as String;
            final tanggalPesan = doc['tanggal_pesan'] as Timestamp; // Tanggal Pesan
            final tanggalKirim = doc['tanggal_kirim'] as Timestamp; // Tanggal Kirim

            bool isWithinDateRange = true;
            if (selectedStartDate != null && selectedEndDate != null) {
              isWithinDateRange = (tanggalPesan.toDate().isAfter(selectedStartDate!) && tanggalPesan.toDate().isBefore(selectedEndDate!)) ||
                  (tanggalKirim.toDate().isAfter(selectedStartDate!) && tanggalKirim.toDate().isBefore(selectedEndDate!));
            }

            return (id.toLowerCase().contains(searchTerm.toLowerCase()) &&
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
                    'Customer ID': data['customer_id'],
                    'Tanggal Pesan': DateFormat('dd/MM/yyyy').format((data['tanggal_pesan'] as Timestamp).toDate()), // Format tanggal
                    'Tanggal Kirim': DateFormat('dd/MM/yyyy').format((data['tanggal_kirim'] as Timestamp).toDate()), // Format tanggal
                    'Total Harga': data['total_harga'],
                    'Total Produk': '${data['total_produk']} ${data['satuan']}',
                    'Catatan': data['catatan'],
                    'Status': data['status_pesanan'],
                  };
                  return ListCard(
                    title: id,
                    description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPesananPelangganScreen(
                            customerOrderId: data['id'], // Mengirimkan ID customer order
                            customerId: data['customer_id'],
                            statusCO: data['status_pesanan'],
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
                            content: const Text("Anda yakin ingin menghapus pesanan penjualan ini?"),
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
                                  final customerOrderBloc = BlocProvider.of<CustomerOrderBloc>(context);
                                  customerOrderBloc.add(DeleteCustomerOrderEvent(paginatedDocs[index].id));
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
                    status: data['status_pesanan'],
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
          title: ('Filter Berdasarkan Status Penjualan'),
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
