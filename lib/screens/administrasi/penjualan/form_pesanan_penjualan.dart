import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/pesanan_pelanggan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_pesanan_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/pesanan_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdown_produk_detail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdowndetail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/pelanggan_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardData {
  String kodeProduk;
  String namaProduk;
  String jumlah;
  String satuan;
  String hargaSatuan;
  String subtotal;
  String selectedDropdownValue = '';
  TextEditingController? jumlahController; // Ubah tipe data menjadi TextEditingController?
  TextEditingController? hargaSatuanController; // Ubah tipe data menjadi TextEditingController?

  ProductCardData({
    required this.kodeProduk,
    required this.namaProduk,
    required this.jumlah,
    required this.satuan,
    required this.hargaSatuan,
    required this.subtotal,
    this.selectedDropdownValue = '',
  }){
    // Initialize the controller with the current 'jumlah' value
    jumlahController = TextEditingController(text: jumlah);;
    hargaSatuanController =  TextEditingController(text: hargaSatuan);
  }
  
  void calculateSubtotal() {
  if (jumlah.isNotEmpty && hargaSatuan.isNotEmpty) {
    int jumlahValue = int.tryParse(jumlah) ?? 0;
    int hargaSatuanValue = int.tryParse(hargaSatuan) ?? 0;
    int result = jumlahValue * hargaSatuanValue;
    subtotal = result.toString().replaceAll(RegExp(r'^0+(?=\d)'), ''); // Format sebagai string dengan 2 desimal dan hapus nol di depan
  } else {
    subtotal = ''; // Atur subtotal menjadi kosong jika jumlah atau harga satuan kosong
  }
}
}

class FormPesananPelangganScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pelanggan_screen';
  final String? customerOrderId;

  const FormPesananPelangganScreen({Key? key, this.customerOrderId}) : super(key: key);
  
  @override
  State<FormPesananPelangganScreen> createState() =>
      _FormPesananPelangganScreenState();
}

class _FormPesananPelangganScreenState extends State<FormPesananPelangganScreen> {
  DateTime? _selectedTanggalPesan;
  DateTime? _selectedTanggalKirim;
  String? selectedKode;
  String? dropdownValue;
  List<Map<String, dynamic>> productData = []; // Inisialisasi daftar produk
  
  TextEditingController catatanController = TextEditingController();
  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController alamatPengirimanController = TextEditingController();
  TextEditingController totalHargaController = TextEditingController();
  TextEditingController totalProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final customerOrderBloc = CustomerOrderBloc();

  @override
  void dispose() {
    selectedPelangganNotifier.removeListener(_selectedKodeListener);
    customerOrderBloc.close();
    super.dispose();
  }

  // Fungsi yang akan dipanggil ketika selectedKode berubah
  void _selectedKodeListener() {
    setState(() {
      selectedKode = selectedPelangganNotifier.value;
    });
  }

 List<ProductCardData> productCards = [];

  void addProductCard() {
    setState(() {
      productCards.add(ProductCardData(
        kodeProduk: '',
        namaProduk: '',
        jumlah: '',
        satuan: '',
        hargaSatuan: '',
        subtotal: '',
      ));
      updateTotalHargaProduk(); // Panggil updateTotalHargaProduk saat menambah produk
    });
  }

  void updateTotalHargaProduk() {
  int totalHarga = 0;
  int totalProduk = 0;

  for (var productCardData in productCards) {
    if (productCardData.subtotal.isNotEmpty) {
      int subtotalValue = int.tryParse(productCardData.subtotal) ?? 0;
      totalHarga += subtotalValue;
      totalProduk++;
    }
  }

  setState(() {
    totalHargaController.text = currencyFormat.format(totalHarga); // Format total harga
    totalProdukController.text = totalProduk.toString();
  });
}

void addOrUpdateCustomerOrder() {
  final _customerOrderBloc = BlocProvider.of<CustomerOrderBloc>(context);
  
  try {
    final customerOrder = CustomerOrder(
      id: '',
      customerId: selectedKode ?? '',
      alamatPengiriman: alamatPengirimanController.text,
      catatan: catatanController.text,
      satuan: 'Pcs',
      status: 1,
      statusPesanan: statusController.text,
      tanggalKirim: _selectedTanggalKirim ?? DateTime.now(),
      tanggalPesan: _selectedTanggalPesan ?? DateTime.now(),
      totalHarga: currencyFormat.parse(totalHargaController.text).toInt(),
      totalProduk: int.parse(totalProdukController.text),
      detailCustomerOrderList: [], // Initialize as an empty list
    );

    // Loop melalui productCards untuk menambahkan detail customer order
    for (var productCardData in productCards) {
      final detailCustomerOrder = DetailCustomerOrder(
        id: '',
        customerOrderId: '',
        productId: productCardData.kodeProduk,
        jumlah: int.parse(productCardData.jumlah),
        hargaSatuan: int.parse(productCardData.hargaSatuan),
        satuan: productCardData.satuan,
        status: 1,
        subtotal: int.parse(productCardData.subtotal),
      );
      customerOrder.detailCustomerOrderList?.add(detailCustomerOrder);
    }

    print(customerOrder.detailCustomerOrderList);

    // Dispatch event untuk menambahkan customer order
    _customerOrderBloc.add(AddCustomerOrderEvent(customerOrder));
    _showSuccessMessageAndNavigateBack();
  } catch (e) {
    // Tangani pengecualian di sini
    print('Error: $e');
  }
}


void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        message: 'Berhasil menyimpan pesanan pelanggan.',
      );
    },
    ).then((_) {
      Navigator.pop(context,null);
    });
  }

