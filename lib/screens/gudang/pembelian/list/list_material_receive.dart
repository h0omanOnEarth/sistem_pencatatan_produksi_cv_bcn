import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/purchase_request_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/form/form_penerimaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMaterialReceive extends StatefulWidget {
  static const routeName = '/list_material_receive_screen';

  const ListMaterialReceive({super.key});
  @override
  State<ListMaterialReceive> createState() => _ListMaterialReceiveState();
}

class _ListMaterialReceiveState extends State<ListMaterialReceive> {
  final CollectionReference purchaseReqRef = FirebaseFirestore.instance.collection('material_receives');
  String searchTerm = '';
  int selectedStatus = -1;
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
                const CustomAppBar(title: 'Penerimaan Bahan', formScreen: FormPenerimaanBahanScreen()),
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
                      return const Text('Tidak ada data penerimaan bahan.');
                    } else {
                      final querySnapshot = snapshot.data!;
                      final itemDocs = querySnapshot.docs;

                      final filteredDocs = itemDocs.where((doc) {
                        final keterangan = doc['id'] as String;
                        final status = doc['status'] as int;
                        final tanggalRencana = doc['tanggal_penerimaan'] as Timestamp; // Tanggal Pesan

                        bool isWithinDateRange = true;
                        if (selectedStartDate != null && selectedEndDate != null) {
                          isWithinDateRange = (tanggalRencana.toDate().isAfter(selectedStartDate!.toDate()) && tanggalRencana.toDate().isBefore(selectedEndDate!.toDate()));
                        }

                        return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                            (selectedStatus.toInt() == -1 || status == selectedStatus) &&
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
                            'Tanggal Penerimaan': DateFormat('dd/MM/yyyy').format((data['tanggal_penerimaan'] as Timestamp).toDate()), // Format tanggal
                            'Id Bahan' : data['material_id']
                          };
                          return ListCard(
                            title: id,
                            description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormPenerimaanBahanScreen(
                                    purchaseRequestId: data['purchase_request_id'],
                                    materialReceiveId: data['id'],
                                    materialId: data['material_id'],
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
                                    content: const Text("Anda yakin ingin menghapus penerimaan bahan ini?"),
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
                                          final purReqBloc = BlocProvider.of<PurchaseRequestBloc>(context);
                                          purReqBloc.add(DeletePurchaseRequestEvent(filteredDocs[index].id));
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
    String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter Berdasarkan Penerimaan Bahan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Aktif');
              },
              child: const Text('Aktif'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Tidak Aktif');
              },
              child: const Text('Tidak Aktif'),
            ),
          ],
        );
      },
    );

    if (selectedValue != null) {
      setState(() {
        selectedStatus = (selectedValue == 'Aktif') ? 1 : (selectedValue == 'Tidak Aktif') ? 0 : -1;
      });
    }
  }

}