import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Represents the XlsIO widget class.
class LaporanPesananPelanggan extends StatelessWidget {
  static const routeName = '/administrasi/laporan/penjualan';

  const LaporanPesananPelanggan({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateExcelStatefulWidget(title: 'Laporan Penjualan'),
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
            Routemaster.of(context)
                .push('${MainAdministrasi.routeName}?selectedIndex=4');
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

    // Filter data berdasarkan tanggal pesan
    final filteredOrders = orders.where((order) {
      final orderDate = order['tanggal_pesan'].toDate();
      return (startDate == null || orderDate.isAfter(startDate)) &&
          (endDate == null || orderDate.isBefore(endDate));
    }).toList();

    for (var i = 0; i < filteredOrders.length; i++) {
      final order = filteredOrders[i];
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
    final totalCell = sheet.getRangeByIndex(filteredOrders.length + 3, 6);
    totalCell.setText('Total');
    totalCell.cellStyle.bold = true;

    final subtotalRange = sheet.getRangeByIndex(filteredOrders.length + 3, 7);
    subtotalRange.setFormula('SUM(G3:G${filteredOrders.length + 2})');
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

    // Filter data berdasarkan tanggal pesan
    final filteredOrders = orders.where((order) {
      final orderDate = order['tanggal_pesan'].toDate();
      return (startDate == null || orderDate.isAfter(startDate)) &&
          (endDate == null || orderDate.isBefore(endDate));
    }).toList();

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
              for (var order in filteredOrders)
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
