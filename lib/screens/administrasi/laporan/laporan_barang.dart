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
class LaporanBarang extends StatelessWidget {
  static const routeName = '/administrasi/laporan/barang';

  const LaporanBarang({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateExcelStatefulWidget(title: 'Laporan Barang'),
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
    titleRange.setText('Laporan Barang Produksi');

    // Add headers with background color
    final headers = [
      'product_id',
      'nama',
      'stok',
      'jumlah_pesanan',
      'jumlah_retur',
      'jumlah_produksi',
    ];

    for (var i = 0; i < headers.length; i++) {
      final headerCell = sheet.getRangeByIndex(2, i + 1);
      headerCell.setText(headers[i]);
      headerCell.cellStyle.backColor = '#C0C0C0'; // Grey background color
    }

    // Fetch data from Firestore and populate the Excel sheet
    final productsSnapshot =
        await FirebaseFirestore.instance.collection('products').get();
    final products = productsSnapshot.docs.map((doc) => doc.data()).toList();

    final customerOrdersSnapshot =
        await FirebaseFirestore.instance.collection('customer_orders').get();

    final customerOrderReturnsSnapshot = await FirebaseFirestore.instance
        .collection('customer_order_returns')
        .get();

    final productionResultsSnapshot =
        await FirebaseFirestore.instance.collection('production_results').get();
    final productionResults =
        productionResultsSnapshot.docs.map((doc) => doc.data()).toList();

    final materialUsagesSnapshot =
        await FirebaseFirestore.instance.collection('material_usages').get();
    final materialUsages =
        materialUsagesSnapshot.docs.map((doc) => doc.data()).toList();

    final productionOrdersSnapshot =
        await FirebaseFirestore.instance.collection('production_orders').get();
    final productionOrders =
        productionOrdersSnapshot.docs.map((doc) => doc.data()).toList();

    for (var i = 0; i < products.length; i++) {
      final product = products[i];
      final productID = product['id'];

      final customerOrdersData =
          await Future.wait(customerOrdersSnapshot.docs.map((doc) async {
        final detailCustomerOrdersCollection =
            doc.reference.collection('detail_customer_orders');
        final detailCustomerOrdersSnapshot =
            await detailCustomerOrdersCollection.get();

        final jumlahPesanan = detailCustomerOrdersSnapshot.docs
            .where((detailOrder) => detailOrder['product_id'] == productID)
            .map((detailOrder) => detailOrder['jumlah'] as int)
            .fold(0, (prev, amount) => prev + amount);

        return {'product_id': productID, 'jumlah_pesanan': jumlahPesanan};
      }));

      final customerOrders = customerOrdersData
          .where((order) => order['product_id'] == productID)
          .map((order) => order['jumlah_pesanan'] as int)
          .toList();

      final totalJumlahPesanan =
          customerOrders.fold(0, (prev, amount) => prev + amount);

      final customerOrderReturnsData =
          await Future.wait(customerOrderReturnsSnapshot.docs.map((doc) async {
        final detailCustomerOrderReturnsCollection =
            doc.reference.collection('detail_customer_order_returns');
        final detailCustomerOrderReturnsSnapshot =
            await detailCustomerOrderReturnsCollection.get();

        final jumlahRetur = detailCustomerOrderReturnsSnapshot.docs
            .where((detailOrderReturn) =>
                detailOrderReturn['product_id'] == productID)
            .map((detailOrderReturn) =>
                detailOrderReturn['jumlah_pengembalian'] as int)
            .fold(0, (prev, amount) => prev + amount);

        return {'product_id': productID, 'jumlah_retur': jumlahRetur};
      }));

      final customerOrderReturns = customerOrderReturnsData
          .where((orderReturn) => orderReturn['product_id'] == productID)
          .map((orderReturn) => orderReturn['jumlah_retur'] as int)
          .toList();

      final totalJumlahRetur =
          customerOrderReturns.fold(0, (prev, amount) => prev + amount);

      final jumlahProduksi = productionResults
          .where((result) {
            final materialUsageID = result['material_usage_id'] as String;
            final materialUsage = materialUsages.firstWhere(
                (usage) => usage['id'] == materialUsageID,
                orElse: () => {});
            // ignore: unnecessary_null_comparison
            if (materialUsage == null) return false;
            final productionOrderID =
                materialUsage['production_order_id'] as String;
            final productionOrder = productionOrders.firstWhere(
                (order) => order['id'] == productionOrderID,
                orElse: () => {});
            // ignore: unnecessary_null_comparison
            if (productionOrder == null) return false;
            final productIDFromOrder = productionOrder['product_id'] as String;

            return productIDFromOrder == productID;
          })
          .map((result) => result['jumlah_produk_berhasil'] as int)
          .fold(0, (prev, amount) => prev + amount);

      final data = [
        product['id'],
        product['nama'],
        product['stok'],
        totalJumlahPesanan,
        totalJumlahRetur,
        jumlahProduksi,
      ];

      for (var j = 0; j < data.length; j++) {
        final dataCell = sheet.getRangeByIndex(i + 3, j + 1);
        dataCell.setValue(data[j]);
      }
    }

    // Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();
    // Dispose the document.
    workbook.dispose();

    Uint8List uint8list = Uint8List.fromList(bytes);

    // Save and launch the file using open_file
    try {
      await FileSaveHelper.saveAndLaunchFile(
          uint8list, 'Laporan_Barang_Produksi.xlsx');
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
