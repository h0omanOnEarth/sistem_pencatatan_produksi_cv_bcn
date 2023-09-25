import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/faktur_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_invoice.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/invoice.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/general_drop_down.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/suratJalanDropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class FormFakturPenjualanScreen extends StatefulWidget {
  static const routeName = '/form_faktur_penjualan_screen';
  final String? invoiceId;
  final String? shipmentId;

  const FormFakturPenjualanScreen({Key? key, this.invoiceId, this.shipmentId}) : super(key: key);
  
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
  bool  isFirstTime = false;
  int total=0;
  int totalProduk=0;
  bool isNomorRekeningDisabled = false;
  
  TextEditingController catatanController = TextEditingController();
  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController totalHargaController = TextEditingController();
  TextEditingController totalProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nomorPesananPelanggan = TextEditingController();
  TextEditingController kodePelangganController = TextEditingController();

  //list
  List<Map<String, dynamic>> materialDetailsData= []; // Initialize the list

  //service and providers
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Instance Firestore
  final productService = ProductService();

  @override
  void initState(){
    super.initState();
    statusController.text = "Dalam Proses";

    if(widget.invoiceId!=null){
      isFirstTime = true;
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
  totalHargaController.text = total.toString();
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

  _showSuccessMessageAndNavigateBack();
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
   return BlocProvider(
    create: (context) => InvoiceBloc(),
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
             DatePickerButton(
                        label: 'Tanggal Faktur',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
              ),
              const SizedBox(height: 16.0,),
              SuratJalanDropDown(
                    selectedSuratJalan: selectedNomorSuratJalan,
                    onChanged: (newValue) {
                      setState(() {
                        selectedNomorSuratJalan = newValue??'';
                        materialDetailsData.clear();
                         _updateTotal();
                        // Update text fields dengan totalHarga dan totalProduk
                      });
                    },
                    namaPelangganController: namaPelangganController,
                    kodePelangganController: kodePelangganController,
                    nomorPesananPelanggan: nomorPesananPelanggan,
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
                isEnabled: !isNomorRekeningDisabled,
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
              ),
              const SizedBox(height: 16.0,),
              TextFieldWidget(
                label: 'Catatan',
                placeholder: 'Catatan',
                controller: catatanController,
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
                FutureBuilder<QuerySnapshot>(
                  future: (widget.invoiceId != null && isFirstTime == true)
                      ? firestore
                          .collection('invoices')
                          .doc(widget.invoiceId ?? '')
                          .collection('detail_invoices')
                          .get()
                      : firestore
                          .collection('shipments')
                          .doc(selectedNomorSuratJalan)
                          .collection('detail_shipments')
                          .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('Tidak ada data detail pesanan.');
                    }

                    final List<Widget> customCards = [];

                    for (final doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final productId = data['product_id'] as String? ?? '';

                      Future<Map<String, dynamic>> productInfoFuture =
                          productService.fetchProductInfo(productId);

                      customCards.add(
                        FutureBuilder<Map<String, dynamic>>(
                          future: productInfoFuture,
                          builder: (context, materialInfoSnapshot) {
                            if (materialInfoSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (materialInfoSnapshot.hasError) {
                              return Text('Error: ${materialInfoSnapshot.error}');
                            }

                            final productInfoData = materialInfoSnapshot.data ?? {};
                            final productName = productInfoData['nama'] as String;
                            final productPrice = (productInfoData['harga'] as num).toDouble();

                           // Calculate subtotal
                            int subtotal = (productPrice * data['jumlah_pengiriman']).toInt(); // 
                           
                            // Create the CustomCard
                            final customCard = CustomCard(
                              content: [
                                CustomCardContent(text: 'Kode Barang: $productId'),
                                CustomCardContent(text: 'Nama: $productName'),
                                CustomCardContent(
                                    text:
                                        'Jumlah (Pcs): ${data['jumlah_pengiriman'].toString()}'),
                                CustomCardContent(
                                    text:
                                        'Jumlah (Dus): ${data['jumlah_pengiriman_dus'].toString()}'),
                                CustomCardContent(
                                    text:
                                        'Harga per Pcs: Rp ${productPrice.toInt().toString()}'), // Format price
                                CustomCardContent(
                                    text: 'Subtotal: Rp ${subtotal.toString()}'), // Format subtotal
                              ],
                            );
                       
                            Map<String, dynamic> detailMaterial = {
                              'productId': productId, // Add fields you need
                              'jumlahPcs': data['jumlah_pengiriman'],
                              'jumlahDus': data['jumlah_pengiriman_dus'],
                              'harga': productPrice,
                              'subtotal': subtotal,
                            };
                            materialDetailsData.add(detailMaterial); // Add to the list
                            isFirstTime = false;
                            return customCard;
                          },
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: customCards.length,
                      itemBuilder: (context, index) {
                        return customCards[index];
                      },
                    );
                  },
                ),
              ],
            ),
              const SizedBox(height: 16.0,),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
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
                      onPressed: () {
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
    ),
   )
  );
}
}

