import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanBahanGudang extends StatelessWidget {
  static const routeName = '/gudang/laporan/bahan';

  const LaporanBahanGudang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateExcelStatefulWidget(title: 'Laporan Stok Bahan'),
    );
  }
}

class CreateExcelStatefulWidget extends StatefulWidget {
  const CreateExcelStatefulWidget({Key? key, required this.title})
      : super(key: key);

  final String title;

  @override
  _CreateExcelState createState() => _CreateExcelState();
}

class _CreateExcelState extends State<CreateExcelStatefulWidget> {
  bool isGenerating = false;
  final firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> materials = [];
  List<Map<String, dynamic>> purchaseOrders = [];
  List<Map<String, dynamic>> purchaseReturns = [];
  List<Map<String, dynamic>> materialUsages = [];

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
            Routemaster.of(context)
                .push('${MainGudang.routeName}?selectedIndex=5');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                minimumSize: const Size(200, 50),
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
                minimumSize: const Size(200, 50),
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
              )
          ],
        ),
      ),
    );
  }

  Future<void> fetchData() async {
    final productsSnapshot = await firestore.collection('materials').get();
    materials = productsSnapshot.docs.map((doc) => doc.data()).toList();

    purchaseOrders = await fetchPurchaseOrders();
    purchaseReturns = await fetchPurchaseReturns();
    materialUsages = await fetchMaterialUsages();
  }

  Future<List<Map<String, dynamic>>> fetchPurchaseOrders() async {
    final snapshot = await firestore.collection('purchase_orders').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPurchaseReturns() async {
    final snapshot = await firestore.collection('purchase_returns').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchMaterialUsages() async {
    final querySnapshot = await firestore.collection('material_usages').get();
    List<Map<String, dynamic>> result = [];

    for (var queryDocumentSnapshot in querySnapshot.docs) {
      final subcollection = await queryDocumentSnapshot.reference
          .collection('detail_material_usages')
          .get();

      List<Map<String, dynamic>> subcollectionDocs = [];

      for (var subcollectionDoc in subcollection.docs) {
        subcollectionDocs.add(subcollectionDoc.data());
      }

      Map<String, dynamic> materialUsageData = queryDocumentSnapshot.data();
      materialUsageData["detail_material_usages"] = subcollectionDocs;
      result.add(materialUsageData);
    }

    return result;
  }

  Future<void> generateExcel() async {
    await fetchData();
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = false;

    sheet.getRangeByName('A1:G1').columnWidth = 13;

    final titleRange = sheet.getRangeByName('A1:G1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;

    titleRange.setText('Laporan Bahan');

    final headers = [
      'ID Bahan',
      'Nama Bahan',
      'Stok',
      'Jumlah Pembelian Bahan',
      'Jumlah Retur Bahan',
      'Jumlah Penggunaan Bahan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final headerCell = sheet.getRangeByIndex(2, i + 1);
      headerCell.setText(headers[i]);
      headerCell.cellStyle.backColor = '#C0C0C0';
    }

    for (var i = 0; i < materials.length; i++) {
      final material = materials[i];
      final materialID = material['id'];

      final jumlahPesanan = calculateTotalJumlahPesanan(materialID);
      final jumlahRetur = calculateTotalJumlahRetur(materialID);
      final penggunaanProduksi = await calculatePenggunaanProduksi(materialID);

      final data = [
        material['id'],
        material['nama'],
        material['stok'],
        jumlahPesanan,
        jumlahRetur,
        penggunaanProduksi,
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
      await FileSaveHelper.saveAndLaunchFile(uint8list, 'Laporan_Bahan.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  int calculateTotalJumlahPesanan(String materialID) {
    return purchaseOrders
        .where((order) => order['material_id'] == materialID)
        .map((order) => order['jumlah'] as int)
        .fold(0, (prev, amount) => prev + amount);
  }

  int calculateTotalJumlahRetur(String materialID) {
    int totalRetur = 0;

    for (var purchaseReturn in purchaseReturns) {
      final purchaseOrderID = purchaseReturn['purchase_order_id'];
      final matchingPurchaseOrder = purchaseOrders.firstWhere(
        (order) => order['id'] == purchaseOrderID,
        orElse: () => {},
      );

      final orderMaterialID = matchingPurchaseOrder['material_id'];
      if (orderMaterialID == materialID) {
        totalRetur += purchaseReturn['jumlah'] as int;
      }
    }

    return totalRetur;
  }

  Future<int> calculatePenggunaanProduksi(String materialID) async {
    int totalUsage = 0;
    for (var usage in materialUsages) {
      if (usage['detail_material_usages'] != null) {
        final List<Map<String, dynamic>> subcollection =
            usage['detail_material_usages'] as List<Map<String, dynamic>>;
        final usageForMaterial = subcollection
            .where((subdoc) => subdoc['material_id'] == materialID)
            .map((subdoc) => subdoc['jumlah'] as int)
            .fold(0, (prev, amount) => prev + amount);

        totalUsage += usageForMaterial;
      }
    }

    return totalUsage;
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    await fetchData();
    final pdf = pw.Document();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();
    final font = await PdfGoogleFonts.nunitoExtraLight();

    final tableData = <List<String>>[
      [
        'ID Bahan',
        'Nama Bahan',
        'Stok',
        'Jumlah Pembelian Bahan',
        'Jumlah Retur Bahan',
        'Penggunaan Bahan Produksi',
      ],
    ];

    for (var i = 0; i < materials.length; i++) {
      final material = materials[i];
      final materialID = material['id'];

      final totalJumlahPesanan = calculateTotalJumlahPesanan(materialID);
      final totalJumlahRetur = calculateTotalJumlahRetur(materialID);
      final penggunaanProduksi = await calculatePenggunaanProduksi(materialID);

      tableData.add([
        material['id'].toString(),
        material['nama'].toString(),
        material['stok'].toString(),
        totalJumlahPesanan.toString(),
        totalJumlahRetur.toString(),
        penggunaanProduksi.toString(),
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
            text: 'Laporan Bahan',
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
