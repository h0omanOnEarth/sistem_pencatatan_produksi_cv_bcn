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
class LaporanPenggunaanBahan extends StatelessWidget {
  static const routeName = '/administrasi/laporan/penggunaanbahan';

  const LaporanPenggunaanBahan({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateExcelStatefulWidget(title: 'Laporan Penggunaan Bahan'),
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
    sheet.getRangeByName('A1:F1').columnWidth = 13;

    // Merge cells for the title and format it
    final titleRange = sheet.getRangeByName('A1:F1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;

    // Add the title
    titleRange.setText('Laporan Penggunaan Bahan');

    // Add headers with background color
    final headers = [
      'ID',
      'Production Order ID',
      'Material Request ID',
      'Batch',
      'Tanggal Penggunaan',
      'Status MU',
      'Material ID',
      'Jumlah',
      'Satuan',
    ];

    for (var i = 0; i < headers.length; i++) {
      final headerCell = sheet.getRangeByIndex(2, i + 1);
      headerCell.setText(headers[i]);
      headerCell.cellStyle.backColor = '#C0C0C0';
    }

    // Fetch data from Firestore and populate the Excel sheet
    final materialUsagesQuery =
        FirebaseFirestore.instance.collection('material_usages');
    final materialUsagesQuerySnapshot = await materialUsagesQuery.get();

    int rowIndex = 3;

    for (var i = 0; i < materialUsagesQuerySnapshot.docs.length; i++) {
      final materialUsageDoc = materialUsagesQuerySnapshot.docs[i];
      final materialUsageData = materialUsageDoc.data();

      sheet.getRangeByIndex(rowIndex, 1).setText(materialUsageDoc.id);
      sheet
          .getRangeByIndex(rowIndex, 2)
          .setText(materialUsageData['production_order_id']);
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setText(materialUsageData['material_request_id']);
      sheet.getRangeByIndex(rowIndex, 4).setText(materialUsageData['batch']);
      sheet
          .getRangeByIndex(rowIndex, 5)
          .setDateTime(materialUsageData['tanggal_penggunaan'].toDate());
      sheet
          .getRangeByIndex(rowIndex, 6)
          .setText(materialUsageData['status_mu']);

      // Fetch and populate the details from subcollection
      final detailMaterialUsagesQuery =
          materialUsageDoc.reference.collection('detail_material_usages');
      final detailMaterialUsagesQuerySnapshot =
          await detailMaterialUsagesQuery.get();

      for (var j = 0; j < detailMaterialUsagesQuerySnapshot.docs.length; j++) {
        final detailMaterialUsageData =
            detailMaterialUsagesQuerySnapshot.docs[j].data();
        sheet
            .getRangeByIndex(rowIndex, 7)
            .setText(detailMaterialUsageData['material_id']);
        sheet
            .getRangeByIndex(rowIndex, 8)
            .setNumber(detailMaterialUsageData['jumlah']);
        sheet
            .getRangeByIndex(rowIndex, 9)
            .setText(detailMaterialUsageData['satuan']);
        rowIndex++;
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List uint8list = Uint8List.fromList(bytes);

    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_Penggunaan_Bahan.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();

    final materialUsagesQuery =
        FirebaseFirestore.instance.collection('material_usages');
    final materialUsagesQuerySnapshot = await materialUsagesQuery.get();
    final materialUsages = materialUsagesQuerySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    for (var i = 0; i < materialUsages.length; i++) {
      final mu = materialUsages[i];
      final detailMaterialUsagesQuery = materialUsagesQuery
          .doc(mu['id'])
          .collection('detail_material_usages');
      final detailMaterialUsagesQuerySnapshot =
          await detailMaterialUsagesQuery.get();
      final detailMaterialUsages = detailMaterialUsagesQuerySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

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
          pw.Header(
            text: 'Material Usage ID: ${mu['id']}',
            level: 1,
            textStyle: pw.TextStyle(
              font: font2,
              fontSize: 14,
            ),
          ),
          pw.Table.fromTextArray(
            data: [
              [
                'ID',
                'Production Order ID',
                'Material Request ID',
                'Batch',
                'Tanggal Penggunaan',
                'Status MU',
              ],
              [
                mu['id'].toString(),
                mu['production_order_id'].toString(),
                mu['material_request_id'].toString(),
                mu['batch'].toString(),
                DateFormat('dd/MM/yyyy')
                    .format(mu['tanggal_penggunaan'].toDate()),
                mu['status_mu'].toString(),
                // Initialize these columns with empty strings
              ],
            ],
          ),
          if (detailMaterialUsages.isNotEmpty)
            pw.Header(
              text: 'Detail Penggunaan Bahan',
              level: 2,
              textStyle: pw.TextStyle(
                font: font2,
                fontSize: 14,
              ),
            ),
          if (detailMaterialUsages.isNotEmpty)
            pw.Table.fromTextArray(
              data: [
                [
                  'Material ID',
                  'Jumlah',
                  'Satuan',
                ],
                for (var detailMu in detailMaterialUsages)
                  [
                    detailMu['material_id'].toString(),
                    detailMu['jumlah'].toString(),
                    detailMu['satuan'].toString(),
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
