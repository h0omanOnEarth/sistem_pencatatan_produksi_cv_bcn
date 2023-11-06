import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Represents the XlsIO widget class.
class LaporanReturBarang extends StatelessWidget {
  static const routeName = '/administrasi/laporan/retur';

  const LaporanReturBarang({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateExcelStatefulWidget(title: 'Laporan Retur Barang'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Routemaster.of(context)
                .push('${MainAdministrasi.routeName}?selectedIndex=4');
          },
        ),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.center, // Tambahkan ini untuk memusatkan tombol
        children: [
          ElevatedButton(
            // Mengganti TextButton dengan ElevatedButton
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.green, // Memberikan warna teks putih
              minimumSize: const Size(200, 50), // Menentukan ukuran tombol
            ),
            onPressed: () {
              // Tandai status loading saat tombol ditekan
              setState(() {
                isGenerating = true;
              });
              generateExcel().then((_) {
                // Setelah selesai, hentikan status loading
                setState(() {
                  isGenerating = false;
                });
              });
            },
            child: const Text('Generate Excel'),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            // Mengganti TextButton dengan ElevatedButton
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.red, // Memberikan warna teks putih
              minimumSize: const Size(200, 50), // Menentukan ukuran tombol
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
                  });
            },
            child: const Text('Generate PDF'),
          ),
          if (isGenerating) // Tampilkan CircularProgressIndicator jika sedang loading
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Downloading'), // Tambahkan teks "Downloading" di sini
              ],
            )
        ],
      )),
    );
  }

  Future<void> generateExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = false;

    // Set column widths
    sheet.getRangeByName('A1:G1').columnWidth = 13;

    // Merge cells for the title and format it
    final titleRange = sheet.getRangeByName('A1:G1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;
    titleRange.cellStyle.backColor = '#C0C0C0';

    titleRange.setText('Laporan Pengembalian Barang');

    final customerOrderReturnsQuery =
        FirebaseFirestore.instance.collection('customer_order_returns');
    final customerOrderReturnsQuerySnapshot =
        await customerOrderReturnsQuery.get();

    int rowIndex = 3;

    for (var i = 0; i < customerOrderReturnsQuerySnapshot.docs.length; i++) {
      final corDoc = customerOrderReturnsQuerySnapshot.docs[i];
      final corData = corDoc.data();

      final headerTitles = [
        'ID',
        'Invoice ID',
        'Tanggal Pengembalian',
        'Alasan Pengembalian',
        'Status COR',
        'Product ID',
        'Jumlah Pengembalian'
      ];

      for (var colIndex = 1; colIndex <= headerTitles.length; colIndex++) {
        final cell = sheet.getRangeByIndex(rowIndex, colIndex);
        cell.setText(headerTitles[colIndex - 1]);
        cell.cellStyle.backColor = '#FFFF00';
        cell.cellStyle.bold = true;
      }

      rowIndex++;

      final corRowData = [
        corData['id'],
        corData['invoice_id'],
        DateFormat('dd/MM/yyyy')
            .format(corData['tanggal_pengembalian'].toDate()),
        corData['alasan_pengembalian'],
        corData['status_cor'],
      ];

      for (var colIndex = 1; colIndex <= corRowData.length; colIndex++) {
        sheet
            .getRangeByIndex(rowIndex, colIndex)
            .setText(corRowData[colIndex - 1]);
      }

      final detailCORQuery =
          corDoc.reference.collection('detail_customer_order_returns');
      final detailCORQuerySnapshot = await detailCORQuery.get();

      if (detailCORQuerySnapshot.docs.isNotEmpty) {
        rowIndex++;

        for (var j = 0; j < detailCORQuerySnapshot.docs.length; j++) {
          final detailCORData = detailCORQuerySnapshot.docs[j].data();

          final productService = ProductService();
          final productInfo =
              await productService.getProductInfo(detailCORData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          final detailRowData = [
            detailCORData['product_id'],
            productName,
            detailCORData['jumlah_pengembalian'].toString(),
          ];

          for (var colIndex = 1; colIndex <= detailRowData.length; colIndex++) {
            sheet
                .getRangeByIndex(rowIndex, colIndex + 4)
                .setText(detailRowData[colIndex - 1]);
          }

          rowIndex++;
        }
      }

      if (i < customerOrderReturnsQuerySnapshot.docs.length - 1) {
        for (var colIndex = 1; colIndex <= 7; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.cellStyle.borders.bottom.color = '#000000';
        }
        rowIndex++;
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List uint8list = Uint8List.fromList(bytes);

    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_pengembalian_barang.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();

    final customerOrderReturnsQuery =
        FirebaseFirestore.instance.collection('customer_order_returns');
    final customerOrderReturnsQuerySnapshot =
        await customerOrderReturnsQuery.get();
    final customerOrderReturns = customerOrderReturnsQuerySnapshot.docs
        .map((doc) => doc.data())
        .toList();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    for (var i = 0; i < customerOrderReturns.length; i++) {
      final cor = customerOrderReturns[i];
      final detailCORQuery = customerOrderReturnsQuery
          .doc(cor['id'])
          .collection('detail_customer_order_returns');
      final detailCORQuerySnapshot = await detailCORQuery.get();
      final detailCOR =
          detailCORQuerySnapshot.docs.map((doc) => doc.data()).toList();

      final headerTitles = [
        'ID',
        'Invoice ID',
        'Tanggal Pengembalian',
        'Alasan Pengembalian',
        'Status COR',
      ];

      final headerData = [
        cor['id'].toString(),
        cor['invoice_id'].toString(),
        DateFormat('dd/MM/yyyy').format(cor['tanggal_pengembalian'].toDate()),
        cor['alasan_pengembalian'],
        cor['status_cor'],
        '',
        '',
      ];

      pdf.addPage(pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),
        build: (pw.Context context) => [
          pw.Header(
            text: 'Laporan Penggunaan Bahan',
            level: 0,
            textStyle: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table.fromTextArray(
            data: [headerTitles, headerData],
          ),
          if (detailCOR.isNotEmpty)
            pw.Header(
              text: 'Detail Penggunaan Bahan',
              level: 2,
              textStyle: pw.TextStyle(
                font: font2,
                fontSize: 14,
              ),
            ),
          if (detailCOR.isNotEmpty)
            pw.Table.fromTextArray(
              data: [
                ['Product ID', 'Product Name', 'Jumlah Pengembalian'],
                for (var detail in detailCOR)
                  [
                    detail['product_id'],
                    'Product Name Not Found', // Default value
                    detail['jumlah_pengembalian'].toString()
                  ],
              ],
            ),
        ],
      ));
    }

    final pdfBytes = Uint8List.fromList(await pdf.save());
    return pdfBytes;
  }
}
