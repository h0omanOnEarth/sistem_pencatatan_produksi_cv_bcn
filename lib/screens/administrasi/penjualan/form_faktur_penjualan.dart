import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/faktur_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_invoice.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/invoice.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/suratJalanDropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormFakturPenjualanScreen extends StatefulWidget {
  static const routeName = '/form_faktur_penjualan_screen';
  final String? invoiceId;
  final String? shipmentId;
  final String? statusFk;

  const FormFakturPenjualanScreen({Key? key, this.invoiceId, this.shipmentId, this.statusFk}) : super(key: key);
  
  @override
  State<FormFakturPenjualanScreen> createState() =>
      _FormFakturPenjualanScreenState();
}

class _FormFakturPenjualanScreenState extends State<FormFakturPenjualanScreen> {
  DateTime? _selectedDate;
  String? selectedNomorSuratJalan;
  String selectedNomorRekening = '2711598075';
  String selectedMetodePembayaran = 'Transfer BCA';
  String selectedStatusPembayaran = 'Belum Bayar';
  int total=0;
  int totalProduk=0;
  bool isNomorRekeningDisabled = false;
  bool isLoading = false;
  
  TextEditingController catatanController = TextEditingController();
  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController totalHargaController = TextEditingController();
  TextEditingController totalProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nomorPesananPelanggan = TextEditingController();
  TextEditingController kodePelangganController = TextEditingController();
  TextEditingController nomorDeliveryOrderController = TextEditingController();

  //list
  List<Map<String, dynamic>> materialDetailsData= []; 
  List<Widget> customCards = [];

  //service and providers
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  final productService = ProductService();
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();
  final deliveryOrderService = DeliveryOrderService();

Future<void> fetchShipments() async {
  QuerySnapshot snapshot;

  if (widget.invoiceId != null) {
    snapshot = await firestore
        .collection('invoices')
        .doc(widget.invoiceId ?? '')
        .collection('detail_invoices')
        .get();
  } else {
    snapshot = await firestore
        .collection('shipments')
        .doc(selectedNomorSuratJalan)
        .collection('detail_shipments')
        .get();
  }

  materialDetailsData.clear();
  customCards.clear();

  for (final doc in snapshot.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final productId = data['product_id'] as String? ?? '';

    Future<Map<String, dynamic>> productInfoFuture =
        productService.fetchProductInfo(productId);

    final productInfoSnapshot = await productInfoFuture;

    final productName = productInfoSnapshot['nama'] as String;
    final productPrice = (productInfoSnapshot['harga'] as num).toDouble();
    final jumlahPcs = data['jumlah_pengiriman'] as int? ?? 0;
    final jumlahDus = data['jumlah_pengiriman_dus'] as int? ?? 0;

    // Calculate subtotal
    int subtotal = (productPrice * jumlahPcs).toInt(); 

    // Create the CustomCard
    final customCard = CustomCard(
      content: [
        CustomCardContent(text: 'Kode Barang: $productId'),
        CustomCardContent(text: 'Nama: $productName'),
        CustomCardContent(
            text: 'Jumlah (Pcs): ${jumlahPcs.toString()}'),
        CustomCardContent(
            text: 'Jumlah (Dus): ${jumlahDus.toString()}'),
        CustomCardContent(
            text: 'Harga per Pcs: Rp ${productPrice.toInt().toString()}'), 
        CustomCardContent(
            text: 'Subtotal: Rp ${subtotal.toString()}'), 
      ],
    );

    Map<String, dynamic> detailMaterial = {
      'productId': productId, 
      'jumlahPcs': jumlahPcs,
      'jumlahDus': jumlahDus,
      'harga': productPrice,
      'subtotal': subtotal,
    };
    materialDetailsData.add(detailMaterial); 
    customCards.add(customCard);
  }
  setState(() {});
}

  void initializeShipment() async{
    selectedNomorSuratJalan = widget.shipmentId;
    firestore
    .collection('shipments')
    .where('id', isEqualTo: widget.shipmentId) // Gunakan .where untuk mencocokkan ID
    .get()
    .then((QuerySnapshot querySnapshot) async {
    if (querySnapshot.docs.isNotEmpty) {
      final shipmentData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      nomorDeliveryOrderController.text = shipmentData['delivery_order_id'];
        Map<String, dynamic>? deliveryOrder = await deliveryOrderService.getDeliveryOrderInfo(shipmentData['delivery_order_id']);
        final customerOrderId = deliveryOrder?['customerOrderId'] as String;
        Map<String, dynamic>? customerOrder = await customerOrderService.getCustomerOrderInfo(customerOrderId);
        Map<String, dynamic>? customer = await customerService.getCustomerInfo(customerOrder?['customer_id']);
        namaPelangganController.text = customer?['nama'];
        kodePelangganController.text = customer?['id'];
        nomorPesananPelanggan.text = customerOrder?['id'];
    } else {
      print('Document does not exist on Firestore');
    }
  }).catchError((error) {
    print('Error getting document: $error');
  });
  }

