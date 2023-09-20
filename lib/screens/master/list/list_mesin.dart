import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/mesin_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/form_mesin.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_appbar.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/list_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/search_bar.dart';

class ListMasterMesinScreen extends StatefulWidget {
  static const routeName = '/list_master_mesin_screen';

  const ListMasterMesinScreen({super.key});
  @override
  State<ListMasterMesinScreen> createState() => _ListMasterMesinScreenState();
}

class _ListMasterMesinScreenState extends State<ListMasterMesinScreen> {
  final CollectionReference mesinRef = FirebaseFirestore.instance.collection('machines');
  String searchTerm = '';
  String selectedTipe = '';

  @override
  Widget build(BuildContext context) {
     return BlocProvider(
      create: (context) => MesinBloc(),
      child: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomAppBar(title: 'Mesin', formScreen: FormMasterMesinScreen()),
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
                StreamBuilder<QuerySnapshot>(
                    stream: mesinRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey), // Ubah warna ke abu-abu
                          ),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
                        return const Text('Tidak ada data mesin.');
                      } else {
                        final querySnapshot = snapshot.data!;
                        final mesinDocs = querySnapshot.docs;

                        final filteredTipeDocs = mesinDocs.where((doc) {
                          final nama = doc['nama'] as String;
                          final tipe = doc['tipe'] as String;
                          return (nama.toLowerCase().contains(searchTerm.toLowerCase()) &&
                              (selectedTipe.isEmpty || tipe == selectedTipe));
                        }).toList();

                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredTipeDocs.length,
                          itemBuilder: (context, index) {
                            final data = filteredTipeDocs[index].data() as Map<String, dynamic>;
                            final nama = data['nama'] as String;
                            final info = {
                            'id' : data['id'] as String,
                            'nomor seri': data['nomor_seri'] as String,
                            'Status': data['status'] == 1 ? 'Aktif' : 'Tidak Aktif',
                          };
                            return ListCard(
                              title: nama,
                              description: info.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FormMasterMesinScreen(
                                       mesinId: data['id'],
                                       supplierId: data['supplier_id'], // Mengirimkan ID pelanggan
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
                                      content: const Text("Anda yakin ingin menghapus mesin ini?"),
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
                                            final mesinBloc =BlocProvider.of<MesinBloc>(context);
                                            mesinBloc.add(DeleteMesinEvent(data['id']));
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
                  BlocBuilder<MesinBloc, MesinState>(
                    builder: (context, state) {
                      if (state is ErrorState) {
                        Text(state.errorMessage);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

    Future<void> _showFilterDialog(BuildContext context) async {
    String? selectedValue = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Filter Berdasarkan Tipe Mesin'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, '');
              },
              child: const Text('Semua'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Penggiling');
              },
              child: const Text('Penggiling'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pencampur');
              },
              child: const Text('Pencampur'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Pencetak');
              },
              child: const Text('Pencetak'),
            ),
             SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'Mesin');
              },
              child: const Text('Mesin'),
            ),
          ],
        );
      },
    );

    if (selectedValue != null) {
      setState(() {
        selectedTipe = selectedValue;
      });
    }
  }

}

