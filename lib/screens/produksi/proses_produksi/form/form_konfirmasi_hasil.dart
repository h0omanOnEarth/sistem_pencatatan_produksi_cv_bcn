import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdowndetail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardData {
  String nomorHasilProduksi;
  String kodeBarang;
  String namaBarang;
  String jumlahHasil;
  String satuan;
  String jumlahKonfirmasi;
  String selectedDropdownValue = '';

  ProductCardData({
    required this.nomorHasilProduksi,
    required this.kodeBarang,
    required this.namaBarang,
    required this.jumlahHasil,
    required this.satuan,
    required this.jumlahKonfirmasi,
    this.selectedDropdownValue = '',
  });
}

class FormKonfirmasiProduksiScreen extends StatefulWidget {
  static const routeName = '/form_konfirmasi_produksi_screen';

  const FormKonfirmasiProduksiScreen({super.key});
  
  @override
  State<FormKonfirmasiProduksiScreen> createState() =>
      _FormKonfirmasiProduksiScreenState();
}


class _FormKonfirmasiProduksiScreenState extends State<FormKonfirmasiProduksiScreen> {
  DateTime? selectedDate;
  String selectedStatus = 'Aktif';

  List<ProductCardData> productCards = [];
    void addProductCard() {
    setState(() {
      productCards.add(ProductCardData(
        nomorHasilProduksi: '',
        kodeBarang: '',
        namaBarang: '',
        jumlahHasil: '',
        satuan: '',
        jumlahKonfirmasi: '',
      ));
    });
  }

  @override
  void initState() {
    super.initState();
    addProductCard(); // Tambahkan product card secara default pada initState
  }

  @override
  Widget build(BuildContext context) {
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
                        child: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                    ),
                    SizedBox(width: 24.0),
                    const Flexible(
                        child: Text(
                          'Konfirmasi Produksi',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.0,),
                DatePickerButton(
                      label: 'Tanggal Pencatatan',
                      selectedDate: selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                ),
                SizedBox(height: 16.0,),
                DropdownWidget(
                  label: 'Status',
                  selectedValue: selectedStatus, // Isi dengan nilai yang sesuai
                  items: ['Aktif', 'Tidak Aktif'],
                  onChanged: (newValue) {
                    setState(() {
                      selectedStatus = newValue; // Update _selectedValue saat nilai berubah
                      print('Selected value: $newValue');
                    });
                  },
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Catatan',
                  placeholder: 'Catatan',
                  controller: catatanController,
                ),
                SizedBox(height: 16.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Detail Konfirmasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        addProductCard();
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color.fromRGBO(59, 51, 51, 1),
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              if (productCards.isNotEmpty)
              ...productCards.map((productCardData) {
                return ProductCard(
                  productCardData: productCardData,
                  onDelete: () {
                    setState(() {
                      productCards.remove(productCardData);
                    });
                  },
                  children: [
                    ProductCardChildren(productCardData: productCardData),
                    // ... Add other child widgets here
                  ],
                );
              }).toList(),
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
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
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


class ProductCardChildren extends StatefulWidget {
  final ProductCardData productCardData;

  ProductCardChildren({required this.productCardData});

  @override
  _ProductCardChildrenState createState() => _ProductCardChildrenState();
}

class _ProductCardChildrenState extends State<ProductCardChildren> {
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownDetailWidget(
          label: 'Nomor Hasil Produksi',
          items: ['Hasil 1', 'Hasil 2'],
          selectedValue: widget.productCardData.nomorHasilProduksi,
          onChanged: (newValue) {
                setState(() {
                  widget.productCardData.nomorHasilProduksi = newValue;
                });
              },
        ),
      const SizedBox(height: 16.0,),
      Row(
        children: [
          Expanded(child:
            TextFieldWidget(
                label: 'Kode Barang',
                placeholder: '0',
                controller: TextEditingController(text: widget.productCardData.kodeBarang),
                isEnabled: false,
              ), 
          ),
          SizedBox(width: 16.0),
          Expanded(
            child:   
            TextFieldWidget(
                label: 'Nama Barang',
                placeholder: 'Nama Barang',
                controller: TextEditingController(text: widget.productCardData.namaBarang),
                isEnabled: false,
            ), 
          ),
        ],
       ),   
      const SizedBox(height: 16.0,),
      Row(
        children: [
          Expanded(child:
            TextFieldWidget(
                label: 'Jumlah Hasil',
                placeholder: '0',
                controller: TextEditingController(text: widget.productCardData.jumlahHasil),
                isEnabled: false,
              ), 
          ),
          SizedBox(width: 16.0),
          Expanded(
            child:   
            TextFieldWidget(
                label: 'Satuan',
                placeholder: 'Satuan',
                controller: TextEditingController(text: widget.productCardData.satuan),
                isEnabled: false,
            ), 
          ),
        ],
       ),   
      const SizedBox(height: 16.0,),
      TextFieldWidget(
            label: 'Jumlah Konfirmasi',
            placeholder: '0',
            controller: TextEditingController(text: widget.productCardData.jumlahKonfirmasi),
        ), 
      ],
    );
  }
}
