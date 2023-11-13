import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/blocs/penjualan/surat_jalan_bloc.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/detail_surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/models/penjualan/surat_jalan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/suratJalanService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/custom_withField_card.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/deliveryOrder_dropdown.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/errorDialogWidget.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/success_dialog.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

// Buat objek yang akan menyimpan data untuk setiap card
class CardData {
  TextEditingController pcsController;
  TextEditingController dusController;
  String productID;
  int jumlahPesanan;

  CardData({
    required this.pcsController,
    required this.dusController,
    required this.productID,
    required this.jumlahPesanan,
  });
}

class FormSuratJalanScreen extends StatefulWidget {
  static const routeName = '/gudang/penjualan/shipment/form';
  final String? shipmentId;
  final String? deliveryId;
  final String? statusShp;

  const FormSuratJalanScreen(
      {Key? key, this.shipmentId, this.deliveryId, this.statusShp})
      : super(key: key);

  @override
  State<FormSuratJalanScreen> createState() => _FormSuratJalanScreenState();
}

class _FormSuratJalanScreenState extends State<FormSuratJalanScreen> {
  DateTime? _selectedDate;
  String? selectedNomorPerintahPengiriman;
  bool isLoading = false;

  //List
  List<Widget> detailPesananWidgets = [];
  List<CustomWithTextFieldCardContent> detailPesanan = [];
  // Deklarasikan list yang akan menyimpan data untuk setiap card
  List<CardData> cardDataList = [];

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //services
  final productService = ProductService();
  final suratJalanService = SuratJalanService();
  final shipmentService = SuratJalanService();
  final deliveryOrderService = DeliveryOrderService();
  final customerOrderService = CustomerOrderService();
  final customerService = CustomerService();

  //controllers
  TextEditingController catatanController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController nomorPesananPelanggan = TextEditingController();
  TextEditingController nomorSuratJalanController = TextEditingController();
  TextEditingController kodePenerimaController = TextEditingController();
  TextEditingController namaPenerimaController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController totalPcsProdukController = TextEditingController();

  // Fungsi untuk mengambil data dari Firestore
  Future<void> fetchDataFromFirestore(
    String selectedNomorPerintahPengiriman,
  ) async {
    final querySnapshot = await firestore
        .collection('delivery_orders')
        .doc(selectedNomorPerintahPengiriman)
        .collection('detail_delivery_orders')
        .get();

    detailPesananWidgets.clear();
    cardDataList.clear(); // Bersihkan list cardDataList

    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final jumlahPcsController = TextEditingController();
      final jumlahDusController = TextEditingController();

      // Tambahkan listener untuk mengupdate total saat controller berubah
      jumlahPcsController.addListener(() {
        updateTotalPcsProduk();
      });

      // Tambahkan controller ke dalam list cardDataList
      cardDataList.add(CardData(
        pcsController: jumlahPcsController,
        dusController: jumlahDusController,
        productID: data['product_id'],
        jumlahPesanan: data['jumlah'],
      ));

      final cardContentPcs = CustomWithTextFieldCardContent(
        text: '',
        isRow: true,
        leftHintText: 'Jumlah',
        rightHintText: 'Pcs',
        rightEnabled: false,
        controller: jumlahPcsController,
      );
      final cardContentDus = CustomWithTextFieldCardContent(
        text: '',
        isRow: true,
        leftHintText: 'Jumlah',
        rightHintText: 'Dus',
        rightEnabled: false,
        controller: jumlahDusController,
      );
      Map<String, dynamic>? product =
          await productService.getProductInfo(data['product_id']);
      final namaProduct = product?['nama'];
      final banyaknya = product?['banyaknya'];

      // Menambahkan cardContent ke detailPesananWidgets
      detailPesananWidgets.add(CustomWithTextFieldCard(
        content: [
          CustomWithTextFieldCardContent(
              text: 'Kode Barang: ${data['product_id']}'),
          CustomWithTextFieldCardContent(text: 'Nama Barang: $namaProduct '),
          CustomWithTextFieldCardContent(
              text: 'Jumlah : ${data['jumlah']} ${data['satuan']}'),
          CustomWithTextFieldCardContent(
              text: 'Total: ${data['jumlah'] / banyaknya} dus'),
          CustomWithTextFieldCardContent(
              text: 'Jumlah Pengiriman (Pcs):', isBold: true),
          cardContentPcs,
          CustomWithTextFieldCardContent(
              text: 'Jumlah Pengiriman (Dus):', isBold: true),
          cardContentDus,
        ],
      ));
    }
    setState(() {
      if (widget.shipmentId != null) {
        fetchDetail();
      }
    });
  }

