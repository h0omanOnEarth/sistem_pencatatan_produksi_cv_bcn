import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/surat_jalan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/penjualan/form/form_surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/filter_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListSuratJalan extends StatefulWidget {
  static const routeName = '/list_surat_jalan_screen';

  const ListSuratJalan({super.key});
  @override
  State<ListSuratJalan> createState() => _ListSuratJalanState();
}

class _ListSuratJalanState extends State<ListSuratJalan> {
  final CollectionReference purchaseReqRef = FirebaseFirestore.instance.collection('shipments');
  String searchTerm = '';
  String selectedStatus ='';
  Timestamp? selectedStartDate;
  Timestamp? selectedEndDate;
  String startDateText = ''; // Tambahkan variabel untuk menampilkan tanggal filter
  String endDateText = '';   // Tambahkan variabel untuk menampilkan tanggal filter

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
                const CustomAppBar(title: 'Surat Jalan', formScreen: FormSuratJalanScreen()),
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
                      return const Text('Tidak ada data surat jalan');
                    } else {
                      final querySnapshot = snapshot.data!;
                      final itemDocs = querySnapshot.docs;

                      final filteredDocs = itemDocs.where((doc) {
                        final keterangan = doc['id'] as String;
                        final status = doc['status_shp'] as String;
                        final tanggalPembuatan = doc['tanggal_pembuatan'] as Timestamp; // Tanggal Pesan

                        bool isWithinDateRange = true;
                        if (selectedStartDate != null && selectedEndDate != null) {
                          isWithinDateRange = (tanggalPembuatan.toDate().isAfter(selectedStartDate!.toDate()) && tanggalPembuatan.toDate().isBefore(selectedEndDate!.toDate()));
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
                            'Tanggal Pembuatan': DateFormat('dd/MM/yyyy').format((data['tanggal_pembuatan'] as Timestamp).toDate()), // Format tanggal
                            'Alamat Penerima' : data['alamat_penerima']
                          };
                          return ListCard(
                            title: id,
                            description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormSuratJalanScreen(
                                    shipmentId: data['id'],
                                    deliveryId: data['delivery_order_id'],
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
                                    content: const Text("Anda yakin ingin menghapus surat jalan ini?"),
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
                                          final shipmentBloc = BlocProvider.of<ShipmentBloc>(context);
                                          shipmentBloc.add(DeleteShipmentEvent(filteredDocs[index].id));
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
        startDateText = DateFormat('dd/MM/yyyy').format(pickedDate); // Tambahkan ini
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
        endDateText = DateFormat('dd/MM/yyyy').format(pickedDate); // Tambahkan ini
      });
    }
  }

   Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          title: ('Filter Berdasarkan Status Surat Jalan'),
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