  String formatRupiah(int amount) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
  return formatter.format(amount);
}


  @override
  void initState(){
    super.initState();
    statusController.text = "Dalam Proses";

    if(widget.invoiceId!=null){
        firestore.collection('invoices').doc(widget.invoiceId) // Menggunakan widget.customerOrderId
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data() as Map<String, dynamic>;
        setState(() {
          catatanController.text = data['catatan'] ?? '';
          statusController.text = data['status_fk'];
          final tanggalPembuatanFirestore = data['tanggal_pembuatan'];
          if (tanggalPembuatanFirestore != null) {
            _selectedDate = (tanggalPembuatanFirestore as Timestamp).toDate();
          }
          selectedMetodePembayaran = data['metode_pembayaran'];
          selectedStatusPembayaran = data['status_pembayaran'];
          selectedNomorSuratJalan = data['shipment_id'];
           // Periksa apakah data['nomor_rekening'] adalah null atau string kosong
        if (data['nomor_rekening'] == null || data['nomor_rekening'] == '') {
          isNomorRekeningDisabled = true; // Dinonaktifkan jika null atau kosong
        }
        });
        fetchShipments();
        _updateTotal();
      } else {
        print('Document does not exist on Firestore');
      }
    }).catchError((error) {
      print('Error getting document: $error');
    });
    }

    if(widget.shipmentId!=null){
      initializeShipment();
    }

  }

void _updateTotal() async {
  int newTotalProduk = 0;
  int newTotal = 0;

  // Mengambil data dari Firestore subkoleksi detail_shipments
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('shipments')
      .doc(selectedNomorSuratJalan) // Ganti dengan ID dokumen shipment yang sesuai
      .collection('detail_shipments')
      .get();

  // Iterasi melalui hasil query dan menghitung total
  for (QueryDocumentSnapshot document in querySnapshot.docs) {
    Map<String, dynamic> detail = document.data() as Map<String, dynamic>;

    // Validasi apakah 'jumlah_pengiriman' adalah angka
    if (detail.containsKey('jumlah_pengiriman')) {
      dynamic jumlahPengiriman = detail['jumlah_pengiriman'];
      if (jumlahPengiriman is int) {
        newTotalProduk += jumlahPengiriman;
      } else if (jumlahPengiriman is String) {
        // Cek apakah bisa di-parse ke dalam int
        int? parsedValue = int.tryParse(jumlahPengiriman);
        if (parsedValue != null) {
          newTotalProduk += parsedValue;
        }
      }
    }

    Map<String, dynamic>? product = await productService.fetchProductInfo(detail['product_id']);
    
    // Pastikan product['harga'] adalah angka sebelum mengonversinya
    if (product.containsKey('harga')) {
      dynamic harga = product['harga'];
      if (harga is int) {
        // Hitung total dengan menggabungkan jumlah_pengiriman * harga
        newTotal += newTotalProduk * harga;
      } else if (harga is String) {
        // Cek apakah bisa di-parse ke dalam int
        int? parsedValue = int.tryParse(harga);
        if (parsedValue != null) {
          // Hitung total dengan menggabungkan jumlah_pengiriman * harga
          newTotal += newTotalProduk * parsedValue;
        }
      }
    }
  }

  setState(() {
    totalProduk = newTotalProduk;
    total = newTotal;
  });

  // Update controller values
  totalHargaController.text = formatRupiah(total);
  totalProdukController.text = totalProduk.toString();
}

void addOrUpdate(){
    final invoiceBloc = BlocProvider.of<InvoiceBloc>(context);
    if (isNomorRekeningDisabled) {
    selectedNomorRekening = '';
    }
    final invoice = Invoice(id: '', metodePembayaran: selectedMetodePembayaran, nomorRekening: selectedNomorRekening, shipmentId: selectedNomorSuratJalan??'', status: 1, statusFk: statusController.text, total: total, totalProduk: totalProduk, tanggalPembuatan: _selectedDate??DateTime.now(), statusPembayaran: selectedStatusPembayaran, catatan: catatanController.text, detailInvoices: []);
    
    for (var productCardData in materialDetailsData) {
      final detailInvoice = DetailInvoice(id: '', invoiceId: '', productId: productCardData['productId'], harga: productCardData['harga'], jumlahPengiriman: productCardData['jumlahPcs'], jumlahPengirimanDus: productCardData['jumlahDus'], subtotal: productCardData['subtotal'], status: 1);
      invoice.detailInvoices.add(detailInvoice);
    }

    if(widget.invoiceId!=null){
      invoiceBloc.add(UpdateInvoiceEvent(widget.invoiceId??'', invoice));
    }else{
      invoiceBloc.add(AddInvoiceEvent(invoice));
    }

}

void clearFormFields() {
  setState(() {
    _selectedDate = null;
    selectedNomorSuratJalan = null;
    selectedNomorRekening = '2711598075';
    selectedMetodePembayaran = 'Transfer BCA';
    selectedStatusPembayaran = 'Belum Bayar';
    total = 0;
    totalProduk = 0;
    catatanController.clear();
    namaPelangganController.clear();
    totalHargaController.clear();
    totalProdukController.clear();
    statusController.clear();
    nomorPesananPelanggan.clear();
    kodePelangganController.clear();
    materialDetailsData.clear();
    isNomorRekeningDisabled = false;
    customCards.clear();
  });
}

