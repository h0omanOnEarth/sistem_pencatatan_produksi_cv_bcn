import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Represents the XlsIO widget class.
class LaporanPesananPelanggan extends StatelessWidget {
  static const routeName = '/administrasi/laporan/penjualan';

  const LaporanPesananPelanggan({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateExcelStatefulWidget(title: 'Laporan Penjualan'),
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
    sheet.getRangeByName('A1:H1').columnWidth = 13;

    // Merge cells for the title and format it
    final titleRange = sheet.getRangeByName('A1:H1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;

    // Add the title
    titleRange.setText('Laporan Pesanan Pelanggan');

    // Add headers with background color
    final headers = [
      'Customer ID',
      'ID',
      'Catatan',
      'Status Pesanan',
      'Tanggal Pesan',
      'Tanggal Kirim',
      'Total Harga',
      'Total Produk',
      'Satuan'
    ];
    for (var i = 0; i < headers.length; i++) {
      final headerCell = sheet.getRangeByIndex(2, i + 1);
      headerCell.setText(headers[i]);
      headerCell.cellStyle.backColor = '#C0C0C0'; // Grey background color
    }

    // Fetch data from Firestore and populate the Excel sheet
    final querySnapshot =
        await FirebaseFirestore.instance.collection('customer_orders').get();
    final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var i = 0; i < orders.length; i++) {
      final order = orders[i];
      sheet.getRangeByIndex(i + 3, 1).setText(order['customer_id']);
      sheet.getRangeByIndex(i + 3, 2).setText(order['id']);
      sheet.getRangeByIndex(i + 3, 3).setText(order['catatan']);
      sheet.getRangeByIndex(i + 3, 4).setText(order['status_pesanan']);
      sheet
          .getRangeByIndex(i + 3, 5)
          .setDateTime(order['tanggal_pesan'].toDate());
      sheet
          .getRangeByIndex(i + 3, 6)
          .setDateTime(order['tanggal_kirim'].toDate());
      sheet
          .getRangeByIndex(i + 3, 7)
          .setNumber(order['total_harga'].toDouble());
      sheet.getRangeByIndex(i + 3, 8).setText(order['total_produk'].toString());
      sheet.getRangeByIndex(i + 3, 9).setText(order['satuan']);
    }

    // Add "Total" to the left of the subtotal
    final totalCell = sheet.getRangeByIndex(orders.length + 3, 6);
    totalCell.setText('Total');
    totalCell.cellStyle.bold = true;

    final subtotalRange = sheet.getRangeByIndex(orders.length + 3, 7);
    subtotalRange.setFormula('SUM(G3:G${orders.length + 2})');
    subtotalRange.cellStyle.bold = true;
    subtotalRange.cellStyle.backColor = '#C0C0C0';

    // Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();
    // Dispose the document.
    workbook.dispose();

    Uint8List uint8list = Uint8List.fromList(bytes);

    // Save and launch the file using open_file
    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_Pesanan_Pelanggan.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();

    final querySnapshot =
        await FirebaseFirestore.instance.collection('customer_orders').get();
    final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

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
            text: 'Laporan Pesanan Pelanggan',
            level: 0,
            textStyle: pw.TextStyle(
              font: font, // Gunakan variabel font
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table.fromTextArray(
            context: context,
            data: [
              [
                'Customer ID',
                'ID',
                'Status Pesanan',
                'Tanggal Pesan',
                'Tanggal Kirim',
                'Total Harga',
                'Total Produk',
                'Satuan'
              ],
              for (var order in orders)
                [
                  order['customer_id'].toString(),
                  order['id'].toString(),
                  order['status_pesanan'].toString(),
                  DateFormat('dd/MM/yyyy')
                      .format(order['tanggal_pesan'].toDate()),
                  DateFormat('dd/MM/yyyy')
                      .format(order['tanggal_kirim'].toDate()),
                  order['total_harga'].toString(),
                  order['total_produk'].toString(),
                  order['satuan'].toString(),
                ],
            ],
          ),
        ],
      ),
    );

    final pdfBytes = Uint8List.fromList(await pdf.save());

    // Printing.layoutPdf(
    //   onLayout: (format) {
    //     return pdfBytes;
    //   },
    // );
    return pdfBytes;
  }
}
