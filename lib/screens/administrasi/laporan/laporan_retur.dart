import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
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
  DateTime? startDate; // Tambahkan variabel tanggal awal
  DateTime? endDate; // Tambahkan variabel tanggal akhir
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
                  .push('${MainAdministrasi.routeName}?selectedIndex=4');
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
                    SizedBox(
                      width: 250,
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
                      width: 250,
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
    titleRange.cellStyle.backColor = '#C0C0C0'; // Header background color

    // Add the title
    titleRange.setText('Laporan Retur Barang');

    Query<Map<String, dynamic>> customerOrderReturnsQuery =
        FirebaseFirestore.instance.collection('customer_order_returns');

    // Tambahkan filter berdasarkan tanggal
    if (startDate != null) {
      customerOrderReturnsQuery = customerOrderReturnsQuery
          .where('tanggal_pengembalian', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      customerOrderReturnsQuery = customerOrderReturnsQuery
          .where('tanggal_pengembalian', isLessThanOrEqualTo: endDate);
    }

    final customerOrderReturnsQuerySnapshot =
        await customerOrderReturnsQuery.get();

    int rowIndex = 3;

    for (var i = 0; i < customerOrderReturnsQuerySnapshot.docs.length; i++) {
      final corDoc = customerOrderReturnsQuerySnapshot.docs[i];
      final corData = corDoc.data();

      // Populate headers with background colors
      final headerTitles = [
        'ID',
        'Invoice ID',
        'Tanggal Pengembalian',
        'Alasan Pengembalian',
        'Status COR',
      ];

      for (var colIndex = 1; colIndex <= headerTitles.length; colIndex++) {
        final cell = sheet.getRangeByIndex(rowIndex, colIndex);
        cell.setText(headerTitles[colIndex - 1]);
        cell.cellStyle.backColor = '#FFFF00'; // Header background color
        cell.cellStyle.bold = true;
      }

      rowIndex++;

      // Populate data cells for COR data
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

      // Fetch and populate the details from the subcollection
      final detailCORQuery =
          corDoc.reference.collection('detail_customer_order_returns');
      final detailCORQuerySnapshot = await detailCORQuery.get();

      if (detailCORQuerySnapshot.docs.isNotEmpty) {
        rowIndex++;

        // Add a separator line
        for (var colIndex = 1; colIndex <= 3; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.setText([
            'ID Produk',
            'Nama Produk',
            'Jumlah Pengembalian'
          ][colIndex - 1]);
          cell.cellStyle.backColor = '#FFFFCC'; // Border color
          cell.cellStyle.bold = true;
        }

        rowIndex++;

        for (var j = 0; j < detailCORQuerySnapshot.docs.length; j++) {
          final detailCORData = detailCORQuerySnapshot.docs[j].data();

          // Fetch product info using the ProductService
          final productService = ProductService();
          final productInfo =
              await productService.getProductInfo(detailCORData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          // Populate data cells for detail_customer_order_returns
          final detailRowData = [
            detailCORData['product_id'],
            productName,
            detailCORData['jumlah_pengembalian'].toString(),
          ];

          for (var colIndex = 1; colIndex <= 3; colIndex++) {
            final cell = sheet.getRangeByIndex(rowIndex, colIndex);
            cell.setText(detailRowData[colIndex - 1]);
          }

          rowIndex++;
        }
      }

      if (i < customerOrderReturnsQuerySnapshot.docs.length - 1) {
        // Add a separator line between COR entries
        for (var colIndex = 1; colIndex <= 7; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.cellStyle.borders.bottom.color = '#FFFFCC';
        }
        rowIndex++;
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    Uint8List uint8list = Uint8List.fromList(bytes);

    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_Retur_Barang.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();

    Query<Map<String, dynamic>> customerOrderReturnsQuery =
        FirebaseFirestore.instance.collection('customer_order_returns');

    // Tambahkan filter berdasarkan tanggal
    if (startDate != null) {
      customerOrderReturnsQuery = customerOrderReturnsQuery
          .where('tanggal_pengembalian', isGreaterThanOrEqualTo: startDate);
    }
    if (endDate != null) {
      customerOrderReturnsQuery = customerOrderReturnsQuery
          .where('tanggal_pengembalian', isLessThanOrEqualTo: endDate);
    }

    final customerOrderReturnsQuerySnapshot =
        await customerOrderReturnsQuery.get();
    final customerOrderReturns = customerOrderReturnsQuerySnapshot.docs
        .map((doc) => doc.data())
        .toList();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    if (customerOrderReturns.isNotEmpty) {
      for (var i = 0; i < customerOrderReturns.length; i++) {
        final cor = customerOrderReturns[i];

        // Ganti ini dengan cara yang sesuai untuk mengakses dokumen dalam koleksi
        final detailCORQuery = FirebaseFirestore.instance.collection(
            'customer_order_returns/${cor['id']}/detail_customer_order_returns');

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
        ];

        final productService = ProductService();

        final detailRows = <List<String>>[];

        for (var detail in detailCOR) {
          final productInfo =
              await productService.getProductInfo(detail['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          detailRows.add([
            detail['product_id'],
            productName,
            detail['jumlah_pengembalian'].toString(),
          ]);
        }

        final pdfPage = pw.MultiPage(
          pageTheme: pw.PageTheme(
            orientation: pw.PageOrientation.landscape,
            theme: pw.ThemeData.withFont(
              base: font1,
              bold: font2,
            ),
          ),
          build: (pw.Context context) => [
            pw.Header(
              text: 'Laporan Retur Barang',
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
                  ...detailRows,
                ],
              ),
          ],
        );

        pdf.addPage(pdfPage);
      }
    } else {
      // Tambahkan lembar dengan teks "Tidak ada data" jika tidak ada data yang sesuai dengan filter
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Tidak ada data'),
        ),
      ));
    }

    final pdfBytes = Uint8List.fromList(await pdf.save());
    return pdfBytes;
  }
}
