import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/delivery_order_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/delivery_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_delivery_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/class/product_card_cust_widget_build.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/class/product_card_customer_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/customer_order_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPesananPengirimanScreen extends StatefulWidget {
  static const routeName = '/form_pesanan_pengiriman_screen';

  final String? deliveryOrderId;
  final String? customerOrderId;
  const FormPesananPengirimanScreen({Key? key, this.deliveryOrderId, this.customerOrderId}) : super(key: key);
  
  @override
  State<FormPesananPengirimanScreen> createState() =>
      _FormPesananPengirimanScreenState();
}

class _FormPesananPengirimanScreenState extends State<FormPesananPengirimanScreen> {
  DateTime? _selectedDate;
  DateTime? _selectedReqDate;
  String? selectedPesanan;
  String selectedMetode = "Pengiriman Truk Pabrik";
  String? dropdownValue;
  bool isLoading = false;
  
  TextEditingController statusController = TextEditingController();
  TextEditingController pelangganController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController totalBarangController = TextEditingController();
  TextEditingController totalHargaController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController waktuPengirimanController = TextEditingController();
  
  List<ProductCardDataCustomerOrder> productCards = [];
  List<Map<String, dynamic>> productData = []; // Inisialisasi daftar produk
  List<Map<String, dynamic>> customerOrderData = []; // Inisialisasi daftar produk
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  final deliveryOrderBloc = DeliveryOrderBloc();

void addProductCard() {
  setState(() {
    productCards.add(ProductCardDataCustomerOrder(
      kodeProduk: '',
      namaProduk: '',
      jumlah: '',
      satuan: '',
      hargaSatuan: '',
      subtotal: '',
    ));
    //void update
    updateTotalHargaProduk(); 
  });
}

void clearForm() {
  setState(() {
    _selectedDate = null;
    _selectedReqDate = null;
    selectedPesanan = null;
    selectedMetode = "Pengiriman Truk Pabrik";
    dropdownValue = null;
    catatanController.clear();
    statusController.clear();
    pelangganController.clear();
    alamatController.clear();
    totalBarangController.clear();
    totalHargaController.clear();
    waktuPengirimanController.clear();
    productCards.clear();
    productCards.add(ProductCardDataCustomerOrder(
      kodeProduk: '',
      namaProduk: '',
      jumlah: '',
      satuan: '',
      hargaSatuan: '',
      subtotal: '',
    ));
  });
}

 @override
  void dispose() {
    selectedCustomerOrderNotifier.removeListener(_selectedCustomerOrderListener);
    deliveryOrderBloc.close();
    super.dispose();
  }

 // Fungsi yang akan dipanggil ketika selectedPesanan berubah
void _selectedCustomerOrderListener() {
  setState(() {
    selectedPesanan = selectedCustomerOrderNotifier.value;
  });
}

void addOrUpdateData(){
  final deliveryOrderBloc = BlocProvider.of<DeliveryOrderBloc>(context);
    try {
    final deliveryOrder = DeliveryOrder(id: '', customerOrderId: selectedPesanan??'', metodePengiriman: selectedMetode, satuan: 'Pcs', status: 1, catatan: catatanController.text,alamatPengiriman: alamatController.text,statusPesananPengiriman: statusController.text, tanggalPesananPengiriman: _selectedDate?? DateTime.now(), tanggalRequestPengiriman: _selectedReqDate??DateTime.now(), totalBarang: int.tryParse(totalBarangController.text)??0, totalHarga: int.tryParse(currencyFormat.parse(totalHargaController.text).toString())??0, estimasiWaktu: int.tryParse(waktuPengirimanController.text)??0, detailDeliveryOrderList: []);

    // Loop melalui productCards untuk menambahkan detail customer order
    for (var productCardData in productCards) {
      final detailDeliveryOrder = DetailDeliveryOrder(
        id: '',
        deliveryOrderId: '',
        product_id: productCardData.kodeProduk,
        jumlah: int.tryParse(productCardData.jumlah)??0,
        hargaSatuan: int.tryParse(productCardData.hargaSatuan)??0,
        satuan: productCardData.satuan,
        status: 1,
        subtotal: int.tryParse(productCardData.subtotal)??0,
      );
      deliveryOrder.detailDeliveryOrderList?.add(detailDeliveryOrder);
    }

    if(widget.deliveryOrderId!=null){
      //berarti update
      deliveryOrderBloc.add(UpdateDeliveryOrderEvent(widget.deliveryOrderId??'', deliveryOrder));
    }else{
      deliveryOrderBloc.add(AddDeliveryOrderEvent(deliveryOrder));
    }
    
  } catch (e) {
    // Tangani pengecualian di sini
    print('Error: $e');
  }
}

void fetchDataProduct(){
    firestore.collection('products').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> product = {
          'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
          'nama': doc['nama'] as String, // Ganti 'nama' dengan field yang sesuai di Firestore
        };
        setState(() {
          productData.add(product); // Tambahkan produk ke daftar produk
        });
      }
    });
}