// Tambahkan fungsi untuk menghitung total Pcs produk
  void updateTotalPcsProduk() {
    int totalPcs = 0;

    for (final cardData in cardDataList) {
      final jumlahPcs = int.tryParse(cardData.pcsController.text) ?? 0;
      totalPcs += jumlahPcs;
    }
    totalPcsProdukController.text = totalPcs.toString();
  }

  void fetchDetail() async {
    // Fetch the shipment detail
    final shipmentDetails =
        await shipmentService.getDetailShipments(widget.shipmentId ?? '');

    if (shipmentDetails != null) {
      // Iterate through each card and update its details
      for (int i = 0; i < cardDataList.length; i++) {
        // Find the corresponding detail shipment data by productID
        final detailShipment = shipmentDetails.firstWhere(
          (detail) => detail['product_id'] == cardDataList[i].productID,
          orElse: () => {},
        );

        // Update the data for the current card
        cardDataList[i].pcsController.text =
            detailShipment['jumlahPengiriman'].toString();
        cardDataList[i].dusController.text =
            detailShipment['jumlahPengirimanDus'].toString();
        cardDataList[i].pcsController.addListener(() {
          updateTotalPcsProduk();
        });
      }

      updateTotalPcsProduk();
    } else {
      // Handle the case where shipmentDetails is null
      print(
          'Detail Shipment tidak ditemukan atau terjadi kesalahan dalam pengambilan data.');
    }
  }

  void fetchCustomerDetail() async {
    Map<String, dynamic>? deliveryOrder = await deliveryOrderService
        .getDeliveryOrderInfo(widget.deliveryId ?? '');
    final customerOrderId = deliveryOrder?['customerOrderId'];
    Map<String, dynamic>? customerOrder =
        await customerOrderService.getCustomerOrderInfo(customerOrderId);
    Map<String, dynamic>? customer =
        await customerService.getCustomerInfo(customerOrder?['customer_id']);
    nomorPesananPelanggan.text = customerOrderId;
    namaPenerimaController.text = customer?['nama'];
    kodePenerimaController.text = customer?['id'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearForm() {
    // Hapus semua data dalam controller
    nomorSuratJalanController.clear();
    _selectedDate = null;
    selectedNomorPerintahPengiriman = null;
    kodePenerimaController.clear();
    namaPenerimaController.clear();
    alamatController.clear();
    totalPcsProdukController.clear();
    statusController.clear();
    catatanController.clear();
    nomorPesananPelanggan.clear();
    // Hapus semua data dalam cardDataList
    cardDataList.clear();
    // Hapus semua widget dalam detailPesananWidgets
    detailPesananWidgets.clear();
    // Panggil setState agar tampilan diperbarui
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      //untuk mengatasi asinkronus pada init state
      suratJalanService.generateNextShipmentId().then((nomorSuratJalan) {
        nomorSuratJalanController.text = nomorSuratJalan;
      });
    });
    statusController.text = "Dalam Proses";
    if (widget.shipmentId != null) {
      firestore
          .collection('shipments')
          .doc(widget.shipmentId)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          final data = documentSnapshot.data() as Map<String, dynamic>;
          setState(() {
            catatanController.text = data['catatan'] ?? '';
            statusController.text = data['status_shp'];
            alamatController.text = data['alamat_penerima'];
            nomorSuratJalanController.text = data['id'];
            selectedNomorPerintahPengiriman = data['delivery_order_id'];
            final tanggalPembuatanFirestore = data['tanggal_pembuatan'];
            if (tanggalPembuatanFirestore != null) {
              _selectedDate = (tanggalPembuatanFirestore as Timestamp).toDate();
            }
          });
        } else {
          print('Document does not exist on Firestore');
        }
      }).catchError((error) {
        print('Error getting document: $error');
      });
    }

    if (widget.deliveryId != null) {
      fetchDataFromFirestore(widget.deliveryId ?? '');
      updateTotalPcsProduk();
      fetchCustomerDetail();
    }
  }

  void addOrUpdate() {
    final shipmentBloc = BlocProvider.of<ShipmentBloc>(context);
    final shipment = Shipment(
        id: nomorSuratJalanController.text,
        alamatPenerima: alamatController.text,
        catatan: catatanController.text,
        deliveryOrderId: selectedNomorPerintahPengiriman ?? '',
        status: 1,
        statusShp: statusController.text,
        totalPcs: int.tryParse(totalPcsProdukController.text) ?? 0,
        tanggalPembuatan: _selectedDate ?? DateTime.now(),
        detailListShipment: []);
    for (int index = 0; index < cardDataList.length; index++) {
      String jumlahDus = cardDataList[index].dusController.text;
      String jumlahPcs = cardDataList[index].pcsController.text;
      String kodeProduk = cardDataList[index].productID;
      String jumlahPesanan = cardDataList[index].jumlahPesanan.toString();
      double jumlahDusPesanan = (double.tryParse(jumlahPesanan) ?? 0) / 2000;
      int jumlahDusPesananInt = jumlahDusPesanan.toInt();

      final detailShipment = DetailShipment(
          id: '',
          shipmentId: '',
          jumlahDusPesanan: jumlahDusPesananInt,
          jumlahPengiriman: int.tryParse(jumlahPcs) ?? 0,
          jumlahPengirimanDus: int.tryParse(jumlahDus) ?? 0,
          jumlahPesanan: int.tryParse(jumlahPesanan) ?? 0,
          productId: kodeProduk,
          status: 1);
      shipment.detailListShipment.add(detailShipment);
    }

    if (widget.shipmentId != null) {
      shipmentBloc.add(UpdateShipmentEvent(widget.shipmentId ?? '', shipment));
    } else {
      shipmentBloc.add(AddShipmentEvent(shipment));
    }

    updateTotalPcsProduk();
  }

  void _showSuccessMessageAndNavigateBack() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          message: 'Berhasil menyimpan surat jalan',
        );
      },
    ).then((_) {
      Navigator.pop(context, null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShipmentBloc, ShipmentBlocState>(
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
          ).then((_) {
            Navigator.pop(context, null);
          });
        } else if (state is LoadingState) {
          setState(() {
            isLoading = true;
          });
        }
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
                                child:
                                    Icon(Icons.arrow_back, color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          const Flexible(
                            child: Text(
                              'Surat Jalan',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextFieldWidget(
                        label: 'Nomor Surat Jalan',
                        placeholder: 'Nomor Surat Jalan',
                        controller: nomorSuratJalanController,
                        isEnabled: false,
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      DatePickerButton(
                        label: 'Tanggal Pembuatan',
                        selectedDate: _selectedDate,
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                          });
                        },
                        isEnabled: widget.statusShp != "Selesai",
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      DeliveryOrderDropDown(
                        selectedDO: selectedNomorPerintahPengiriman,
                        onChanged: (newValue) {
                          setState(() {
                            selectedNomorPerintahPengiriman = newValue ?? '';
                            fetchDataFromFirestore(
                                selectedNomorPerintahPengiriman ?? '');
                          });
                        },
                        namaPelangganController: namaPenerimaController,
                        kodePelangganController: kodePenerimaController,
                        alamatController: alamatController,
                        nomorPesananPelanggan: nomorPesananPelanggan,
                        isEnabled: widget.shipmentId == null,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              label: 'Penerima',
                              placeholder: 'Penerima',
                              controller: kodePenerimaController,
                              isEnabled: false,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFieldWidget(
                              label: 'Nama Penerima',
                              placeholder: 'Nama Penerima',
                              controller: namaPenerimaController,
                              isEnabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFieldWidget(
                        label: 'Nomor Pesanan Pelanggan',
                        placeholder: 'Nomor Pesanan Pelanggan',
                        controller: nomorPesananPelanggan,
                        isEnabled: false,
                      ),
                      const SizedBox(height: 16),
                      TextFieldWidget(
                        label: 'Alamat Penerima',
                        placeholder: 'Alamat',
                        controller: alamatController,
                        multiline: true,
                        isEnabled: widget.statusShp != "Selesai",
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFieldWidget(
                              label: 'Total Produk',
                              placeholder: '0',
                              controller: totalPcsProdukController,
                              isEnabled: false,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: TextFieldWidget(
                              label: ' ',
                              placeholder: 'Pcs',
                              controller: namaPenerimaController,
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
                      TextFieldWidget(
                        label: 'Catatan',
                        placeholder: 'Catatan',
                        controller: catatanController,
                        isEnabled: widget.statusShp != "Selesai",
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
                        physics: const BouncingScrollPhysics(),
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
                              onPressed: widget.statusShp == "Selesai"
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
                              onPressed: widget.statusShp == "Selesai"
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
                  color: Colors.white
                      .withOpacity(0.3), // Latar belakang semi-transparan
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        )),
      ),
    );
  }
}
