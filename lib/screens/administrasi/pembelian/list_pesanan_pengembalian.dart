import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/sidebar_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPesananPengembalianPembelian extends StatefulWidget {
  static const routeName = '/administrasi/pembelian/pengembalian/list';

  const ListPesananPengembalianPembelian({super.key});
  @override
  State<ListPesananPengembalianPembelian> createState() =>
      _ListPesananPengembalianPembelianState();
}

class _ListPesananPengembalianPembelianState
    extends State<ListPesananPengembalianPembelian> {
  final CollectionReference purchaseReturnRef =
      FirebaseFirestore.instance.collection('purchase_returns');
  String searchTerm = '';
  String selectedStatus = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String startDateText =
      ''; // Tambahkan variabel untuk menampilkan tanggal filter
  String endDateText =
      ''; // Tambahkan variabel untuk menampilkan tanggal filter

  // Tambahkan variabel untuk pengaturan halaman data
  int itemsPerPage = 5;
  int startIndex = 0;
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;
  int _selectedIndex = 2;
  bool _isSidebarCollapsed = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PurchaseReturnBloc, PurchaseReturnBlocState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            setState(() {
              isLoading = false; // Matikan isLoading saat successState
            });
          } else if (state is ErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            );
          } else if (state is LoadingState) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is! LoadingState) {
            setState(() {
              isLoading = false;
            });
          }
        },
        child: Scaffold(
          body: SafeArea(
              child: Stack(
            children: [
              Center(
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
              if (isLoading)
                Positioned(
                  // Menambahkan Positioned untuk indikator loading
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.3), // Latar belakang semi-transparan
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          )),
        ));
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
                      title: 'Pesanan Pengembalian',
                      formScreen: FormPengembalianPesananScreen(),
                      routes: '${MainAdministrasi.routeName}?selectedIndex=2'),
                  const SizedBox(height: 24.0),
                  _buildSearchBar(),
                  const SizedBox(height: 16.0),
                  buildDateRangeSelector(),
                  const SizedBox(height: 16.0),
                  _buildPurchaseReturnList(),
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
        .push('${MainAdministrasi.routeName}?selectedIndex=$index');
  }

  Widget _buildMobileContent() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CustomAppBar(
                title: 'Pesanan Pengembalian',
                formScreen: FormPengembalianPesananScreen(),
                routes: '${MainAdministrasi.routeName}?selectedIndex=2'),
            const SizedBox(height: 24.0),
            _buildSearchBar(),
            const SizedBox(
              height: 16.0,
            ),
            buildDateRangeSelector(),
            const SizedBox(height: 16.0),
            _buildPurchaseReturnList(),
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

  Widget _buildPurchaseReturnList() {
    return StreamBuilder<QuerySnapshot>(
      stream: purchaseReturnRef.orderBy('id', descending: false).snapshots(),
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
            final alasan = doc['alasan'] as String;
            final status = doc['jenis_bahan'] as String;
            final statusDoc = doc['status'] as int;
            final tanggalPengembalian = doc['tanggal_pengembalian']
                as Timestamp; // Tanggal Pengembalian

            bool isWithinDateRange = true;
            if (selectedStartDate != null && selectedEndDate != null) {
              isWithinDateRange =
                  (tanggalPengembalian.toDate().isAfter(selectedStartDate!) &&
                      tanggalPengembalian.toDate().isBefore(selectedEndDate!));
            }

            return (alasan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                (selectedStatus.isEmpty || status == selectedStatus) &&
                isWithinDateRange &&
                statusDoc == 1);
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
            children: [
              ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: paginatedDocs.length,
                itemBuilder: (context, index) {
                  final data =
                      paginatedDocs[index].data() as Map<String, dynamic>;
                  final id = data['id'] as String;
                  final info = {
                    'ID Pembelian': data['purchase_order_id'],
                    'Tanggal Pengembalian': DateFormat('dd/MM/yyyy').format(
                        (data['tanggal_pengembalian'] as Timestamp).toDate()),
                    'Jumlah Pengembalian':
                        '${data['jumlah']} ${data['satuan']}',
                    'Alasan': data['alasan'],
                    'Catatan': data['keterangan']
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
                          builder: (context) => FormPengembalianPesananScreen(
                            purchaseReturnId: data['id'],
                            purchaseOrderId: data[
                                'purchase_order_id'], // Mengirimkan ID pesanan pelanggan
                            qtyLama: data['jumlah'],
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
                                  final purchaseReturnBloc =
                                      BlocProvider.of<PurchaseReturnBloc>(
                                          context);
                                  purchaseReturnBloc.add(
                                      DeletePurchaseReturnEvent(data['id']));
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
              const SizedBox(
                height: 16.0,
              ),
              if (filteredDocs.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: isPrevButtonDisabled
                          ? null
                          : () {
                              setState(() {
                                startIndex = (startIndex - itemsPerPage)
                                    .clamp(0, filteredDocs.length);
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .brown, // Mengubah warna latar belakang menjadi cokelat
                      ),
                      child: const Text('Prev'),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: isNextButtonDisabled
                          ? null
                          : () {
                              setState(() {
                                startIndex = (startIndex + itemsPerPage)
                                    .clamp(0, filteredDocs.length);
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .brown, // Mengubah warna latar belakang menjadi cokelat
                      ),
                      child: const Text('Next'),
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
          title: const Text('Filter Berdasarkan Jenis Bahan'),
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
        selectedStatus = selectedValue;
      });
    }
  }
}
