import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/material_transforms_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/produksi/form/form_pengubahan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/filter_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/listCardFinishedDelete.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListPengubahanBahan extends StatefulWidget {
  static const routeName = '/list_pengubahan_bahan_screen';

  const ListPengubahanBahan({super.key});
  @override
  State<ListPengubahanBahan> createState() => _ListPengubahanBahanState();
}

class _ListPengubahanBahanState extends State<ListPengubahanBahan> {
  final CollectionReference custReturnReqRef = FirebaseFirestore.instance.collection('material_transforms');
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
                const CustomAppBar(title: 'Pengubahan Bahan', formScreen: FormPengubahanBahan()),
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
                ),
                //cards
                const SizedBox(height: 16.0),
                StreamBuilder<QuerySnapshot>(
                  stream: custReturnReqRef.snapshots(),
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
                      return const Text('Tidak ada data pengubahan bahan');
                    } else {
                      final querySnapshot = snapshot.data!;
                      final itemDocs = querySnapshot.docs;

                      final filteredDocs = itemDocs.where((doc) {
                        final keterangan = doc['id'] as String;
                        final status = doc['status_mtf'] as String;
                        final tanggalPembuatan = doc['tanggal_pengubahan'] as Timestamp; // Tanggal Pesan

                        bool isWithinDateRange = true;
                        if (selectedStartDate != null && selectedEndDate != null) {
                          isWithinDateRange = (tanggalPembuatan.toDate().isAfter(selectedStartDate!) && tanggalPembuatan.toDate().isBefore(selectedEndDate!));
                        }

                        return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                            (selectedStatus.isEmpty || status == selectedStatus) &&
                            isWithinDateRange);
                      }).toList();

                      // Perbarui status tombol Prev dan Next
                      isPrevButtonDisabled = startIndex == 0;
                      isNextButtonDisabled = startIndex + itemsPerPage >= filteredDocs.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: (filteredDocs.length - startIndex).clamp(0, itemsPerPage),
                            itemBuilder: (context, index) {
                              final data = filteredDocs[startIndex + index].data() as Map<String, dynamic>;
                              final id = data['id'] as String;
                              final info = {
                                'ID Mesin' : data['machine_id'],
                                'Tanggal Pengubahan': DateFormat('dd/MM/yyyy').format((data['tanggal_pengubahan'] as Timestamp).toDate()), // Format tanggal
                                'Jumlah Hasil': '${data['jumlah_hasil']} ${data['satuan_hasil']}',
                                'Total Hasil': '${data['total_hasil']} ${data['satuan_total_hasil']}',
                                'Catatan' : data['catatan'],
                                'Status': data['status_mtf']
                              };
                              return ListCardFinishedDelete(
                                title: id,
                                description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FormPengubahanBahan(
                                        materialTransformId: data['id'],
                                        machineId: data['machine_id'],
                                      )
                                    )
                                  );
                                },
                                onDeletePressed: () async {
                                  final confirmed = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text("Konfirmasi Hapus"),
                                        content: const Text("Anda yakin ingin menghapus pengubahan bahan ini?"),
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
                                              final materialTransformBloc = BlocProvider.of<MaterialTransformsBloc>(context);
                                              materialTransformBloc.add(DeleteMaterialTransformsEvent(filteredDocs[startIndex + index].id));
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
                                onFinished: () async{

                                },
                                status: data['status_mtf'],
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FilterDialog(
          title: ('Filter Berdasarkan Status Pengubahan Bahan'),
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