void fetchDataCustomerOrder(){
    // Ambil data produk dari Firestore di initState
    firestore.collection('customer_orders').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> customerOrder = {
          'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
        };
        setState(() {
          customerOrderData.add(customerOrder); // Tambahkan produk ke daftar produk
        });
      }
    });
}

void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        message: 'Berhasil menyimpan pesanan pengiriman.',
      );
    },
    ).then((_) {
      Navigator.pop(context,null);
    });
  }

void updateTotalHargaProduk() {
  int totalHarga = 0;
  int totalProduk = 0;
  for (var productCardData in productCards) {
    if (productCardData.subtotal.isNotEmpty) {
      int subtotalValue = int.tryParse(productCardData.subtotal) ?? 0;
      totalHarga += subtotalValue;
      totalProduk+= int.tryParse(productCardData.jumlah)??0;
    }
  }
  setState(() {
    totalHargaController.text = currencyFormat.format(totalHarga); // Format total harga
    totalBarangController.text = totalProduk.toString();
  });
}

  Future<void> fetchCustomerName(String customerId) async {
    final customerQuery = await firestore
        .collection('customers')
        .where('id', isEqualTo: customerId)
        .get();

    if (customerQuery.docs.isNotEmpty) {
      final customerDocument = customerQuery.docs.first;
      setState(() {
        pelangganController.text = customerDocument['nama'] ?? '';
      });
    }
}

void initializeCustomerOrder(){
    selectedPesanan = widget.customerOrderId;
    _selectedCustomerOrderListener();
    firestore
    .collection('customer_orders')
    .where('id', isEqualTo: selectedPesanan) // Gunakan .where untuk mencocokkan ID
    .get()
    .then((QuerySnapshot querySnapshot) {
    if (querySnapshot.docs.isNotEmpty) {
      final customerData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      fetchCustomerName(customerData['customer_id']);
    } else {
      print('Document does not exist on Firestore');
    }
  }).catchError((error) {
    print('Error getting document: $error');
  });
}

  // Fungsi untuk mengambil data detail_customer_orders
void fetchDataDetailDeliveryOrder() {
  firestore
      .collection('delivery_orders')
      .doc(widget.deliveryOrderId!) // Menggunakan widget.customerOrderId
      .collection('detail_delivery_orders') // Ganti dengan nama collection yang sesuai
      .get()
      .then((querySnapshot) {
    final newProductCards = <ProductCardDataCustomerOrder>[];
    querySnapshot.docs.forEach((doc) async {
      final detailData = doc.data();

        final productId = detailData['product_id'] as String;
        // Mencari nama produk berdasarkan productId
        final product = productData.firstWhere(
          (product) => product['id'] == productId,
          orElse: () => {'nama': 'Produk Tidak Ditemukan'}, // Default jika tidak ditemukan
        );

      final productCardData = ProductCardDataCustomerOrder(
        kodeProduk: detailData['product_id'] as String,
        namaProduk: product['nama'], // Anda dapat mengisi nama produk berdasarkan productData
        jumlah: detailData['jumlah'].toString(),
        satuan: detailData['satuan'] as String,
        hargaSatuan: detailData['harga_satuan'].toString(),
        subtotal: detailData['subtotal'].toString(),
      );

      newProductCards.add(productCardData);
    });

    setState(() {
      productCards = newProductCards;
    });
  });
}

@override
void initState() {
  super.initState();
  statusController.text = 'Dalam Proses';
  fetchDataCustomerOrder();
  fetchDataProduct();
  addProductCard(); 
   
  if (widget.deliveryOrderId != null) {
  // Jika ada customerOrderId, ambil data dari Firestore
  FirebaseFirestore.instance
      .collection('delivery_orders')
      .doc(widget.deliveryOrderId) // Menggunakan widget.customerOrderId
      .get()
      .then((DocumentSnapshot documentSnapshot) {
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      setState(() {
        alamatController.text = data['alamat_pengiriman'];
        catatanController.text = data['catatan'] ?? '';
        totalHargaController.text = data['total_harga'].toString();
        totalBarangController.text = data['total_barang'].toString();
        statusController.text = data['status_pesanan_pengiriman'];
        final tanggalDeliveryOrderFirestore = data['tanggal_pesanan_pengiriman'];
        if (tanggalDeliveryOrderFirestore != null) {
          _selectedDate = (tanggalDeliveryOrderFirestore as Timestamp).toDate();
        }
        final tanggalRequestFirestore = data['tanggal_request_pengiriman'];
        if (tanggalRequestFirestore != null) {
          _selectedReqDate = (tanggalRequestFirestore as Timestamp).toDate();
        }
        waktuPengirimanController.text = data['estimasi_waktu'].toString();
      });
    } else {
      print('Document does not exist on Firestore');
    }
  }).catchError((error) {
    print('Error getting document: $error');
  });

  fetchDataDetailDeliveryOrder(); // Ambil data detail_customer_orders
}

 if (widget.customerOrderId != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeCustomerOrder();
    });
  }

  WidgetsBinding.instance.addPostFrameCallback((_) {
    selectedCustomerOrderNotifier.addListener(_selectedCustomerOrderListener);
    selectedPesanan = selectedCustomerOrderNotifier.value;
  });
}

