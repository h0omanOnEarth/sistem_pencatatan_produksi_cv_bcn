import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPesananPengembalianPembelian extends StatefulWidget {
  static const routeName = '/list_pengembalian_pembelian_screen';

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
  Timestamp? selectedStartDate;
  Timestamp? selectedEndDate;
  String startDateText = ''; // Tambahkan variabel untuk menampilkan tanggal filter
  String endDateText = ''; // Tambahkan variabel untuk menampilkan tanggal filter

  // Tambahkan variabel untuk pengaturan halaman data
  int itemsPerPage = 5;
  int startIndex = 0;
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
                 const CustomAppBar(title: 'Pesanan Pengembalian', formScreen: FormPengembalianPesananScreen()),
                const SizedBox(height: 24.0),
                Row(
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
                ),
                const SizedBox(
                  height: 16.0,
                ),
                Row(
                  children: [
                    Column(
                      children: [
                        const Text(
                          "Tanggal Mulai:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              _selectStartDate(context);
                            },
                          ),
                        ),
                        Text(startDateText),
                      ],
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      children: [
                        const Text(
                          "Tanggal Selesai:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[400]!),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () {
                              _selectEndDate(context);
                            },
                          ),
                        ),
                        Text(endDateText),
                      ],
                    )
                  ],
                ),
                //cards
                const SizedBox(
                  height: 16.0,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: purchaseReturnRef.
                  orderBy('id', descending: false).
                  snapshots(),
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
                      return const Text('Tidak ada data pesanan.');
                    } else {
                      final querySnapshot = snapshot.data!;
                      final itemDocs = querySnapshot.docs;

                      final filteredDocs = itemDocs.where((doc) {
                        final alasan = doc['alasan'] as String;
                        final status = doc['jenis_bahan'] as String;
                        final tanggalPengembalian =
                            doc['tanggal_pengembalian'] as Timestamp; // Tanggal Pengembalian

                        bool isWithinDateRange = true;
                        if (selectedStartDate != null &&
                            selectedEndDate != null) {
                          isWithinDateRange = (tanggalPengembalian
                                  .toDate()
                                  .isAfter(selectedStartDate!.toDate()) &&
                              tanggalPengembalian
                                  .toDate()
                                  .isBefore(selectedEndDate!.toDate()));
                        }

                        return (alasan.toLowerCase().contains(
                                searchTerm.toLowerCase()) &&
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
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: paginatedDocs.length,
                            itemBuilder: (context, index) {
                              final data = paginatedDocs[index]
                                  .data() as Map<String, dynamic>;
                              final id = data['id'] as String;
                              final info = {
                                'Tanggal Pengembalian': DateFormat('dd/MM/yyyy')
                                    .format((data['tanggal_pengembalian']
                                            as Timestamp)
                                        .toDate()),
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
                                          FormPengembalianPesananScreen(
                                        purchaseReturnId: data['id'],
                                        purchaseOrderId:
                                            data['purchase_order_id'], // Mengirimkan ID pesanan pelanggan
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
                                                  BlocProvider.of<
                                                      PurchaseReturnBloc>(
                                                      context);
                                              purchaseReturnBloc.add(
                                                  DeletePurchaseReturnEvent(
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
                            },
                          ),
                          const SizedBox(height: 16.0,),
                          if (filteredDocs.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: isPrevButtonDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            startIndex =
                                                (startIndex - itemsPerPage)
                                                    .clamp(0, startIndex);
                                          });
                                        },
                                  style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.brown, // Mengubah warna latar belakang menjadi cokelat
                                ),
                                  child: const Text('Prev'),
                                ),
                                const SizedBox(width: 16.0),
                                ElevatedButton(
                                  onPressed: isNextButtonDisabled
                                      ? null
                                      : () {
                                          setState(() {
                                            startIndex =
                                                (startIndex + itemsPerPage)
                                                    .clamp(0, filteredDocs.length);
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
                ),
              ],
            ),
          ),
        ),
      ),
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
        startDateText =
            DateFormat('dd/MM/yyyy').format(pickedDate); // Tambahkan ini
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
        endDateText =
            DateFormat('dd/MM/yyyy').format(pickedDate); // Tambahkan ini
      });
    }
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
