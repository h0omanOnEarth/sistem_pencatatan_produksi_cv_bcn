import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';


class FormPesananPembelianScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pembelian_screen';

  final String? purchaseOrderId; // Terima ID pegawai jika dalam mode edit
  const FormPesananPembelianScreen({Key? key, this.purchaseOrderId}) : super(key: key);
  
  @override
  State<FormPesananPembelianScreen> createState() =>
      _FormPesananPembelianScreenState();
}

class _FormPesananPembelianScreenState extends State<FormPesananPembelianScreen> {
  DateTime? _selectedTanggalPengiriman;
  DateTime? _selectedTanggalPesanan;
  String selectedKode = "Kode A";
  String selectedSupplier = "Supplier 1";
  String selectedSatuan = "Kg";
  String selectedStatusPembayaran = "Belum Bayar";
  String selectedStatusPengiriman = "Dalam Proses";

  @override
  Widget build(BuildContext context) {
    var namaBahanController;
    var jumlahController;
    var hargaSatuanController;
    var totalController;
    var catatanController;
    return Scaffold(
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
                        child:const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                   const SizedBox(width: 16.0),
                    const Text(
                      'Pesanan Pembelian',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedKode, // Isi dengan nilai yang sesuai
                      items: ['Kode A', 'Kode B', 'Kode C'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                      label: 'Nama Bahan',
                      placeholder: 'Nama Bahan',
                      controller: namaBahanController,
                      isEnabled: false,
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                DropdownWidget(
                      label: 'Supplie',
                      selectedValue: selectedSupplier, // Isi dengan nilai yang sesuai
                      items: ['Supplier 1', 'Supplier 2'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSupplier = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: 
                    TextFieldWidget(
                      label: 'Jumlah',
                      placeholder: 'Jumlah',
                      controller: jumlahController,
                    ),),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Satuan',
                      selectedValue: selectedSatuan, // Isi dengan nilai yang sesuai
                      items: ['Kg','Ons','Pcs','Gram','Sak'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedSatuan = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                 Row(
                  children: [
                    Expanded(
                      child:    TextFieldWidget(
                      label: 'Harga Satuan',
                      placeholder: 'Harga Satuan',
                      controller: hargaSatuanController,
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Total',
                        placeholder: 'Total',
                        controller: totalController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child:  DatePickerButton(
                        label: 'Tanggal Pesanan',
                        selectedDate: _selectedTanggalPesanan,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPesanan = newDate;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DatePickerButton(
                        label: 'Tanggal Pengirman',
                        selectedDate: _selectedTanggalPengiriman,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPengiriman = newDate;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: DropdownWidget(
                      label: 'Status Pemayaran',
                      selectedValue: selectedStatusPembayaran, // Isi dengan nilai yang sesuai
                      items: ['Belum Bayar', 'Dalam Proses', 'Selesai'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatusPembayaran = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: DropdownWidget(
                      label: 'Status Pengiriman',
                      selectedValue: selectedStatusPengiriman, // Isi dengan nilai yang sesuai
                      items: ['Dalam Proses', 'Selesai'],
                      onChanged: (newValue) {
                        setState(() {
                          selectedStatusPengiriman = newValue; // Update _selectedValue saat nilai berubah
                          print('Selected value: $newValue');
                        });
                      },
                    ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0,),
                   TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
              
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
                          backgroundColor: Color.fromRGBO(59, 51, 51, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Simpan',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle clear button press
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(59, 51, 51, 1),
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
    );
  }
}
