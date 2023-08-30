import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdowndetail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/product_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardData {
  String kodeBahan;
  String namaBahan;
  String hargaBahan;
  String kodeBatch;
  String namaBatch;
  String jumlah;
  String satuan;
  String hargaSatuan;
  String selectedDropdownValue = '';

  ProductCardData({
    required this.kodeBahan,
    required this.namaBahan,
    required this.hargaBahan,
    required this.kodeBatch,
    required this.namaBatch,
    required this.jumlah,
    required this.satuan,
    required this.hargaSatuan,
    this.selectedDropdownValue = '',
  });
}

class FormMasterBOMScreen extends StatefulWidget {
  static const routeName = '/form_master_bom_screen';

  const FormMasterBOMScreen({super.key});
  
  @override
  State<FormMasterBOMScreen> createState() =>
      _FormMasterBOMScreenState();
}


class _FormMasterBOMScreenState extends State<FormMasterBOMScreen> {
  String selectedKodeProduk = "Produk 1";
  String selectedStatus = "Aktif";
  DateTime? selectedDate;

  List<ProductCardData> productCards = [];
    void addProductCard() {
    setState(() {
      productCards.add(ProductCardData(
        kodeBahan: '',
        namaBahan: '',
        hargaBahan: '',
        kodeBatch: '',
        namaBatch: '',
        jumlah: '',
        satuan: '',
        hargaSatuan: '',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
   
    var kodeBOMController;
    var namaProdukController;
    var dimensiControler;
    var beratController;
    var ketebalanController;
    var satuanController;
    var versiBOMController;
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
                    const Text(
                      'Bill of Material',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.0),
                TextFieldWidget(
                  label: 'Kode BOM',
                  placeholder: 'Kode BOM',
                  controller: kodeBOMController,
                ),
                SizedBox(height: 16.0),
                DropdownWidget(
                  label: 'Kode Produk',
                  selectedValue: selectedKodeProduk, // Isi dengan nilai yang sesuai
                  items: ['Produk 1', 'Produk 2'],
                  onChanged: (newValue) {
                    setState(() {
                      selectedKodeProduk = newValue; // Update _selectedValue saat nilai berubah
                      print('Selected value: $newValue');
                    });
                  },
                ),
                SizedBox(height: 16.0),
                TextFieldWidget(
                  label: 'Nama Produk',
                  placeholder: 'Nama Produk',
                  controller: namaProdukController,
                  isEnabled: false,
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(child: 
                    TextFieldWidget(
                      label: 'Dimensi',
                      placeholder: 'Dimensi',
                      controller: dimensiControler,
                    ),),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:    TextFieldWidget(
                        label: 'Berat',
                        placeholder: 'Berat',
                        controller: beratController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(child: 
                       TextFieldWidget(
                          label: 'Ketebalan',
                          placeholder: 'Ketebalan',
                          controller: ketebalanController,
                        ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child:   
                       TextFieldWidget(
                        label: 'Satuan',
                        placeholder: 'Satuan ',
                        controller: satuanController,
                        isEnabled: false,
                      ),
                    ),
                  ],
                ),    
                SizedBox(height: 16.0,),
                DatePickerButton(
                      label: 'Tanggal Pembuatan BOM',
                      selectedDate: selectedDate,
                      onDateSelected: (newDate) {
                        setState(() {
                          selectedDate = newDate;
                        });
                      },
                ),
                SizedBox(height: 16.0,),
                TextFieldWidget(
                  label: 'Versi BOM',
                  placeholder: '1',
                  controller: versiBOMController,
                  isEnabled: false,
                ),
                SizedBox(height: 16.0,),
                DropdownWidget(
                  label: 'Status BOM',
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
                    'Detail Bahan',
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
          label: 'Kode Bahan',
          items: ['Kode 1', 'Kode 2'],
          selectedValue: widget.productCardData.kodeBahan,
          onChanged: (newValue) {
                setState(() {
                  widget.productCardData.kodeBahan = newValue;
                });
              },
        ),
        const SizedBox(height: 8.0),
        TextFieldWidget(
              label: 'Nama Bahan',
              placeholder: 'Nama Bahan',
              controller: TextEditingController(text: widget.productCardData.namaBahan),
              isEnabled: false,
       ),
       const SizedBox(height: 16.0,),
       TextFieldWidget(
              label: 'Harga Bahan',
              placeholder: 'Harga Bahan',
              controller: TextEditingController(text: widget.productCardData.hargaBahan),
      ),
      const SizedBox(height: 16.0,),
      Row(
        children: [
          Expanded(child: 
            DropdownDetailWidget(
              label: 'Kode Batch',
              items: ['Batch 1', 'Batch 2'],
              selectedValue: widget.productCardData.kodeBatch,
              onChanged: (newValue) {
                    setState(() {
                      widget.productCardData.kodeBatch = newValue;
                    });
                  },
            ),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child:   
              TextFieldWidget(
              label: 'Nama Batch',
              placeholder: 'Nama Batch',
              controller: TextEditingController(text: widget.productCardData.namaBatch),
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
                label: 'Jumlah',
                placeholder: '0',
                controller: TextEditingController(text: widget.productCardData.jumlah),
              ), 
          ),
          SizedBox(width: 16.0),
          Expanded(
            child:   
            DropdownDetailWidget(
              label: 'Satuan',
              items: ['Pcs', 'Kg', 'Ons'],
              selectedValue: widget.productCardData.satuan,
              onChanged: (newValue) {
                    setState(() {
                      widget.productCardData.satuan = newValue;
                    });
                  },
            ),
          ),
        ],
      ),    
      ],
    );
  }
}
