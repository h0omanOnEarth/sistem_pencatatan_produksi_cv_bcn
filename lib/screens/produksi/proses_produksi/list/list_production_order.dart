import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/production_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/form/form_perintah_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListProductionOrder extends StatefulWidget {
  static const routeName = '/list_production_order_screen';

  const ListProductionOrder({super.key});
  @override
  State<ListProductionOrder> createState() => _ListProductionOrderState();
}

class _ListProductionOrderState extends State<ListProductionOrder> {
  final CollectionReference productionOrderRef = FirebaseFirestore.instance.collection('production_orders');
  String searchTerm = '';
  String selectedStatus = '';
  Timestamp? selectedStartDate;
  Timestamp? selectedEndDate;
  String startDateText = ''; // Tambahkan variabel untuk menampilkan tanggal filter
  String endDateText = '';   // Tambahkan variabel untuk menampilkan tanggal filter

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
                SizedBox(
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
                              'Perintah Produksi',
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
                                      builder: (context) => const FormPerintahProduksiScreen(),
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
                ),
                const SizedBox(height: 24.0), 
                Row(
                  children: [
                    SizedBox(
                      width: screenWidth * 0.6,
                      child: SearchBarWidget(searchTerm: searchTerm, onChanged: (value) {
                        setState(() {
                          searchTerm = value;
                        });
                      }),
                    ),
                    const SizedBox(width: 16.0),// Add spacing between calendar icon and filter button
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
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Column(
                      children: [
                      const Text( "Tanggal Mulai: ",style: TextStyle( fontWeight: FontWeight.bold,),),
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
                      const SizedBox(width: 16.0), // Add spacing between calendar icon and filter button
                      Text(startDateText), 
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      children: [
                          const Text( "Tanggal Selesai: ",style: TextStyle( fontWeight: FontWeight.bold,),),
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
                const SizedBox(height: 16.0),
                StreamBuilder<QuerySnapshot>(
                  stream: productionOrderRef.snapshots(),
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

                      final filteredDocs = itemDocs.where((doc) {
                        final keterangan = doc['id'] as String;
                        final status = doc['status_pro'] as String;
                        final tanggalRencana = doc['tanggal_rencana'] as Timestamp; // Tanggal Pesan
                        final tanggalProduksi = doc['tanggal_produksi'] as Timestamp; // Tanggal Kirim

                        bool isWithinDateRange = true;
                        if (selectedStartDate != null && selectedEndDate != null) {
                          isWithinDateRange = (tanggalRencana.toDate().isAfter(selectedStartDate!.toDate()) && tanggalRencana.toDate().isBefore(selectedEndDate!.toDate())) ||
                              (tanggalProduksi.toDate().isAfter(selectedStartDate!.toDate()) && tanggalProduksi.toDate().isBefore(selectedEndDate!.toDate()));
                        }

                        return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                            (selectedStatus.isEmpty || status == selectedStatus) &&
                            isWithinDateRange);
                      }).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final data = filteredDocs[index].data() as Map<String, dynamic>;
                          final id = data['id'] as String;
                          final info = {
                            'Id': data['id'],
                            'Tanggal Perintah Produksi': DateFormat('dd/MM/yyyy').format((data['tanggal_rencana'] as Timestamp).toDate()), // Format tanggal
                            'Tanggal Produksi': DateFormat('dd/MM/yyyy').format((data['tanggal_produksi'] as Timestamp).toDate()), // Format tanggal
                          };
                          return ListCard(
                            title: id,
                            description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormPerintahProduksiScreen(
                                    productionOrderId: data['id'],
                                    productId: data['product_id'],
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
                                    content: const Text("Anda yakin ingin menghapus perintah produksi ini?"),
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
                                          final productionOrderBloc = BlocProvider.of<ProductionOrderBloc>(context);
                                          productionOrderBloc.add(DeleteProductionOrderEvent(filteredDocs[index].id));
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
        startDateText = '${DateFormat('dd/MM/yyyy').format(pickedDate)}'; // Tambahkan ini
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
        endDateText = '${DateFormat('dd/MM/yyyy').format(pickedDate)}'; // Tambahkan ini
      });
    }
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter Berdasarkan Status Perintah Produksi'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Dalam Proses');
              },
              child: const Text('Dalam Proses'),
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
