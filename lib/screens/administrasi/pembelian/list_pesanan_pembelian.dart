import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/pesanan_pembelian_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/calendarFilterWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPesananPembelian extends StatefulWidget {
  static const routeName = '/list_pesanan_pembelian_screen';

  const ListPesananPembelian({Key? key}) : super(key: key);

  @override
  State<ListPesananPembelian> createState() => _ListPesananPembelianState();
}

class _ListPesananPembelianState extends State<ListPesananPembelian> {
  final CollectionReference purchaseOrderRef =
      FirebaseFirestore.instance.collection('purchase_orders');
  String searchTerm = '';
  String selectedStatus = '';
  Timestamp? selectedStartDate;
  Timestamp? selectedEndDate;
  String startDateText = '';
  String endDateText = '';
  int startIndex = 0; // Indeks awal data yang ditampilkan
  int itemsPerPage = 3; // Jumlah data per halaman
  bool isPrevButtonDisabled = true;
  bool isNextButtonDisabled = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppBar(screenWidth),
                const SizedBox(height: 24.0),
                _buildSearchBar(),
                const SizedBox(height: 16.0,),
                buildDateRangeSelector(),
                const SizedBox(height: 16.0),
                _buildPurchaseOrderList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(double screenWidth) {
    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),
                const Text(
                  'Pesanan Pembelian',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: screenWidth * 0.20),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FormPesananPembelianScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      children: [
        SizedBox(
          width: screenWidth * 0.6,
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
        DateSelector(
          labelText: 'Tanggal Mulai: ',
          onPressed: () {
            _selectStartDate(context);
          },
          dateText: startDateText,
        ),
        const SizedBox(width: 16.0),
        DateSelector(
          labelText: 'Tanggal Selesai: ',
          onPressed: () {
            _selectEndDate(context);
          },
          dateText: endDateText,
        ),
      ],
    );
  }


  Widget _buildPurchaseOrderList() {
    return StreamBuilder<QuerySnapshot>(
      stream: purchaseOrderRef.snapshots(),
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
            final keterangan = doc['keterangan'] as String;
            final status = doc['status_pembayaran'] as String;
            final tanggalPesan = doc['tanggal_pesan'] as Timestamp;
            final tanggalKirim = doc['tanggal_kirim'] as Timestamp;

            bool isWithinDateRange = true;
            if (selectedStartDate != null && selectedEndDate != null) {
              isWithinDateRange = (tanggalPesan.toDate().isAfter(selectedStartDate!.toDate()) &&
                  tanggalPesan.toDate().isBefore(selectedEndDate!.toDate())) ||
                  (tanggalKirim.toDate().isAfter(selectedStartDate!.toDate()) &&
                      tanggalKirim.toDate().isBefore(selectedEndDate!.toDate()));
            }

            return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                (selectedStatus.isEmpty || status == selectedStatus) &&
                isWithinDateRange);
          }).toList();

          // Menghitung total halaman berdasarkan jumlah data dan item per halaman
          int totalPages = (filteredDocs.length / itemsPerPage).ceil();
          if (totalPages < 1) totalPages = 1;

          // Menghitung indeks akhir data yang ditampilkan
          int endIndex = startIndex + itemsPerPage;
          if (endIndex > filteredDocs.length) {
            endIndex = filteredDocs.length;
            isNextButtonDisabled = true;
          } else {
            isNextButtonDisabled = false;
          }

          // Memotong data yang akan ditampilkan berdasarkan indeks awal dan akhir
          final displayedDocs = filteredDocs.sublist(startIndex, endIndex);

          // Tombol "Prev" hanya aktif jika indeks awal lebih besar dari 0
          if (startIndex <= 0) {
            isPrevButtonDisabled = true;
          } else {
            isPrevButtonDisabled = false;
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: displayedDocs.length,
                itemBuilder: (context, index) {
                  final data = displayedDocs[index].data() as Map<String, dynamic>;
                  final id = data['id'] as String;
                  final info = {
                    'Tanggal Pesan': DateFormat('dd/MM/yyyy').format(
                        (data['tanggal_pesan'] as Timestamp).toDate()),
                    'Tanggal Kirim': DateFormat('dd/MM/yyyy').format(
                        (data['tanggal_kirim'] as Timestamp).toDate()),
                  };
                  return ListCard(
                    title: id,
                    description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPesananPembelianScreen(
                            purchaseOrderId: data['id'],
                            supplierId: data['supplier_id'],
                            bahanId: data['material_id'],
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
                            content: const Text("Anda yakin ingin menghapus pesanan pembelian ini?"),
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
                                  final purchaseOrderBloc = BlocProvider.of<PurchaseOrderBloc>(context);
                                  purchaseOrderBloc.add(DeletePurchaseOrderEvent(data['id']));
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
              // Tombol Prev dan Next
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isPrevButtonDisabled
                        ? null
                        : () {
                      setState(() {
                        startIndex -= itemsPerPage;
                        // Tombol "Next" harus diaktifkan setelah pembaruan indeks
                        isNextButtonDisabled = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
                    ),
                    child: const Text('Prev'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: isNextButtonDisabled
                        ? null
                        : () {
                      setState(() {
                        startIndex += itemsPerPage;
                        // Tombol "Prev" harus diaktifkan setelah pembaruan indeks
                        isPrevButtonDisabled = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
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

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedStartDate?.toDate() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedStartDate?.toDate()) {
      setState(() {
        selectedStartDate = Timestamp.fromDate(pickedDate);
        startDateText = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedEndDate?.toDate() ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedEndDate?.toDate()) {
      setState(() {
        selectedEndDate = Timestamp.fromDate(pickedDate);
        endDateText = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter Berdasarkan Status Pembayaran'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Belum Bayar');
              },
              child: const Text('Belum Bayar'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Selesai');
              },
              child: const Text('Selesai'),
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
