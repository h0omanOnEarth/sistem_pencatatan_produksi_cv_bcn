import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;

//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';

/// Represents the XlsIO widget class.
class LaporanPesananPelanggan extends StatelessWidget {
  static const routeName = '/administrasi/laporan/penjualan';

  const LaporanPesananPelanggan({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CreateExcelStatefulWidget(title: 'Create Excel document'),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.lightBlue,
                disabledForegroundColor: Colors.grey,
              ),
              onPressed: generateExcel,
              child: const Text('Generate Excel'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> generateExcel() async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    sheet.showGridlines = false;

    // Set column widths
    sheet.getRangeByName('A1:H1').columnWidth = 13;

    // Add headers
    final headers = ['Customer ID', 'ID', 'Catatan', 'Status Pesanan', 'Tanggal Pesan', 'Tanggal Kirim', 'Total Harga', 'Total Produk', 'Satuan'];
    for (var i = 1; i <= headers.length; i++) {
      sheet.getRangeByIndex(1, i).setText(headers[i - 1]);
    }

    // Fetch data from Firestore and populate the Excel sheet
    final querySnapshot = await FirebaseFirestore.instance.collection('customer_orders').get();
    final orders = querySnapshot.docs.map((doc) => doc.data()).toList();

    for (var i = 0; i < orders.length; i++) {
      final order = orders[i];
      sheet.getRangeByIndex(i + 2, 1).setText(order['customer_id']);
      sheet.getRangeByIndex(i + 2, 2).setText(order['id']);
      sheet.getRangeByIndex(i + 2, 3).setText(order['catatan']);
      sheet.getRangeByIndex(i + 2, 4).setText(order['status_pesanan']);
      sheet.getRangeByIndex(i + 2, 5).setDateTime(order['tanggal_pesan'].toDate());
      sheet.getRangeByIndex(i + 2, 6).setDateTime(order['tanggal_kirim'].toDate());
      sheet.getRangeByIndex(i + 2, 7).setText(order['total_harga'].toString());
      sheet.getRangeByIndex(i + 2, 8).setText(order['total_produk'].toString());
      sheet.getRangeByIndex(i + 2, 9).setText(order['satuan']);
    }

    // Save and launch the excel.
    final List<int> bytes = workbook.saveAsStream();
    // Dispose the document.
    workbook.dispose();

    // Save and launch the file.
    await FileSaveHelper.saveAndLaunchFile(bytes, 'Laporan_Pesanan_Pelanggan.xlsx');
  }
}