void _showSuccessMessageAndNavigateBack() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        message: 'Berhasil menyimpan faktur penjualan.',
      );
    },
    ).then((_) {
      Navigator.pop(context,null);
    });
  }


@override
Widget build(BuildContext context) {
   final bool isShipmentSelected = selectedNomorSuratJalan != null;
   return BlocListener<InvoiceBloc, InvoiceBlocState>(
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
                            'Faktur Penjualan',
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
                  label: 'Tanggal Faktur',
                  selectedDate: _selectedDate,
                  onDateSelected: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                  },
                  isEnabled: widget.statusFk!="Selesai",
                  ),
                  const SizedBox(height: 16.0,),
                  SuratJalanDropDown(
                    selectedSuratJalan: selectedNomorSuratJalan,
                    onChanged: (newValue) {
                      setState(() {
                        selectedNomorSuratJalan = newValue??'';
                        fetchShipments();
                        _updateTotal();
                        // Update text fields dengan totalHarga dan totalProduk
                      });
                    },
                    namaPelangganController: namaPelangganController,
                    kodePelangganController: kodePelangganController,
                    nomorPesananPelanggan: nomorPesananPelanggan,
                    nomorDeliveryOrderController: nomorDeliveryOrderController,
                    isEnabled: widget.invoiceId==null,
                  ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                      label: 'Nomor Perintah Pengiriman',
                      placeholder: 'Nomor Perintah Pengiriman',
                      controller: nomorDeliveryOrderController,
                      isEnabled: false,
                    ),
                  const SizedBox(height: 16.0),
                  TextFieldWidget(
                      label: 'Nomor Pesanan',
                      placeholder: 'Nomor Pesanan',
                      controller: nomorPesananPelanggan,
                      isEnabled: false,
                    ),
                  const SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Expanded(child:  
                      TextFieldWidget(
                          label: 'Kode Pelanggan',
                          placeholder: '-',
                          controller: kodePelangganController,
                          isEnabled: false,
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Expanded(child:
                      TextFieldWidget(
                          label: 'Nama Pelanggan',
                          placeholder: '-',
                          controller: namaPelangganController,
                          isEnabled: false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  DropdownWidget(
                    label: 'Metode Pembayaran',
                    selectedValue: selectedMetodePembayaran, // Isi dengan nilai yang sesuai
                    items: const ['Transfer BCA', 'Tunai'],
                    onChanged: (newValue) {
                      setState(() {
                        selectedMetodePembayaran = newValue; // Update _selectedValue saat nilai berubah
                        if (selectedMetodePembayaran == 'Tunai') {
                            isNomorRekeningDisabled = true;
                          } else {
                            isNomorRekeningDisabled = false;
                          }
                      });
                    },
                    isEnabled: widget.statusFk!="Selesai",
                  ),
                  const SizedBox(height: 16.0,),
                  DropdownWidget(
                    label: 'Nomor Rekening',
                    selectedValue: selectedNomorRekening, // Isi dengan nilai yang sesuai
                    items: const ['2711598075', '5120181868'],
                    onChanged: (newValue) {
                      setState(() {
                        selectedNomorRekening = newValue; // Update _selectedValue saat nilai berubah
                      });
                    },
                    isEnabled: !isNomorRekeningDisabled && widget.statusFk!="Selesai",
                  ),
                  const SizedBox(height: 16.0,),
                  DropdownWidget(
                    label: 'Status Pembayaran',
                    selectedValue: selectedStatusPembayaran, // Isi dengan nilai yang sesuai
                    items: const ['Belum Bayar', 'Lunas'],
                    onChanged: (newValue) {
                      setState(() {
                        selectedStatusPembayaran = newValue; // Update _selectedValue saat nilai berubah
                      });
                    },
                    isEnabled: widget.statusFk!="Selesai",
                  ),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                    label: 'Catatan',
                    placeholder: 'Catatan',
                    controller: catatanController,
                    isEnabled: widget.statusFk!="Selesai",
                  ),
                  const SizedBox(height: 16.0,),
                  TextFieldWidget(
                  label: 'Status',
                  placeholder: 'Dalam Proses',
                  controller: statusController,
                  isEnabled: false,
                ),
                const SizedBox(height: 16.0,),
                if (!isShipmentSelected)
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0,),
                  if (!isShipmentSelected)
                  const Text(
                    'Tidak ada detail pesanan',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16.0,),
                  //cards
                    //cards
                  if (isShipmentSelected)
                  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detail Pesanan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16.0,),
                   ListView.builder(
                    shrinkWrap: true,
                    itemCount: customCards.length,
                    itemBuilder: (context, index) {
                      return customCards[index];
                    },
                  )
                  ],
                ),
                  const SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: widget.statusFk == "Selesai" ? null :() {
                            // Handle save button press
                            addOrUpdate();
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
                          onPressed: widget.statusFk == "Selesai" ? null : () {
                            // Handle clear button press
                            clearFormFields();
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
          ), if (isLoading)
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
   )
  );
}
}