@override
Widget build(BuildContext context) {
   return BlocListener<DeliveryOrderBloc, DeliveryOrderBlocState>(
    listener: (context, state) async {
      if (state is SuccessState) {
        _showSuccessMessageAndNavigateBack();
        setState(() {
          isLoading = false; // Matikan isLoading saat successState
        });
      } else if (state is ErrorState) {
        final snackbar = SnackBar(content: Text(state.errorMessage));
        ScaffoldMessenger.of(context).showSnackBar(snackbar);
      } else if (state is LoadingState) {
        setState(() {
          isLoading = true; // Aktifkan isLoading saat LoadingState
        });
      }
      // Hanya jika bukan LoadingState, atur isLoading ke false
      if (state is! LoadingState) {
        setState(() {
          isLoading = false;
        });
      }
    },
    child: Scaffold(
    body: SafeArea(
      child: Stack(
        children: [
          Center(
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
                          Navigator.pop(context,null);
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
                            'Pesanan Pengiriman',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  CustomerOrderDropDownWidget(namaPelangganController: pelangganController, alamatPengirimanController: alamatController, customerOrderId: widget.customerOrderId,),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                    label: 'Pelanggan',
                    placeholder: 'Pelanggan',
                    controller: pelangganController,
                    isEnabled: false,
                  ),
                  const SizedBox(height: 16.0,),
                  DatePickerButton(
                    label: 'Tanggal Pesanan Pengiriman',
                    selectedDate: _selectedDate,
                    onDateSelected: (newDate) {
                      setState(() {
                        _selectedDate = newDate;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0,),
                  DatePickerButton(
                    label: 'Tanggal Permintaan Pengiriman',
                    selectedDate: _selectedReqDate,
                    onDateSelected: (newDate) {
                      setState(() {
                        _selectedReqDate = newDate;
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                    label: 'Alamat',
                    placeholder: 'Alamat',
                    controller: alamatController,
                    multiline: true,
                  ),
                  const SizedBox(height: 16.0,),
                  DropdownWidget(
                    label: 'Metode Pengiriman',
                    selectedValue: selectedMetode, // Isi dengan nilai yang sesuai
                    items: const ['Pengiriman Truk Pabrik', 'Ekspedisi'],
                    onChanged: (newValue) {
                      setState(() {
                        selectedMetode = newValue; // Update _selectedValue saat nilai berubah
                      });
                    },
                  ),
                  const SizedBox(height: 16.0,),
                    Row(
                    children: [
                      Expanded(child: TextFieldWidget(
                          label: 'Total Barang',
                          placeholder: 'Total Barang',
                          controller: totalBarangController,
                          isEnabled: false,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Expanded(child: TextFieldWidget(
                          label: 'Satuan',
                          placeholder: 'Pcs',
                          isController: false,
                          isEnabled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                          label: 'Total Harga',
                          placeholder: 'Total Harga',
                          controller: totalHargaController,
                          isEnabled: false,
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
                      Expanded(child: TextFieldWidget(
                          label: 'Estimasi Waktu Pengiriman',
                          placeholder: 'Waktu Pengiriman',
                          controller: waktuPengirimanController,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      const Expanded(child: TextFieldWidget(
                          label: '',
                          placeholder: 'Days',
                          isController: false,
                          isEnabled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                    label: 'Status',
                    placeholder: 'In Process',
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
                      return ProductCardCustOrder(productCardData: productCardData, updateTotalHargaProduk: updateTotalHargaProduk, productData: productData, productCards: productCards);
                    }).toList(),
                  const SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle save button press
                            addOrUpdateData();
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
                            clearForm();
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
          if (isLoading)
            Positioned( // Menambahkan Positioned untuk indikator loading
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black.withOpacity(0.3), // Latar belakang semi-transparan
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      )
    ),
  ))
  ;
}
}

