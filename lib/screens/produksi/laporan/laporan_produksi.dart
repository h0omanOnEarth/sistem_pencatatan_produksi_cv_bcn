import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/main/main_produksi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LaporanProduksi extends StatelessWidget {
  static const routeName = '/produksi/laporan/produksi';

  const LaporanProduksi({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateExcelStatefulWidget(title: 'Laporan Produksi'),
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
  DateTime? startDate; // Tambahkan variabel tanggal awal
  DateTime? endDate; // Tambahkan variabel tanggal akhir
  final productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Routemaster.of(context)
                .push('${MainProduksi.routeName}?selectedIndex=3');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              // Container untuk mengatur lebar DatePickerButton
              width: 250, // Sesuaikan lebar sesuai kebutuhan Anda
              child: DatePickerButton(
                label: 'Pilih Tanggal Awal',
                selectedDate: startDate,
                onDateSelected: (date) {
                  setState(() {
                    startDate = date;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 16.0,
            ),
            SizedBox(
              // Container untuk mengatur lebar DatePickerButton
              width: 250, // Sesuaikan lebar sesuai kebutuhan Anda
              child: DatePickerButton(
                label: 'Pilih Tanggal Akhir',
                selectedDate: endDate,
                onDateSelected: (date) {
                  setState(() {
                    endDate = date;
                  });
                },
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                minimumSize: const Size(250,
                    50), // Sesuaikan lebar dan tinggi sesuai kebutuhan Anda
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
                minimumSize: const Size(250,
                    50), // Sesuaikan lebar dan tinggi sesuai kebutuhan Anda
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
    );
  }

  Future<void> generateExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = false;

    sheet.getRangeByName('A1:I1').columnWidth = 13;

    final titleRange = sheet.getRangeByName('A1:I1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;
    titleRange.setText('Laporan Produksi');

    final headers = [
      'ID',
      'Tanggal Pencatatan',
      'Product ID',
      'Nama Produk',
      'Jumlah Produk Berhasil',
      'Jumlah Produk Cacat',
      'Total Produk',
      'Waktu Produksi',
      'Catatan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final headerCell = sheet.getRangeByIndex(2, i + 1);
      headerCell.setText(headers[i]);
      headerCell.cellStyle.backColor = '#C0C0C0';
    }

    final querySnapshot =
        await FirebaseFirestore.instance.collection('production_results').get();
    final results = querySnapshot.docs.map((doc) => doc.data()).toList();

    // Filter hasil berdasarkan tanggal yang dipilih
    final filteredResults = results.where((result) {
      final resultDate = result['tanggal_pencatatan'].toDate();
      return (startDate == null || resultDate.isAfter(startDate)) &&
          (endDate == null || resultDate.isBefore(endDate));
    }).toList();

    for (var i = 0; i < filteredResults.length; i++) {
      final result = filteredResults[i];
      sheet.getRangeByIndex(i + 3, 1).setText(result['id']);
      final materialUsageId = result['material_usage_id'];
      final materialUsageDoc = await FirebaseFirestore.instance
          .collection('material_usages')
          .doc(materialUsageId)
          .get();
      final productionOrderId = materialUsageDoc.data()?['production_order_id'];
      final productionOrderDoc = await FirebaseFirestore.instance
          .collection('production_orders')
          .doc(productionOrderId)
          .get();
      final productId = productionOrderDoc.data()?['product_id'];
      Map<String, dynamic>? productInfo =
          await productService.getProductInfo(productId);
      final productName = productInfo?['nama'];

      sheet
          .getRangeByIndex(i + 3, 2)
          .setDateTime(result['tanggal_pencatatan'].toDate());
      sheet.getRangeByIndex(i + 3, 3).setText(productId.toString());
      sheet.getRangeByIndex(i + 3, 4).setText(productName);
      sheet
          .getRangeByIndex(i + 3, 5)
          .setNumber(result['jumlah_produk_berhasil']);
      sheet.getRangeByIndex(i + 3, 6).setNumber(result['jumlah_produk_cacat']);
      sheet.getRangeByIndex(i + 3, 7).setNumber(result['total_produk']);
      sheet.getRangeByIndex(i + 3, 8).setNumber(result['waktu_produksi']);
      sheet.getRangeByIndex(i + 3, 9).setText(result['catatan'].toString());
    }

    final totalProdukRange =
        sheet.getRangeByIndex(filteredResults.length + 3, 7);
    totalProdukRange.setFormula('SUM(G3:G${filteredResults.length + 2})');
    totalProdukRange.cellStyle.bold = true;

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    Uint8List uint8list = Uint8List.fromList(bytes);

    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_Produksi.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();
    final querySnapshot =
        await FirebaseFirestore.instance.collection('production_results').get();
    final results = querySnapshot.docs.map((doc) => doc.data()).toList();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    final tableHeaders = [
      'ID',
      'Tanggal Pencatatan',
      'Material Usage ID',
      'Jumlah Produk Berhasil',
      'Jumlah Produk Cacat',
      'Total Produk',
      'Waktu Produksi',
      'Catatan',
      'Nama Produk', // Tambahkan kolom "Nama Produk"
    ];

    final tableData = <List<dynamic>>[];

    // Filter hasil berdasarkan tanggal yang dipilih
    final filteredResults = results.where((result) {
      final resultDate = result['tanggal_pencatatan'].toDate();
      if (startDate != null && endDate != null) {
        return resultDate.isAfter(startDate) && resultDate.isBefore(endDate);
      } else if (startDate != null) {
        return resultDate.isAfter(startDate);
      } else if (endDate != null) {
        return resultDate.isBefore(endDate);
      }
      return true;
    }).toList();

    for (var result in filteredResults) {
      final materialUsageId = result['material_usage_id'];
      final materialUsageDoc = await FirebaseFirestore.instance
          .collection('material_usages')
          .doc(materialUsageId)
          .get();
      final productionOrderId = materialUsageDoc.data()?['production_order_id'];
      final productionOrderDoc = await FirebaseFirestore.instance
          .collection('production_orders')
          .doc(productionOrderId)
          .get();
      final productId = productionOrderDoc.data()?['product_id'];
      final productInfo = await productService.getProductInfo(productId);
      final productName = productInfo?['nama'] as String? ?? '';

      tableData.add([
        result['id'].toString(),
        DateFormat('dd/MM/yyyy HH:mm')
            .format(result['tanggal_pencatatan'].toDate()),
        result['material_usage_id'].toString(),
        result['jumlah_produk_berhasil'].toString(),
        result['jumlah_produk_cacat'].toString(),
        result['total_produk'].toString(),
        result['waktu_produksi'].toString(),
        result['catatan'],
        productName, // Tambahkan kolom "Nama Produk" di sini
      ]);
    }

    final totalProduk = filteredResults
        .map<int>((result) => result['total_produk'] as int)
        .reduce((value, element) => value + element);

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
            text: 'Laporan Produksi',
            level: 0,
            textStyle: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: [tableHeaders, ...tableData],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total Produk: $totalProduk',
                style: pw.TextStyle(
                  font: font2,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final pdfBytes = Uint8List.fromList(await pdf.save());

    return pdfBytes;
  }
}
