import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/pembelian/penerimaan_bahan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/form/form_penerimaan_bahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/sidebar_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMaterialReceive extends StatefulWidget {
  static const routeName = '/gudang/pembelian/penerimaan/list';

  const ListMaterialReceive({Key? key}) : super(key: key);

  @override
  _ListMaterialReceiveState createState() => _ListMaterialReceiveState();
}

class _ListMaterialReceiveState extends State<ListMaterialReceive> {
  final CollectionReference materialReceivesRef = FirebaseFirestore.instance.collection('material_receives');
  final CollectionReference materialsRef = FirebaseFirestore.instance.collection('materials');

  String searchTerm = '';
  String selectedStatus = '';
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  String startDateText = '';
  String endDateText = '';
  int startIndex = 0;
  int itemsPerPage = 5;
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
      SidebarGudangWidget(
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
                const CustomAppBar(title: 'Penerimaan Bahan', formScreen: FormPenerimaanBahanScreen(), routes: '${MainGudang.routeName}?selectedIndex=2',),
                const SizedBox(height: 24.0),
                _buildSearchBar(),
                const SizedBox(height: 16.0),
                buildDateRangeSelector(),
                const SizedBox(height: 16.0),
                _buildMaterialReceiveList(),
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
  Routemaster.of(context).push('${MainGudang.routeName}?selectedIndex=$index');
}


Widget _buildMobileContent() {
  return SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const CustomAppBar(title: 'Penerimaan Bahan', formScreen: FormPenerimaanBahanScreen(), routes: '${MainGudang.routeName}?selectedIndex=2',),
          const SizedBox(height: 24.0),
          _buildSearchBar(),
          const SizedBox(height: 16.0,),
          buildDateRangeSelector(),
          const SizedBox(height: 16.0),
          _buildMaterialReceiveList(),
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


Widget _buildMaterialReceiveList() {
  return StreamBuilder<QuerySnapshot>(
    stream: materialReceivesRef.snapshots(),
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

        return FutureBuilder<QuerySnapshot>(
          future: materialsRef.get(),
          builder: (context, materialsSnapshot) {
            if (materialsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              );
            } else if (materialsSnapshot.hasError) {
              return Text('Error getting material data: ${materialsSnapshot.error}');
            } else {
              final materialDocs = materialsSnapshot.data?.docs ?? [];

              final filteredDocs = itemDocs.where((doc) {
                final keterangan = doc['id'] as String;
                final tanggalRencana = doc['tanggal_penerimaan'] as Timestamp;
                final status = _getMaterialStatus(materialDocs, doc['material_id']);

                bool isWithinDateRange = true;
                if (selectedStartDate != null && selectedEndDate != null) {
                  isWithinDateRange = (tanggalRencana.toDate().isAfter(selectedStartDate!) &&
                      tanggalRencana.toDate().isBefore(selectedEndDate!));
                }

                return (keterangan.toLowerCase().contains(searchTerm.toLowerCase()) &&
                    (selectedStatus.isEmpty || status.contains(selectedStatus)) &&
                    isWithinDateRange);
              }).toList();

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
                        'ID Bahan': data['material_id'],
                        'Tanggal Penerimaan':
                            DateFormat('dd/MM/yyyy').format((data['tanggal_penerimaan'] as Timestamp).toDate()),
                        'Catatan': data['catatan'],
                        'Jenis Bahan': _getMaterialStatus(materialDocs, data['material_id']),
                        'Jumlah Permintaan': data['jumlah_permintaan'],
                        'Jumlah Diterima': data['jumlah_diterima'],
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
                                stokLama: data['jumlah_diterima'],
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
                                      final purReqBloc = BlocProvider.of<MaterialReceiveBloc>(context);
                                      purReqBloc.add(DeleteMaterialReceiveEvent(filteredDocs[startIndex + index].id));
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
                  const SizedBox(height: 16.0),
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
                          backgroundColor: Colors.brown,
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
                          backgroundColor: Colors.brown,
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

String _getMaterialStatus(List<QueryDocumentSnapshot> materialDocs, String materialId) {
  final materialDoc = materialDocs.firstWhere((doc) => doc['id'] == materialId);
  return materialDoc['jenis_bahan'] as String;
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
