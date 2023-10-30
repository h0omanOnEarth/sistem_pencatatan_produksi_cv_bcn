import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/pesanan_pelanggan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_pesanan_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/pesanan_pelanggan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/class/product_card_cust_widget_build.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/class/product_card_customer_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/pelanggan_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormPesananPelangganScreen extends StatefulWidget {
  static const routeName = 'administrasi/penjualan/pesanan/form';
  final String? customerOrderId;
  final String? customerId;
  final String? statusCO;

  const FormPesananPelangganScreen(
      {Key? key, this.customerOrderId, this.customerId, this.statusCO})
      : super(key: key);

  @override
  State<FormPesananPelangganScreen> createState() =>
      _FormPesananPelangganScreenState();
}

class _FormPesananPelangganScreenState
    extends State<FormPesananPelangganScreen> {
  DateTime? _selectedTanggalPesan;
  DateTime? _selectedTanggalKirim;
  String? selectedKode;
  String? dropdownValue;
  List<Map<String, dynamic>> productData = []; // Inisialisasi daftar produk
  bool isLoading = false;

  TextEditingController catatanController = TextEditingController();
  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController alamatPengirimanController = TextEditingController();
  TextEditingController totalHargaController = TextEditingController();
  TextEditingController totalProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  final customerOrderBloc = CustomerOrderBloc();
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance; // Instance Firestore

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

  List<ProductCardDataCustomerOrder> productCards = [];

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
        totalProduk += int.tryParse(productCardData.jumlah) ?? 0;
      }
    }
    setState(() {
      totalHargaController.text =
          currencyFormat.format(totalHarga); // Format total harga
      totalProdukController.text = totalProduk.toString();
    });
  }

  void clearForm() {
    setState(() {
      _selectedTanggalPesan = null;
      _selectedTanggalKirim = null;
      selectedKode = null;
      dropdownValue = null;
      catatanController.clear();
      alamatPengirimanController.clear();
      totalHargaController.clear();
      totalProdukController.clear();
      statusController.clear();
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

  void addOrUpdateCustomerOrder() {
    final customerOrderBloc = BlocProvider.of<CustomerOrderBloc>(context);
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
        totalHarga: int.tryParse(
                currencyFormat.parse(totalHargaController.text).toString()) ??
            0,
        totalProduk: int.tryParse(totalProdukController.text) ?? 0,
        detailCustomerOrderList: [], // Initialize as an empty list
      );

      // Loop melalui productCards untuk menambahkan detail customer order
      for (var productCardData in productCards) {
        final detailCustomerOrder = DetailCustomerOrder(
          id: '',
          customerOrderId: '',
          productId: productCardData.kodeProduk,
          jumlah: int.tryParse(productCardData.jumlah) ?? 0,
          hargaSatuan: int.tryParse(productCardData.hargaSatuan) ?? 0,
          satuan: productCardData.satuan,
          status: 1,
          subtotal: int.tryParse(productCardData.subtotal) ?? 0,
        );
        customerOrder.detailCustomerOrderList?.add(detailCustomerOrder);
      }

      if (widget.customerId != null) {
        customerOrderBloc.add(UpdateCustomerOrderEvent(
            widget.customerOrderId ?? '', customerOrder));
      } else {
        // Dispatch event untuk menambahkan customer order
        customerOrderBloc.add(AddCustomerOrderEvent(customerOrder));
      }
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
      Navigator.pop(context, null);
    });
  }

  void fetchData() {
    // Ambil data produk dari Firestore di initState
    Query collectionQuery = firestore.collection('products');

    if (widget.customerOrderId == null) {
      // Jika widget.customerOrderId == null, tambahkan klausa where status = 1
      collectionQuery = collectionQuery.where('status', isEqualTo: 1);
    }

    collectionQuery.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> product = {
          'id': doc['id'], // Gunakan ID dokumen sebagai ID produk
          'nama': doc['nama']
              as String, // Ganti 'nama' dengan field yang sesuai di Firestore
        };
        setState(() {
          productData.add(product); // Tambahkan produk ke daftar produk
        });
      }
    });
  }

  // Fungsi untuk mengambil data detail_customer_orders
  void fetchDataDetailCustomerOrder() {
    firestore
        .collection('customer_orders')
        .doc(widget.customerOrderId!) // Menggunakan widget.customerOrderId
        .collection(
            'detail_customer_orders') // Ganti dengan nama collection yang sesuai
        .get()
        .then((querySnapshot) {
      final newProductCards = <ProductCardDataCustomerOrder>[];
      querySnapshot.docs.forEach((doc) async {
        final detailData = doc.data() as Map<String, dynamic>;

        final productId = detailData['product_id'] as String;
        // Mencari nama produk berdasarkan productId
        final product = productData.firstWhere(
          (product) => product['id'] == productId,
          orElse: () => {
            'nama': 'Produk Tidak Ditemukan'
          }, // Default jika tidak ditemukan
        );

        final productCardData = ProductCardDataCustomerOrder(
          kodeProduk: detailData['product_id'] as String,
          namaProduk: product[
              'nama'], // Anda dapat mengisi nama produk berdasarkan productData
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

  void initializeCustomer() {
    selectedKode = widget.customerId;
    _selectedKodeListener();
    firestore
        .collection('customers')
        .where('id',
            isEqualTo: selectedKode) // Gunakan .where untuk mencocokkan ID
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final customerData =
            querySnapshot.docs.first.data() as Map<String, dynamic>;
        final namaCustomer = customerData['nama'];
        namaPelangganController.text = namaCustomer ?? '';
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    addProductCard();
    statusController.text = 'Dalam Proses';
    fetchData();

    if (widget.customerOrderId != null) {
      // Jika ada customerOrderId, ambil data dari Firestore
      FirebaseFirestore.instance
          .collection('customer_orders')
          .doc(widget.customerOrderId) // Menggunakan widget.customerOrderId
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            alamatPengirimanController.text = data['alamat_pengiriman'];
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_pesanan'];
            totalHargaController.text = data['total_harga'].toString();
            totalProdukController.text = data['total_produk'].toString();
            final tanggalKirimFirestore = data['tanggal_kirim'];
            if (tanggalKirimFirestore != null) {
              _selectedTanggalKirim =
                  (tanggalKirimFirestore as Timestamp).toDate();
            }
            final tanggalPesanFirestore = data['tanggal_pesan'];
            if (tanggalPesanFirestore != null) {
              _selectedTanggalPesan =
                  (tanggalPesanFirestore as Timestamp).toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });

      fetchDataDetailCustomerOrder(); // Ambil data detail_customer_orders
    }

    if (widget.customerId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializeCustomer();
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      selectedPelangganNotifier.addListener(_selectedKodeListener);
      selectedKode = selectedPelangganNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerOrderBloc, CustomerOrderBlocState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false; // Matikan isLoading saat successState
            });
          } else if (state is ErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            );
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
                                Navigator.pop(context, null);
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
                                  child: Icon(Icons.arrow_back,
                                      color: Colors.black),
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
                        PelangganDropdownWidget(
                          namaPelangganController: namaPelangganController,
                          customerId: widget.customerId,
                          isEnabled: widget.customerOrderId == null,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Nama Pelanggan',
                          placeholder: 'Nama Pelanggan',
                          controller: namaPelangganController,
                          isEnabled: false,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: DatePickerButton(
                                label: 'Tanggal Pesan',
                                selectedDate: _selectedTanggalPesan,
                                onDateSelected: (newDate) {
                                  setState(() {
                                    _selectedTanggalPesan = newDate;
                                  });
                                },
                                isEnabled: widget.statusCO != "Selesai",
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: DatePickerButton(
                                label: 'Tanggal Kirim',
                                selectedDate: _selectedTanggalKirim,
                                onDateSelected: (newDate) {
                                  setState(() {
                                    _selectedTanggalKirim = newDate;
                                  });
                                },
                                isEnabled: widget.statusCO != "Selesai",
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
                          isEnabled: widget.statusCO != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusCO != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Total Harga',
                                placeholder: 'Total Harga',
                                controller: totalHargaController,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Total Produk',
                                placeholder: 'Total Produk',
                                controller: totalProdukController,
                                isEnabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Status',
                          placeholder: 'Dalam Proses',
                          controller: statusController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
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
                            return ProductCardCustOrder(
                              productCardData: productCardData,
                              updateTotalHargaProduk: updateTotalHargaProduk,
                              productData: productData,
                              productCards: productCards,
                              isEnabled: widget.statusCO != "Selesai",
                            );
                          }).toList(),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.statusCO == "Selesai"
                                    ? null
                                    : () {
                                        // Handle save button press
                                        addOrUpdateCustomerOrder();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(59, 51, 51, 1),
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
                                onPressed: widget.statusCO == "Selesai"
                                    ? null
                                    : () {
                                        // Handle clear button press
                                        clearForm();
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(59, 51, 51, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 16.0),
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
                Positioned(
                  // Menambahkan Positioned untuk indikator loading
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.3), // Latar belakang semi-transparan
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          )),
        ));
  }
}
