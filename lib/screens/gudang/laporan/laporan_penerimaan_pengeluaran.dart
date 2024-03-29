import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/main/main_gudang.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
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
  DateTime? startDate; // Tambahkan variabel tanggal awal
  DateTime? endDate; // Tambahkan variabel tanggal akhir
  final firestore = FirebaseFirestore.instance;
  final List<Map<String, String>> productList = [];

  @override
  void initState() {
    super.initState();
    fetchDataMaterial();
  }

  // Fungsi untuk mencari nama produk berdasarkan ID
  String? findProductName(String productId) {
    final product = productList.firstWhere(
        (element) => element['id'] == productId,
        orElse: () => {'nama': 'Product Not Found'});
    return product['nama'];
  }

  Future<void> fetchDataMaterial() async {
    // Fetch and store 'materials' data
    final materialsQuery = firestore.collection('products');
    final materialsQuerySnapshot = await materialsQuery.get();

    // Populate productList with ID and name of each product
    for (final materialDoc in materialsQuerySnapshot.docs) {
      final materialData = materialDoc.data();
      productList.add({
        'id': materialData['id'],
        'nama': materialData['nama'],
      });
    }
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
            if (kIsWeb) {
              Routemaster.of(context)
                  .push('${MainGudang.routeName}?selectedIndex=5');
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
    final Worksheet sheet1 = workbook.worksheets[0]; // Penerimaan Barang
    final Worksheet sheet2 = workbook.worksheets.add(); // Pengiriman Barang
    sheet1.showGridlines = false;
    sheet2.showGridlines = false;

    // Ganti nama lembar kerja
    sheet1.name = 'Laporan Penerimaan Barang';
    sheet2.name = 'Laporan Pengiriman Barang';

    // Set column widths for Penerimaan Barang
    sheet1.getRangeByName('A1:I1').columnWidth = 13;

    // Merge cells for the title and format it for Penerimaan Barang
    final titleRange1 = sheet1.getRangeByName('A1:I1');
    titleRange1.merge();
    titleRange1.cellStyle.hAlign = HAlignType.center;
    titleRange1.cellStyle.bold = true;
    titleRange1.cellStyle.fontSize = 18;
    titleRange1.cellStyle.backColor = '#C0C0C0'; // Header background color

    // Add the title for Penerimaan Barang
    titleRange1.setText('Laporan Penerimaan Barang');

    // Set column widths for Pengiriman Barang
    sheet2.getRangeByName('A1:I1').columnWidth = 13;

    // Merge cells for the title and format it for Pengiriman Barang
    final titleRange2 = sheet2.getRangeByName('A1:I1');
    titleRange2.merge();
    titleRange2.cellStyle.hAlign = HAlignType.center;
    titleRange2.cellStyle.bold = true;
    titleRange2.cellStyle.fontSize = 18;
    titleRange2.cellStyle.backColor = '#C0C0C0'; // Header background color

    // Add the title for Pengiriman Barang
    titleRange2.setText('Laporan Pengiriman Barang');

    // Fetch and populate 'item_receives' data
    final itemReceivesQuery = firestore.collection('item_receives');
    final itemReceivesQuerySnapshot = await itemReceivesQuery.get();

    // Fetch and populate 'shipments' data
    final shipmentsQuery = firestore.collection('shipments');
    final shipmentsQuerySnapshot = await shipmentsQuery.get();

    int rowIndex1 = 3; // Row index for Penerimaan Barang
    int rowIndex2 = 3; // Row index for Pengiriman Barang

    // Add headers for Penerimaan Barang
    final itemReceivesHeaderTitles = [
      'ID',
      'Production Confirmation ID',
      'Status IRC',
      'Tanggal Penerimaan',
      'Product ID',
      'Product Name',
      'Jumlah Konfirmasi',
    ];

    for (var colIndex = 1;
        colIndex <= itemReceivesHeaderTitles.length;
        colIndex++) {
      final cell = sheet1.getRangeByIndex(rowIndex1, colIndex);
      cell.setText(itemReceivesHeaderTitles[colIndex - 1]);
      cell.cellStyle.backColor = '#FFFF00'; // Header background color
      cell.cellStyle.bold = true;
    }
    rowIndex1++;

    // Add headers for Pengiriman Barang
    final shipmentsHeaderTitles = [
      'ID',
      'Delivery Order ID',
      'Tanggal Pembuatan',
      'Total PCS',
      'Status SHP',
      'Product ID',
      'Product Name',
      'Jumlah Pengiriman',
      'Jumlah Pengiriman Dus',
    ];

    for (var colIndex = 1;
        colIndex <= shipmentsHeaderTitles.length;
        colIndex++) {
      final cell = sheet2.getRangeByIndex(rowIndex2, colIndex);
      cell.setText(shipmentsHeaderTitles[colIndex - 1]);
      cell.cellStyle.backColor = '#FFFF00'; // Header background color
      cell.cellStyle.bold = true;
    }
    rowIndex2++;

    for (var i = 0; i < itemReceivesQuerySnapshot.docs.length; i++) {
      final ircDoc = itemReceivesQuerySnapshot.docs[i];
      final ircData = ircDoc.data();
      final ircDate = ircData['tanggal_penerimaan'].toDate();

      // Check if the ircDate is within the selected date range
      if ((startDate == null || ircDate.isAfter(startDate)) &&
          (endDate == null || ircDate.isBefore(endDate))) {
        // Populate data cells for Penerimaan Barang
        final ircRowData = [
          ircData['id'],
          ircData['production_confirmation_id'],
          ircData['status_irc'],
          DateFormat('dd/MM/yyyy').format(ircDate),
        ];

        for (var colIndex = 1; colIndex <= ircRowData.length; colIndex++) {
          sheet1
              .getRangeByIndex(rowIndex1, colIndex)
              .setText(ircRowData[colIndex - 1]);
        }

        // Fetch and populate detail_item_receives from subcollection
        final detailIRCQuery =
            ircDoc.reference.collection('detail_item_receives');
        final detailIRCQuerySnapshot = await detailIRCQuery.get();

        for (var j = 0; j < detailIRCQuerySnapshot.docs.length; j++) {
          final detailIRCData = detailIRCQuerySnapshot.docs[j].data();

          // Fetch product info using the ProductService
          final productService = ProductService();
          final productInfo =
              await productService.getProductInfo(detailIRCData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          // Populate data cells for Penerimaan Barang
          final detailIRCRowData = [
            detailIRCData['product_id'],
            productName,
            detailIRCData['jumlah_konfirmasi'].toString(),
          ];

          for (var colIndex = 1; colIndex <= 3; colIndex++) {
            sheet1
                .getRangeByIndex(rowIndex1, colIndex + 4)
                .setText(detailIRCRowData[colIndex - 1]);
          }

          rowIndex1++;
        }
      }
    }

    rowIndex1++;

    for (var i = 0; i < shipmentsQuerySnapshot.docs.length; i++) {
      final shpDoc = shipmentsQuerySnapshot.docs[i];
      final shpData = shpDoc.data();
      final shpDate = shpData['tanggal_pembuatan'].toDate();

      // Check if the shpDate is within the selected date range
      if ((startDate == null || shpDate.isAfter(startDate)) &&
          (endDate == null || shpDate.isBefore(endDate))) {
        // Populate data cells for Pengiriman Barang
        final shpRowData = [
          shpData['id'],
          shpData['delivery_order_id'],
          DateFormat('dd/MM/yyyy').format(shpDate),
          shpData['total_pcs'].toString(),
          shpData['status_shp'],
        ];

        for (var colIndex = 1; colIndex <= shpRowData.length; colIndex++) {
          sheet2
              .getRangeByIndex(rowIndex2, colIndex)
              .setText(shpRowData[colIndex - 1]);
        }

        // Fetch and populate detail_shipments from subcollection
        final detailShpQuery = shpDoc.reference.collection('detail_shipments');
        final detailShpQuerySnapshot = await detailShpQuery.get();

        for (var j = 0; j < detailShpQuerySnapshot.docs.length; j++) {
          final detailShpData = detailShpQuerySnapshot.docs[j].data();

          // Fetch product info using the ProductService
          final productService = ProductService();
          final productInfo =
              await productService.getProductInfo(detailShpData['product_id']);
          final productName = productInfo != null
              ? productInfo['nama']
              : 'Product Name Not Found';

          // Populate data cells for Pengiriman Barang
          final detailShpRowData = [
            detailShpData['product_id'],
            productName,
            detailShpData['jumlah_pengiriman'].toString(),
            detailShpData['jumlah_pengiriman_dus'].toString(),
          ];

          for (var colIndex = 1; colIndex <= 4; colIndex++) {
            sheet2
                .getRangeByIndex(rowIndex2, colIndex + 5)
                .setText(detailShpRowData[colIndex - 1]);
          }

          rowIndex2++;
        }
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

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    bool hasData = false;

    final itemReceivesQuery = firestore.collection('item_receives');
    final itemReceivesQuerySnapshot = await itemReceivesQuery.get();

    final shipmentsQuery = firestore.collection('shipments');
    final shipmentsQuerySnapshot = await shipmentsQuery.get();

    Future<List<Map<String, dynamic>>> getItemReceivesData() async {
      final data = <Map<String, dynamic>>[];
      for (final doc in itemReceivesQuerySnapshot.docs) {
        final ircData = doc.data();
        final ircDate = ircData['tanggal_penerimaan'].toDate();

        // Check if the ircDate is within the selected date range
        if ((startDate == null || ircDate.isAfter(startDate)) &&
            (endDate == null || ircDate.isBefore(endDate))) {
          hasData = true;
          final detailIRCQuery =
              doc.reference.collection('detail_item_receives');
          final detailIRCQuerySnapshot = await detailIRCQuery.get();
          final detailIRCData =
              detailIRCQuerySnapshot.docs.map((doc) => doc.data()).toList();
          data.add({
            'id': ircData['id'],
            'production_confirmation_id': ircData['production_confirmation_id'],
            'status_irc': ircData['status_irc'],
            'tanggal_penerimaan': DateFormat('dd/MM/yyyy').format(ircDate),
            'detail_item_receives': detailIRCData,
          });
        }
      }
      return data;
    }

    Future<List<Map<String, dynamic>>> getShipmentsData() async {
      final data = <Map<String, dynamic>>[];
      for (final doc in shipmentsQuerySnapshot.docs) {
        final shpData = doc.data();
        final shpDate = shpData['tanggal_pembuatan'].toDate();

        // Check if the shpDate is within the selected date range
        if ((startDate == null || shpDate.isAfter(startDate)) &&
            (endDate == null || shpDate.isBefore(endDate))) {
          final detailShpQuery = doc.reference.collection('detail_shipments');
          final detailShpQuerySnapshot = await detailShpQuery.get();
          final detailShpData =
              detailShpQuerySnapshot.docs.map((doc) => doc.data()).toList();
          data.add({
            'id': shpData['id'],
            'delivery_order_id': shpData['delivery_order_id'],
            'tanggal_pembuatan': DateFormat('dd/MM/yyyy').format(shpDate),
            'total_pcs': shpData['total_pcs'],
            'status_shp': shpData['status_shp'],
            'detail_shipments': detailShpData,
          });
        }
      }
      return data;
    }

    final itemReceivesData = await getItemReceivesData();
    final shipmentsData = await getShipmentsData();

    // Fungsi untuk membuat halaman PDF berdasarkan data "item_receives"
    void createItemReceivesPage(
        pw.Document pdf, Map<String, dynamic> itemReceiveData) {
      pdf.addPage(pw.MultiPage(
        pageTheme: const pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
        ),
        build: (pw.Context context) => [
          pw.Header(
            text: 'Laporan Pengiriman dan Penerimaan - Penerimaan Barang',
            level: 0,
            textStyle: pw.TextStyle(
              font: font,
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
                font: font1,
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
                    findProductName(detail['product_id']),
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
        pageTheme: const pw.PageTheme(
          orientation: pw.PageOrientation.landscape,
        ),
        build: (pw.Context context) => [
          pw.Header(
            text: 'Laporan Pengiriman dan Penerimaan - Pengiriman Barang',
            level: 0,
            textStyle: pw.TextStyle(
              font: font2,
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
              textStyle: const pw.TextStyle(
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
                    findProductName(detail['product_id']),
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

    if (!hasData) {
      // No matching data found for the date filter, you can add a message or handle it accordingly.
      pdf.addPage(pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('No data found for the selected date range'),
        ),
      ));
    }

    final pdfBytes = Uint8List.fromList(await pdf.save());
    return pdfBytes;
  }
}
