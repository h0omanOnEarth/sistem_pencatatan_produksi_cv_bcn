import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/produksi/item_receive_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/productionConfirmationWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPenerimaanHasilProduksi extends StatefulWidget {
  static const routeName = '/form_penerimaan_hasil_produksi_screen';
  final String? itemReceivceId;
  final String? productionConfirmationId;

  const FormPenerimaanHasilProduksi({Key? key, this.itemReceivceId, this.productionConfirmationId}) : super(key: key);
  
  @override
  State<FormPenerimaanHasilProduksi> createState() =>
      _FormPenerimaanHasilProduksiState();
}

class _FormPenerimaanHasilProduksiState extends State<FormPenerimaanHasilProduksi> {
  DateTime? _selectedDate;
  String? selectedNomorKonfirmasi;
  String selectedStatus = 'Dalam Proses';
  
  TextEditingController catatanController = TextEditingController();
  TextEditingController tanggalKonfirmasiController = TextEditingController();


  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  
@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => ItemReceiveBloc(),
    child: Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
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
                  const SizedBox(width: 16.0),
                  const Flexible(
                        child: Text(
                          'Penerimaan Barang',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Di dalam widget buildProductCard atau tempat lainnya
             DatePickerButton(
                        label: 'Tanggal Penerimaan',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              ProductionConfirmationDropDown(selectedProductionConfirmationDropdown: selectedNomorKonfirmasi,  onChanged: (newValue) {
                    setState(() {
                      selectedNomorKonfirmasi = newValue??'';
                    });
              }, tanggalKonfirmasiController: tanggalKonfirmasiController,),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Tanggal Konfirmasi',
                placeholder: 'Tanggal Konfirmasi',
                controller: tanggalKonfirmasiController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Catatan',
                placeholder: 'Catatan',
                controller: catatanController,
              ),
              const SizedBox(height: 16.0,),
              DropdownWidget(
                        label: 'Status',
                        selectedValue: selectedStatus, // Isi dengan nilai yang sesuai
                        items: const ['Dalam Proses', 'Selesai'],
                        onChanged: (newValue) {
                          setState(() {
                            selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              const Text(
                'Detail Penerimaan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0,),
              CustomCard(
              content: [
                CustomCardContent(text: 'Kode Barang : B0001'),
                CustomCardContent(text: 'Nama Barang : Gelas Pop 22 oz'),
                CustomCardContent(text: 'Jumlah : 100.000 pcs'),
                CustomCardContent(text: 'Jumlah (Dus) : 20 dus'),
              ],
            ),
           CustomCard(
              content: [
                CustomCardContent(text: 'Kode Barang : B0001'),
                CustomCardContent(text: 'Nama Barang : Gelas Pop 22 oz'),
                CustomCardContent(text: 'Jumlah : 100.000 pcs'),
                CustomCardContent(text: 'Jumlah (Dus) : 20 dus'),
              ],
            ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle save button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Simpan',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle clear button press
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: const Padding(
                        padding:  EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'Bersihkan',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  )
  );
}
}

