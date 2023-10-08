import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/pesanan_pembelian_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPesananPembelian extends StatefulWidget {
  static const routeName = '/list_pesanan_pembelian_screen';

  const ListPesananPembelian({Key? key}) : super(key: key);

  @override
  State<ListPesananPembelian> createState() => _ListPesananPembelianState();
}

class _ListPesananPembelianState extends State<ListPesananPembelian> {
  final CollectionReference purchaseOrderRef = FirebaseFirestore.instance.collection('purchase_orders');
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

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomAppBar(title: 'Pesanan Pembelian', formScreen: FormPesananPembelianScreen()),
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


Widget _buildPurchaseOrderList() {
  return StreamBuilder<QuerySnapshot>(
    stream: purchaseOrderRef.orderBy('id').snapshots(),
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
            isWithinDateRange = (tanggalPesan.toDate().isAfter(selectedStartDate!) &&
                tanggalPesan.toDate().isBefore(selectedEndDate!)) ||
                (tanggalKirim.toDate().isAfter(selectedStartDate!) &&
                    tanggalKirim.toDate().isBefore(selectedEndDate!));
          }

          return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
              (selectedStatus.isEmpty || status == selectedStatus) &&
              isWithinDateRange);
        }).toList();

        // Urutkan data berdasarkan tanggal pesan
        filteredDocs.sort((a, b) {
          final tanggalPesanA = (a['tanggal_pesan'] as Timestamp).toDate();
          final tanggalPesanB = (b['tanggal_pesan'] as Timestamp).toDate();
          return tanggalPesanA.compareTo(tanggalPesanB);
        });

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
            const SizedBox(height: 16.0,),
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