Widget buildProductCard(ProductCardData productCardData) {
  return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Colors.grey[300]!),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownProdukDetailWidget(
              label: 'Kode Produk',
              selectedValue: productCardData.kodeProduk,
              onChanged: (newValue) {
                setState(() {
                  productCardData.kodeProduk = newValue;
                  final selectedProduct = productData.firstWhere(
                        (product) => product['id'] == newValue,
                        orElse: () => {'nama': 'Nama Produk Tidak Ditemukan'},
                      );
                  productCardData.namaProduk = selectedProduct['nama'];
                  print(selectedProduct);
                });
              },
              products: productData, // productData adalah daftar produk dari Firestore
            ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
              label: 'Nama Produk',
              placeholder: 'Nama Produk',
              controller: TextEditingController(text: productCardData.namaProduk),
              isEnabled: false,
            ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
              label: 'Jumlah',
              placeholder: 'Jumlah',
              controller: productCardData.jumlahController,
              onChanged: (value) {
              setState(() {
                productCardData.jumlah = value;
                productCardData.calculateSubtotal();
                updateTotalHargaProduk(); // Panggil updateTotalHargaProduk
              });
            },
            ),
              const SizedBox(height: 8.0),
             DropdownDetailWidget(
            label: 'Satuan',
            items: const ['Pcs', 'Kg', 'Ons','Dus'],
            selectedValue: productCardData.satuan,
            onChanged: (newValue) {
              setState(() {
                productCardData.satuan = newValue;
              });
            },
          ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
                label: 'Harga Satuan',
                placeholder: 'Harga Satuan',
                controller: productCardData.hargaSatuanController,
                onChanged: (value) {
                setState(() {
                  productCardData.hargaSatuan = value;
                  productCardData.calculateSubtotal();
                  updateTotalHargaProduk(); // Panggil updateTotalHargaProduk
                });
              },
              ),
              const SizedBox(height: 8.0),
             TextFieldWidget(
                label: 'Subtotal',
                placeholder: 'Subtotal',
                controller: TextEditingController(text: productCardData.subtotal),
                isEnabled: false,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0), // Add the desired margin
          child: Container(
            width: double.infinity, // Make the button full width
            child: ElevatedButton(
              onPressed: () {
                // Handle delete button press
                setState(() {
                  productCards.remove(productCardData);
                  updateTotalHargaProduk(); // Panggil updateTotalHargaProduk saat menghapus produk
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10), // Add padding to the button
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Hapus',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

@override
void initState() {
  super.initState();
  addProductCard(); 
  selectedPelangganNotifier.addListener(_selectedKodeListener);
  selectedKode = selectedPelangganNotifier.value;
  statusController.text = 'Dalam Proses';

  // Ambil data produk dari Firestore di initState
    FirebaseFirestore.instance.collection('products').get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> product = {
          'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
          'nama': doc['nama'] as String, // Ganti 'nama' dengan field yang sesuai di Firestore
        };
        setState(() {
          productData.add(product); // Tambahkan produk ke daftar produk
        });
      });
    });
}

@override
Widget build(BuildContext context) {
  return BlocProvider(
    create: (context) => CustomerOrderBloc(),
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
                        'Pesanan Penjualan',
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
              PelangganDropdownWidget(namaPelangganController: namaPelangganController),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Nama Pelanggan',
                placeholder: 'Nama Pelanggan',
                controller: namaPelangganController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(child: DatePickerButton(
                        label: 'Tanggal Pesan',
                        selectedDate: _selectedTanggalPesan,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedTanggalPesan = newDate;
                          });
                        },
                      ), 
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(child: DatePickerButton(
                      label: 'Tanggal Kirim',
                      selectedDate: _selectedTanggalKirim,
                      onDateSelected: (newDate) {
                        setState(() {
                          _selectedTanggalKirim = newDate;
                        });
                      },
                    ), 
                  ),
                ],
              ),
              const SizedBox(height: 16),
               TextFieldWidget(
                label: 'Alamat Pengiriman',
                placeholder: 'Alamat Pengiriman',
                controller: alamatPengirimanController,
                multiline: true,
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
                    child:  TextFieldWidget(
                      label: 'Total Harga',
                      placeholder: 'Total Harga',
                      controller: totalHargaController,
                      isEnabled: false,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child:  TextFieldWidget(
                      label: 'Total Produk',
                      placeholder: 'Total Produk',
                      controller: totalProdukController,
                      isEnabled: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0,),
               TextFieldWidget(
                label: 'Status',
                placeholder: 'Dalam Proses',
                controller: statusController,
                isEnabled: false,
              ),
              const SizedBox(height: 16.0,),
              // Add Product Card Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      addProductCard();
                    },
                    child: const CircleAvatar(
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
                  return buildProductCard(productCardData);
                }).toList(),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle save button press
                        addOrUpdateCustomerOrder();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(59, 51, 51, 1),
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

