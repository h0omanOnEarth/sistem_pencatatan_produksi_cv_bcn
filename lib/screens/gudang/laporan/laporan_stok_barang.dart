import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Represents the XlsIO widget class.
class LaporanBarangGudang extends StatelessWidget {
  static const routeName = '/gudang/laporan/barang';

  const LaporanBarangGudang({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateExcelStatefulWidget(title: 'Laporan Stok Barang'),
    );
  }
}

/// Represents the XlsIO stateful widget class.
class CreateExcelStatefulWidget extends StatefulWidget {
  /// Initalize the instance of the [CreateExcelStatefulWidget] class.
  const CreateExcelStatefulWidget({Key? key, required this.title})
      : super(key: key);

  /// title.
  final String title;
  @override
  // ignore: library_private_types_in_public_api
  _CreateExcelState createState() => _CreateExcelState();
}

class _CreateExcelState extends State<CreateExcelStatefulWidget> {
  bool isGenerating = false; // Tambahkan variabel status loading
  final firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> customerOrders = [];
  List<Map<String, dynamic>> customerOrderReturns = [];
  List<Map<String, dynamic>> productionResults = [];
  List<Map<String, dynamic>> materialUsages = [];
  List<Map<String, dynamic>> productionOrders = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor:
            Colors.white, // Atur warna latar belakang AppBar menjadi putih
        iconTheme: const IconThemeData(
          color: Colors.black, // Atur warna ikon kembali menjadi hitam
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ), // Atur warna teks title menjadi hitam
        ),
        leading: InkWell(
          onTap: () {
            if (kIsWeb) {
              Routemaster.of(context)
                  .push('${MainGudang.routeName}?selectedIndex=5');
            } else {
              Navigator.pop(context, null);
            }
          },
          child: Container(
            margin: const EdgeInsets.only(left: 8.0), // Tambahkan margin kiri
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white, // Mengubah latar belakang menjadi putih
            ),
            child: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
        ),
        elevation: 0, // Atur elevation (ketebalan garis bawah) menjadi 0
      ),
      body: Center(
        child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            margin: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green,
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          isGenerating = true;
                        });
                        generateExcel().then((_) {
                          setState(() {
                            isGenerating = false;
                          });
                        });
                      },
                      child: const Text('Generate Excel'),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                        minimumSize: const Size(250, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Scaffold(
                              appBar: AppBar(
                                title: const Text('PDF Preview'),
                              ),
                              body: PdfPreview(
                                allowPrinting: true,
                                build: (format) => generatePDF(format),
                              ),
                            );
                          },
                        );
                      },
                      child: const Text('Generate PDF'),
                    ),
                    if (isGenerating)
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Downloading'),
                        ],
                      ),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  Future<void> fetchData() async {
    final productsSnapshot = await firestore.collection('products').get();
    products = productsSnapshot.docs.map((doc) => doc.data()).toList();

    customerOrders = await fetchCustomerOrders();
    customerOrderReturns = await fetchCustomerOrderReturns();
    productionResults = await fetchProductionResults();
    materialUsages = await fetchMaterialUsages();
    productionOrders = await fetchProductionOrders();
  }

  Future<List<Map<String, dynamic>>> fetchCustomerOrders() async {
    final snapshot = await firestore.collection('customer_orders').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchCustomerOrderReturns() async {
    final snapshot = await firestore.collection('customer_order_returns').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductionResults() async {
    final snapshot = await firestore.collection('production_results').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMaterialUsages() async {
    final snapshot = await firestore.collection('material_usages').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchProductionOrders() async {
    final snapshot = await firestore.collection('production_orders').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> generateExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = false;

    sheet.getRangeByName('A1:F1').columnWidth = 13;

    final titleRange = sheet.getRangeByName('A1:F1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;

    titleRange.setText('Laporan Barang Produksi');

    final headers = [
      'ID Produk',
      'Nama Produk',
      'Stok',
      'Jumlah Pesanan Pelanggan',
      'Jumlah Retur',
      'Jumlah Produksi Berhasil',
      'Jumlah Produksi Gagal'
    ];

    for (var i = 0; i < headers.length; i++) {
      final headerCell = sheet.getRangeByIndex(2, i + 1);
      headerCell.setText(headers[i]);
      headerCell.cellStyle.backColor = '#C0C0C0';
    }

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final productID = product['id'];

      final jumlahPesanan = await calculateTotalJumlahPesanan(productID);
      final jumlahRetur = await calculateTotalJumlahRetur(productID);
      final jumlahProduksi = calculateJumlahProduksi(productID);
      final jumlahCacat = calculateJumlahProduksiGagal(productID);

      final data = [
        product['id'],
        product['nama'],
        product['stok'],
        jumlahPesanan,
        jumlahRetur,
        jumlahProduksi,
        jumlahCacat
      ];

      for (var j = 0; j < data.length; j++) {
        final dataCell = sheet.getRangeByIndex(i + 3, j + 1);
        dataCell.setValue(data[j]);
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    Uint8List uint8list = Uint8List.fromList(bytes);

    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_Barang_Produksi.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<int> calculateTotalJumlahPesanan(String productID) async {
    int totalJumlahPesanan = 0;

    for (var i = 0; i < customerOrders.length; i++) {
      final customerOrderData = customerOrders[i];
      final customerOrderDetailsQuery = await firestore
          .collection('customer_orders')
          .doc(customerOrderData['id']) // Use the document ID
          .collection('detail_customer_orders')
          .get();

      final customerOrderDetails =
          customerOrderDetailsQuery.docs.map((doc) => doc.data()).toList();

      for (var j = 0; j < customerOrderDetails.length; j++) {
        final detailOrder = customerOrderDetails[j];
        if (detailOrder['product_id'] == productID) {
          totalJumlahPesanan += detailOrder['jumlah'] as int;
        }
      }
    }

    return totalJumlahPesanan;
  }

  Future<int> calculateTotalJumlahRetur(String productID) async {
    int totalJumlahRetur = 0;

    for (var i = 0; i < customerOrderReturns.length; i++) {
      final customerOrderReturnDoc = customerOrderReturns[i];
      final customerOrderReturnDetailsQuery = await firestore
          .collection('customer_order_returns')
          .doc(customerOrderReturnDoc['id'])
          .collection('detail_customer_order_returns')
          .get();
      final customerOrderReturnDetails = customerOrderReturnDetailsQuery.docs
          .map((doc) => doc.data())
          .toList();

      for (var j = 0; j < customerOrderReturnDetails.length; j++) {
        final detailOrderReturn = customerOrderReturnDetails[j];
        if (detailOrderReturn['product_id'] == productID) {
          totalJumlahRetur += detailOrderReturn['jumlah_pengembalian'] as int;
        }
      }
    }

    return totalJumlahRetur;
  }

  int calculateJumlahProduksi(String productID) {
    return productionResults
        .where((result) {
          final materialUsageID = result['material_usage_id'] as String;
          final materialUsage = materialUsages.firstWhere(
              (usage) => usage['id'] == materialUsageID,
              orElse: () => {});
          // if (materialUsage == null) return false;
          final productionOrderID =
              materialUsage['production_order_id'] as String;
          final productionOrder = productionOrders.firstWhere(
              (order) => order['id'] == productionOrderID,
              orElse: () => {});
          // if (productionOrder == null) return false;
          final productIDFromOrder = productionOrder['product_id'] as String;

          return productIDFromOrder == productID;
        })
        .map((result) => result['jumlah_produk_berhasil'] as int)
        .fold(0, (prev, amount) => prev + amount);
  }

  int calculateJumlahProduksiGagal(String productID) {
    return productionResults
        .where((result) {
          final materialUsageID = result['material_usage_id'] as String;
          final materialUsage = materialUsages.firstWhere(
              (usage) => usage['id'] == materialUsageID,
              orElse: () => {});
          // if (materialUsage == null) return false;
          final productionOrderID =
              materialUsage['production_order_id'] as String;
          final productionOrder = productionOrders.firstWhere(
              (order) => order['id'] == productionOrderID,
              orElse: () => {});
          // if (productionOrder == null) return false;
          final productIDFromOrder = productionOrder['product_id'] as String;

          return productIDFromOrder == productID;
        })
        .map((result) => result['jumlah_produk_cacat'] as int)
        .fold(0, (prev, amount) => prev + amount);
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    final tableData = <List<String>>[
      [
        'product_id',
        'nama',
        'stok',
        'jumlah_pesanan',
        'jumlah_retur',
        'jumlah_produksi',
      ],
    ];

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final productID = product['id'];

      final totalJumlahPesanan = await calculateTotalJumlahPesanan(productID);
      final totalJumlahRetur = await calculateTotalJumlahRetur(productID);
      final jumlahProduksi = calculateJumlahProduksi(productID);

      tableData.add([
        product['id'].toString(),
        product['nama'].toString(),
        product['stok'].toString(),
        totalJumlahPesanan.toString(),
        totalJumlahRetur.toString(),
        jumlahProduksi.toString(),
      ]);
    }

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),
        build: (context) => [
          pw.Header(
            text: 'Laporan Stok Barang',
            level: 0,
            textStyle: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: tableData,
          ),
        ],
      ),
    );

    final pdfBytes = Uint8List.fromList(await pdf.save());
    return pdfBytes;
  }
}
