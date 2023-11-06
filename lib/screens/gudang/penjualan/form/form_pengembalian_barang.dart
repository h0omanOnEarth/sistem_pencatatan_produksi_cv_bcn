import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/customer_order_return_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/customer_order_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_customer_order_return.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderReturnService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/fakturService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/suratJalanService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_withField_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/fakturDropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class CardData {
  TextEditingController pcsController;
  String productID;
  int jumlahPesanan;

  CardData({
    required this.pcsController,
    required this.productID,
    required this.jumlahPesanan,
  });
}

class FormPengembalianBarangScreen extends StatefulWidget {
  static const routeName = '/gudang/penjualan/pengembalian/form';
  final String? invoiceId;
  final String? custOrderReturnId;
  final String? statusCor;

  const FormPengembalianBarangScreen(
      {Key? key, this.invoiceId, this.custOrderReturnId, this.statusCor})
      : super(key: key);

  @override
  State<FormPengembalianBarangScreen> createState() =>
      _FormPengembalianBarangScreenState();
}

class _FormPengembalianBarangScreenState
    extends State<FormPengembalianBarangScreen> {
  DateTime? _selectedDate;
  String? selectedNomorFaktur;
  bool isLoading = false;

  TextEditingController jumlahController = TextEditingController();
  TextEditingController catatanController = TextEditingController();
  TextEditingController namaPelangganController = TextEditingController();
  TextEditingController totalProdukController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nomorPesananPelanggan = TextEditingController();
  TextEditingController kodePelangganController = TextEditingController();
  TextEditingController alasanPengembalianController = TextEditingController();
  TextEditingController nomorSuratJalanController = TextEditingController();
  TextEditingController alamatController = TextEditingController();

  List<Widget> detailPesananWidgets = [];
  List<CustomWithTextFieldCardContent> detailPesanan = [];
  List<CardData> cardDataList = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final productService = ProductService();
  final customerOrderReturnService = CustomerOrderReturnService();
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();
  final deliveryOrderService = DeliveryOrderService();
  final suratJalanService = SuratJalanService();
  final invoiceService = FakturService();

  // Fungsi untuk mengambil data dari Firestore
  Future<void> fetchDataFromFirestore(
    String selectedNomorFaktur,
  ) async {
    final querySnapshot = await firestore
        .collection('invoices')
        .doc(selectedNomorFaktur)
        .collection('detail_invoices')
        .get();

    detailPesananWidgets.clear();
    cardDataList.clear(); // Bersihkan list cardDataList

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final jumlahPcsController = TextEditingController();

      // Tambahkan controller ke dalam list cardDataList
      cardDataList.add(CardData(
        pcsController: jumlahPcsController,
        productID: data['product_id'],
        jumlahPesanan: data['jumlah_pengiriman'],
      ));

      final cardContentPcs = CustomWithTextFieldCardContent(
        text: '',
        isRow: true,
        leftHintText: 'Jumlah',
        rightHintText: 'Pcs',
        rightEnabled: false,
        controller: jumlahPcsController,
      );
      Map<String, dynamic>? product =
          await productService.getProductInfo(data['product_id']);
      final namaProduct = product?['nama'];

      // Menambahkan cardContent ke detailPesananWidgets
      detailPesananWidgets.add(CustomWithTextFieldCard(
        content: [
          CustomWithTextFieldCardContent(
              text: 'Kode Barang: ${data['product_id']}'),
          CustomWithTextFieldCardContent(text: 'Nama Barang: $namaProduct '),
          CustomWithTextFieldCardContent(
              text: 'Jumlah : ${data['jumlah_pengiriman']} Pcs'),
          CustomWithTextFieldCardContent(
              text: 'Jumlah Pengiriman (Pcs):', isBold: true),
          cardContentPcs,
        ],
      ));
    }
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchDetail() async {
    // Fetch the shipment detail
    final customerOrderReturnDetails = await customerOrderReturnService
        .getDetailCustOrderReturn(widget.custOrderReturnId ?? '');
    if (customerOrderReturnDetails != null) {
      // Lakukan sesuatu dengan daftar detail pengiriman yang diterima
      for (int i = 0; i < cardDataList.length; i++) {
        // Find the corresponding detail shipment data by productID
        final detailCustOrRet = customerOrderReturnDetails.firstWhere(
            (detail) => detail['product_id'] == cardDataList[i].productID,
            orElse: () => {});
        cardDataList[i].pcsController.text =
            detailCustOrRet['jumlahPengembalian'].toString();
        cardDataList[i].jumlahPesanan = detailCustOrRet['jumlahPesanan'];
      }
    } else {
      // Handle the case where shipmentDetails is null
      print(
          'Detail Shipment tidak ditemukan atau terjadi kesalahan dalam pengambilan data.');
    }
  }

  void fetchCustomerDetail() async {
    Map<String, dynamic>? invoice =
        await invoiceService.getFakturInfo(widget.invoiceId ?? '');
    Map<String, dynamic>? shipment =
        await suratJalanService.getSuratJalanInfo(invoice?['shipmentId']);
    Map<String, dynamic>? deliveryOrder = await deliveryOrderService
        .getDeliveryOrderInfo(shipment?['deliveryOrderId'] as String);
    final customerOrderId = deliveryOrder?['customerOrderId'] as String;
    Map<String, dynamic>? customerOrder =
        await customerOrderService.getCustomerOrderInfo(customerOrderId);
    Map<String, dynamic>? customer =
        await customerService.getCustomerInfo(customerOrder?['customer_id']);

    namaPelangganController.text = customer?['nama'];
    kodePelangganController.text = customer?['id'];
    nomorSuratJalanController.text = shipment?['id'];
    alamatController.text = shipment?['alamatPenerima'];
  }

  @override
  void initState() {
    super.initState();
    statusController.text = "Dalam Proses";
    if (widget.custOrderReturnId != null) {
      firestore
          .collection('customer_order_returns')
          .doc(widget.custOrderReturnId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_cor'];
            alasanPengembalianController.text = data['alasan_pengembalian'];
            final tanggalPengembalianFirestore = data['tanggal_pengembalian'];
            if (tanggalPengembalianFirestore != null) {
              _selectedDate =
                  (tanggalPengembalianFirestore as Timestamp).toDate();
            }
            selectedNomorFaktur = data['invoice_id'];
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }

    if (widget.invoiceId != null) {
      fetchDataFromFirestore(widget.invoiceId ?? '');
      fetchCustomerDetail();
      fetchDetail();
    }
  }

  void addOrUpdate() {
    final customerOrderReturnBloc =
        BlocProvider.of<CustomerOrderReturnBloc>(context);
    final customerOrderReturn = CustomerOrderReturn(
        alasanPengembalian: alasanPengembalianController.text,
        catatan: catatanController.text,
        id: '',
        invoiceId: selectedNomorFaktur ?? '',
        status: 1,
        tanggalPengembalian: _selectedDate ?? DateTime.now(),
        statusCor: statusController.text,
        detailCustomerOrderReturnList: []);

    for (int index = 0; index < cardDataList.length; index++) {
      String jumlahPcs = cardDataList[index].pcsController.text;
      String kodeProduk = cardDataList[index].productID;
      String jumlahPesanan = cardDataList[index].jumlahPesanan.toString();

      final detailCustomerOrderReturn = DetailCustomerOrderReturn(
          customerOrderReturnId: '',
          id: '',
          jumlahPengembalian: int.tryParse(jumlahPcs) ?? 0,
          jumlahPesanan: int.tryParse(jumlahPesanan) ?? 0,
          productId: kodeProduk,
          status: 1);
      customerOrderReturn.detailCustomerOrderReturnList
          .add(detailCustomerOrderReturn);
    }

    if (widget.custOrderReturnId != null) {
      customerOrderReturnBloc.add(UpdateCustomerOrderReturnEvent(
          widget.custOrderReturnId ?? '', customerOrderReturn));
    } else {
      customerOrderReturnBloc
          .add(AddCustomerOrderReturnEvent(customerOrderReturn));
    }
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan pengembalian pesanan penjualan',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  void clearFormFields() {
    setState(() {
      statusController.text = "Dalam Proses";
      _selectedDate = null;
      selectedNomorFaktur = null;
      nomorSuratJalanController.clear();
      nomorPesananPelanggan.clear();
      kodePelangganController.clear();
      namaPelangganController.clear();
      alamatController.clear();
      alasanPengembalianController.clear();
      jumlahController.clear();
      catatanController.clear();
      statusController.clear();
      totalProdukController.clear();
      detailPesananWidgets.clear();
      cardDataList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CustomerOrderReturnBloc, CustomerOrderReturnBlocState>(
        listener: (context, state) async {
          if (state is SuccessState) {
            _showSuccessMessageAndNavigateBack();
            setState(() {
              isLoading = false; // Matikan isLoading saat successState
            });
          } else if (state is CustomerOrderReturnErrorState) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ErrorDialog(errorMessage: state.errorMessage);
              },
            ).then((_) {
              Navigator.pop(context, null);
            });
          } else if (state is CustomerOrderReturnLoadingState) {
            setState(() {
              isLoading = true;
            });
          }
          if (state is! CustomerOrderReturnLoadingState) {
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
                                'Pengembalian Barang',
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
                          label: 'Tanggal Pengembalian',
                          selectedDate: _selectedDate,
                          onDateSelected: (newDate) {
                            setState(() {
                              _selectedDate = newDate;
                            });
                          },
                          isEnabled: widget.statusCor != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        FakturDropdown(
                          selectedFaktur: selectedNomorFaktur,
                          onChanged: (newValue) {
                            setState(() {
                              selectedNomorFaktur = newValue ?? '';
                              //fetch cards
                              fetchDataFromFirestore(selectedNomorFaktur ?? '');
                            });
                          },
                          namaPelangganController: namaPelangganController,
                          kodePelangganController: kodePelangganController,
                          nomorPesananPelanggan: nomorPesananPelanggan,
                          nomorSuratJalanController: nomorSuratJalanController,
                          alamatController: alamatController,
                          isEnabled: widget.custOrderReturnId == null,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Nomor Surat Jalan',
                          placeholder: 'Nomor Surat Jalan',
                          isEnabled: false,
                          controller: nomorSuratJalanController,
                        ),
                        const SizedBox(height: 16.0),
                        TextFieldWidget(
                          label: 'Nomor Pesanan Pelanggan',
                          placeholder: 'Nomor Pesanan Pelanggan',
                          isEnabled: false,
                          controller: nomorPesananPelanggan,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Kode Pelanggan',
                                placeholder: 'Kode Pelanggan',
                                controller: kodePelangganController,
                                isEnabled: false,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: TextFieldWidget(
                                label: 'Nama Pelanggan',
                                placeholder: 'Nama Pelanggan',
                                controller: namaPelangganController,
                                isEnabled: false,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: 'Alamat',
                          placeholder: 'Alamat',
                          controller: alamatController,
                          multiline: true,
                          isEnabled: false,
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: 'Alasan Pengembalian',
                          placeholder: 'Alasan',
                          controller: alasanPengembalianController,
                          multiline: true,
                          isEnabled: widget.statusCor != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Total Produk',
                          placeholder: 'Total Produk',
                          controller: totalProdukController,
                          isEnabled: false,
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: 'Status',
                          placeholder: 'Dalam Proses',
                          controller: statusController,
                          isEnabled: false,
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        TextFieldWidget(
                          label: 'Catatan',
                          placeholder: 'Catatan',
                          controller: catatanController,
                          isEnabled: widget.statusCor != "Selesai",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        const Text(
                          'Detail Pesanan',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: detailPesananWidgets.length,
                          itemBuilder: (context, index) {
                            return detailPesananWidgets[index];
                          },
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.statusCor == "Selesai"
                                    ? null
                                    : () {
                                        // Handle save button press
                                        addOrUpdate();
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
                                onPressed: widget.statusCor == "Selesai"
                                    ? null
                                    : () {
                                        // Handle clear button press
                                        clearFormFields();
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
                    color: Colors.white
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
