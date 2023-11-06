import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Represents the XlsIO widget class.
class LaporanPenerimaanPengiriman extends StatelessWidget {
  static const routeName = '/gudang/laporan/pengiriman';

  const LaporanPenerimaanPengiriman({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:
          CreateExcelStatefulWidget(title: 'Laporan Pengiriman dan Penerimaan'),
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
                .push('${MainGudang.routeName}?selectedIndex=5');
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
    titleRange.cellStyle.backColor = '#C0C0C0'; // Header background color

    // Fetch and populate 'item_receives' data
    final itemReceivesQuery =
        FirebaseFirestore.instance.collection('item_receives');
    final itemReceivesQuerySnapshot = await itemReceivesQuery.get();

    // Fetch and populate 'shipments' data
    final shipmentsQuery = FirebaseFirestore.instance.collection('shipments');
    final shipmentsQuerySnapshot = await shipmentsQuery.get();

    int rowIndex = 3;

    // Add "Penerimaan Barang" title
    final penerimaanTitleRange = sheet.getRangeByIndex(rowIndex, 1);
    penerimaanTitleRange.setText('Penerimaan Barang');
    penerimaanTitleRange.cellStyle.bold = true;
    penerimaanTitleRange.cellStyle.backColor =
        '#FFFF00'; // Title background color
    rowIndex++;

    // Populate headers for "Penerimaan Barang"
    final itemReceivesHeaderTitles = [
      'ID',
      'Production Confirmation ID',
      'Status IRC',
      'Tanggal Penerimaan',
    ];

    for (var colIndex = 1;
        colIndex <= itemReceivesHeaderTitles.length;
        colIndex++) {
      final cell = sheet.getRangeByIndex(rowIndex, colIndex);
      cell.setText(itemReceivesHeaderTitles[colIndex - 1]);
      cell.cellStyle.backColor = '#FFFF00'; // Header background color
      cell.cellStyle.bold = true;
    }
    rowIndex++;

    for (var i = 0; i < itemReceivesQuerySnapshot.docs.length; i++) {
      final ircDoc = itemReceivesQuerySnapshot.docs[i];
      final ircData = ircDoc.data();

      // Populate data cells for "Penerimaan Barang"
      final ircRowData = [
        ircData['id'],
        ircData['production_confirmation_id'],
        ircData['status_irc'],
        DateFormat('dd/MM/yyyy').format(ircData['tanggal_penerimaan'].toDate()),
      ];

      for (var colIndex = 1; colIndex <= ircRowData.length; colIndex++) {
        sheet
            .getRangeByIndex(rowIndex, colIndex)
            .setText(ircRowData[colIndex - 1]);
      }

      // Fetch and populate detail_item_receives from subcollection
      final detailIRCQuery =
          ircDoc.reference.collection('detail_item_receives');
      final detailIRCQuerySnapshot = await detailIRCQuery.get();

      if (detailIRCQuerySnapshot.docs.isNotEmpty) {
        rowIndex++;

        // Add a separator line for "Penerimaan Barang"
        for (var colIndex = 1; colIndex <= 7; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.cellStyle.borders.bottom.color = '#FFFFCC';
        }
        rowIndex++;

        // Populate headers for detail_item_receives
        final detailIRCHeaderTitles = [
          'Product ID',
          'Product Name',
          'Jumlah Konfirmasi'
        ];

        for (var colIndex = 1;
            colIndex <= detailIRCHeaderTitles.length;
            colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.setText(detailIRCHeaderTitles[colIndex - 1]);
          cell.cellStyle.backColor = '#FFFFCC'; // Header background color
          cell.cellStyle.bold = true;
        }
        rowIndex++;

        for (var j = 0; j < detailIRCQuerySnapshot.docs.length; j++) {
          final detailIRCData = detailIRCQuerySnapshot.docs[j].data();

          // Fetch product info using the ProductService
          final productService = ProductService();
          final productInfo =
              await productService.getProductInfo(detailIRCData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          // Populate data cells for detail_item_receives
          final detailIRCRowData = [
            detailIRCData['product_id'],
            productName,
            detailIRCData['jumlah_konfirmasi'].toString(),
          ];

          for (var colIndex = 1; colIndex <= 3; colIndex++) {
            sheet
                .getRangeByIndex(rowIndex, colIndex)
                .setText(detailIRCRowData[colIndex - 1]);
          }

          rowIndex++;
        }
      }

      if (i < itemReceivesQuerySnapshot.docs.length - 1) {
        // Add a separator line between "Penerimaan Barang" entries
        for (var colIndex = 1; colIndex <= 7; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.cellStyle.borders.bottom.color = '#FFFFCC';
        }
        rowIndex++;
      }
    }

    rowIndex++;

    // Add "Pengiriman Barang" title
    final pengirimanTitleRange = sheet.getRangeByIndex(rowIndex, 1);
    pengirimanTitleRange.setText('Pengiriman Barang');
    pengirimanTitleRange.cellStyle.bold = true;
    pengirimanTitleRange.cellStyle.backColor =
        '#FFFF00'; // Title background color
    rowIndex++;

    // Populate headers for "Pengiriman Barang"
    final shipmentsHeaderTitles = [
      'ID',
      'Delivery Order ID',
      'Tanggal Pembuatan',
      'Total PCS',
      'Status SHP',
    ];

    for (var colIndex = 1;
        colIndex <= shipmentsHeaderTitles.length;
        colIndex++) {
      final cell = sheet.getRangeByIndex(rowIndex, colIndex);
      cell.setText(shipmentsHeaderTitles[colIndex - 1]);
      cell.cellStyle.backColor = '#FFFF00'; // Header background color
      cell.cellStyle.bold = true;
    }
    rowIndex++;

    for (var i = 0; i < shipmentsQuerySnapshot.docs.length; i++) {
      final shpDoc = shipmentsQuerySnapshot.docs[i];
      final shpData = shpDoc.data();

      // Populate data cells for "Pengiriman Barang"
      final shpRowData = [
        shpData['id'],
        shpData['delivery_order_id'],
        DateFormat('dd/MM/yyyy').format(shpData['tanggal_pembuatan'].toDate()),
        shpData['total_pcs'].toString(),
        shpData['status_shp'],
      ];

      for (var colIndex = 1; colIndex <= shpRowData.length; colIndex++) {
        sheet
            .getRangeByIndex(rowIndex, colIndex)
            .setText(shpRowData[colIndex - 1]);
      }

      // Fetch and populate detail_shipments from subcollection
      final detailShpQuery = shpDoc.reference.collection('detail_shipments');
      final detailShpQuerySnapshot = await detailShpQuery.get();

      if (detailShpQuerySnapshot.docs.isNotEmpty) {
        rowIndex++;

        // Add a separator line for "Pengiriman Barang"
        for (var colIndex = 1; colIndex <= 7; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.cellStyle.borders.bottom.color = '#FFFFCC';
        }
        rowIndex++;

        // Populate headers for detail_shipments
        final detailShpHeaderTitles = [
          'Product ID',
          'Product Name',
          'Jumlah Pengiriman',
          'Jumlah Pengiriman Dus'
        ];

        for (var colIndex = 1;
            colIndex <= detailShpHeaderTitles.length;
            colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.setText(detailShpHeaderTitles[colIndex - 1]);
          cell.cellStyle.backColor = '#FFFFCC'; // Header background color
          cell.cellStyle.bold = true;
        }
        rowIndex++;

        for (var j = 0; j < detailShpQuerySnapshot.docs.length; j++) {
          final detailShpData = detailShpQuerySnapshot.docs[j].data();

          // Fetch product info using the ProductService
          final productService = ProductService();
          final productInfo =
              await productService.getProductInfo(detailShpData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          // Populate data cells for detail_shipments
          final detailShpRowData = [
            detailShpData['product_id'],
            productName,
            detailShpData['jumlah_pengiriman'].toString(),
            detailShpData['jumlah_pengiriman_dus'].toString(),
          ];

          for (var colIndex = 1; colIndex <= 4; colIndex++) {
            sheet
                .getRangeByIndex(rowIndex, colIndex)
                .setText(detailShpRowData[colIndex - 1]);
          }

          rowIndex++;
        }
      }

      if (i < shipmentsQuerySnapshot.docs.length - 1) {
        // Add a separator line between "Pengiriman Barang" entries
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
          uint8list, 'Laporan_Pengiriman_Penerimaan.xlsx');
    } catch (e) {
      print('Error opening file: $e');
    }
  }

  Future<Uint8List> generatePDF(PdfPageFormat format) async {
    final pdf = pw.Document();

    final itemReceivesQuery =
        FirebaseFirestore.instance.collection('item_receives');
    final itemReceivesQuerySnapshot = await itemReceivesQuery.get();

    final shipmentsQuery = FirebaseFirestore.instance.collection('shipments');
    final shipmentsQuerySnapshot = await shipmentsQuery.get();

    // Membuat fungsi untuk mengambil data "item_receives" dari Firestore
    Future<List<Map<String, dynamic>>> getItemReceivesData() async {
      final data = <Map<String, dynamic>>[];
      for (final doc in itemReceivesQuerySnapshot.docs) {
        final ircData = doc.data();
        final detailIRCQuery = doc.reference.collection('detail_item_receives');
        final detailIRCQuerySnapshot = await detailIRCQuery.get();
        final detailIRCData =
            detailIRCQuerySnapshot.docs.map((doc) => doc.data()).toList();
        data.add({
          'id': ircData['id'],
          'production_confirmation_id': ircData['production_confirmation_id'],
          'status_irc': ircData['status_irc'],
          'tanggal_penerimaan': DateFormat('dd/MM/yyyy')
              .format(ircData['tanggal_penerimaan'].toDate()),
          'detail_item_receives': detailIRCData,
        });
      }
      return data;
    }

    // Membuat fungsi untuk mengambil data "shipments" dari Firestore
    Future<List<Map<String, dynamic>>> getShipmentsData() async {
      final data = <Map<String, dynamic>>[];
      for (final doc in shipmentsQuerySnapshot.docs) {
        final shpData = doc.data();
        final detailShpQuery = doc.reference.collection('detail_shipments');
        final detailShpQuerySnapshot = await detailShpQuery.get();
        final detailShpData =
            detailShpQuerySnapshot.docs.map((doc) => doc.data()).toList();
        data.add({
          'id': shpData['id'],
          'delivery_order_id': shpData['delivery_order_id'],
          'tanggal_pembuatan': DateFormat('dd/MM/yyyy')
              .format(shpData['tanggal_pembuatan'].toDate()),
          'total_pcs': shpData['total_pcs'],
          'status_shp': shpData['status_shp'],
          'detail_shipments': detailShpData,
        });
      }
      return data;
    }

    final itemReceivesData = await getItemReceivesData();
    final shipmentsData = await getShipmentsData();

    // Fungsi untuk membuat halaman PDF berdasarkan data "item_receives"
    void createItemReceivesPage(
        pw.Document pdf, Map<String, dynamic> itemReceiveData) {
      pdf.addPage(pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
        ),
        build: (pw.Context context) => [
          pw.Header(
            text: 'Laporan Pengiriman dan Penerimaan - Penerimaan Barang',
            level: 0,
            textStyle: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table.fromTextArray(
            data: [
              [
                'ID',
                'Production Confirmation ID',
                'Status IRC',
                'Tanggal Penerimaan'
              ],
              [
                itemReceiveData['id'].toString(),
                itemReceiveData['production_confirmation_id'].toString(),
                itemReceiveData['status_irc'],
                itemReceiveData['tanggal_penerimaan'],
              ],
            ],
          ),
          if (itemReceiveData['detail_item_receives'].isNotEmpty)
            pw.Header(
              text: 'Detail Penerimaan Barang',
              level: 2,
              textStyle: pw.TextStyle(
                fontSize: 14,
              ),
            ),
          if (itemReceiveData['detail_item_receives'].isNotEmpty)
            pw.Table.fromTextArray(
              data: [
                ['Product ID', 'Product Name', 'Jumlah Konfirmasi'],
                for (final detail in itemReceiveData['detail_item_receives'])
                  [
                    detail['product_id'],
                    'Product Name Not Found',
                    detail['jumlah_konfirmasi'].toString(),
                  ],
              ],
            ),
        ],
      ));
    }

    // Fungsi untuk membuat halaman PDF berdasarkan data "shipments"
    void createShipmentsPage(
        pw.Document pdf, Map<String, dynamic> shipmentData) {
      pdf.addPage(pw.MultiPage(
        pageTheme: pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
        ),
        build: (pw.Context context) => [
          pw.Header(
            text: 'Laporan Pengiriman dan Penerimaan - Pengiriman Barang',
            level: 0,
            textStyle: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Table.fromTextArray(
            data: [
              [
                'ID',
                'Delivery Order ID',
                'Tanggal Pembuatan',
                'Total PCS',
                'Status SHP'
              ],
              [
                shipmentData['id'].toString(),
                shipmentData['delivery_order_id'].toString(),
                shipmentData['tanggal_pembuatan'],
                shipmentData['total_pcs'].toString(),
                shipmentData['status_shp'],
              ],
            ],
          ),
          if (shipmentData['detail_shipments'].isNotEmpty)
            pw.Header(
              text: 'Detail Pengiriman Barang',
              level: 2,
              textStyle: pw.TextStyle(
                fontSize: 14,
              ),
            ),
          if (shipmentData['detail_shipments'].isNotEmpty)
            pw.Table.fromTextArray(
              data: [
                [
                  'Product ID',
                  'Product Name',
                  'Jumlah Pengiriman',
                  'Jumlah Pengiriman Dus'
                ],
                for (final detail in shipmentData['detail_shipments'])
                  [
                    detail['product_id'],
                    'Product Name Not Found',
                    detail['jumlah_pengiriman'].toString(),
                    detail['jumlah_pengiriman_dus'].toString(),
                  ],
              ],
            ),
        ],
      ));
    }

    // Membuat halaman PDF berdasarkan data "item_receives"
    for (final itemReceiveData in itemReceivesData) {
      createItemReceivesPage(pdf, itemReceiveData);
    }

    // Membuat halaman PDF berdasarkan data "shipments"
    for (final shipmentData in shipmentsData) {
      createShipmentsPage(pdf, shipmentData);
    }

    final pdfBytes = Uint8List.fromList(await pdf.save());
    return pdfBytes;
  }
}
