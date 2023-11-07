import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:routemaster/routemaster.dart';
//Local imports
import 'package:sistem_manajemen_produksi_cv_bcn/helper/save_file_web.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/main/main_administrasi.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/bahanService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/date_picker_button.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Represents the XlsIO widget class.
class LaporanPenggunaanBahan extends StatelessWidget {
  static const routeName = '/administrasi/laporan/penggunaanbahan';

  const LaporanPenggunaanBahan({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CreateExcelStatefulWidget(title: 'Laporan Penggunaan Bahan'),
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
    sheet.getRangeByName('A1:F1').columnWidth = 13;

    // Merge cells for the title and format it
    final titleRange = sheet.getRangeByName('A1:F1');
    titleRange.merge();
    titleRange.cellStyle.hAlign = HAlignType.center;
    titleRange.cellStyle.bold = true;
    titleRange.cellStyle.fontSize = 18;
    titleRange.cellStyle.backColor = '#C0C0C0'; // Header background color

    // Add the title
    titleRange.setText('Laporan Penggunaan Bahan');

    // Fetch data from Firestore and populate the Excel sheet
    final materialUsagesQuery =
        FirebaseFirestore.instance.collection('material_usages');
    final materialUsagesQuerySnapshot = await materialUsagesQuery.get();

    int rowIndex = 3;

    for (var i = 0; i < materialUsagesQuerySnapshot.docs.length; i++) {
      final materialUsageDoc = materialUsagesQuerySnapshot.docs[i];
      final materialUsageData = materialUsageDoc.data();
      final materialUsageDate =
          materialUsageData['tanggal_penggunaan'].toDate();

      // Check if the materialUsageDate is within the selected date range
      if ((startDate == null || materialUsageDate.isAfter(startDate)) &&
          (endDate == null || materialUsageDate.isBefore(endDate))) {
        // Populate headers with background colors
        for (var colIndex = 1; colIndex <= 6; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.setText([
            'ID',
            'Production Order ID',
            'Material Request ID',
            'Batch',
            'Tanggal Penggunaan',
            'Status MU'
          ][colIndex - 1]);
          cell.cellStyle.backColor = '#FFFF00'; // Header background color
          cell.cellStyle.bold = true;
        }

        rowIndex++;

        // Populate data cells
        for (var colIndex = 1; colIndex <= 6; colIndex++) {
          sheet.getRangeByIndex(rowIndex, 1).setText(materialUsageDoc.id);
          sheet
              .getRangeByIndex(rowIndex, 2)
              .setText(materialUsageData['production_order_id']);
          sheet
              .getRangeByIndex(rowIndex, 3)
              .setText(materialUsageData['material_request_id']);
          sheet
              .getRangeByIndex(rowIndex, 4)
              .setText(materialUsageData['batch']);
          sheet.getRangeByIndex(rowIndex, 5).setDateTime(materialUsageDate);
          sheet
              .getRangeByIndex(rowIndex, 6)
              .setText(materialUsageData['status_mu']);
        }

        // Add a separator line
        for (var colIndex = 1; colIndex <= 6; colIndex++) {
          final cell = sheet.getRangeByIndex(rowIndex, colIndex);
          cell.cellStyle.borders.bottom.color = '#000000'; // Border color
        }

        // Fetch and populate the details from subcollection
        final detailMaterialUsagesQuery =
            materialUsageDoc.reference.collection('detail_material_usages');
        final detailMaterialUsagesQuerySnapshot =
            await detailMaterialUsagesQuery.get();
        final detailMaterialUsages = detailMaterialUsagesQuerySnapshot.docs
            .map((doc) => doc.data())
            .toList();

        if (detailMaterialUsages.isNotEmpty) {
          rowIndex++;
          // Populate detail headers with a different background color
          for (var colIndex = 1; colIndex <= 3; colIndex++) {
            final cell = sheet.getRangeByIndex(rowIndex, colIndex);
            cell.setText(['Material ID', 'Jumlah', 'Satuan'][colIndex - 1]);
            cell.cellStyle.backColor =
                '#FFFF00'; // Header detail_material_usages background color
            cell.cellStyle.bold = true;
          }

          // Add 'Nama Bahan' header with background color
          sheet.getRangeByIndex(rowIndex, 4).setText('Nama Bahan');
          sheet.getRangeByIndex(rowIndex, 4).cellStyle.backColor = '#FFFF00';
          sheet.getRangeByIndex(rowIndex, 4).cellStyle.bold = true;

          rowIndex++;

          for (var j = 0;
              j < detailMaterialUsagesQuerySnapshot.docs.length;
              j++) {
            final detailMaterialUsageData = detailMaterialUsages[j];

            // Populate data cells for detail_material_usages
            for (var colIndex = 1; colIndex <= 3; colIndex++) {
              final cell = sheet.getRangeByIndex(rowIndex, colIndex);
              cell.setText([
                detailMaterialUsageData['material_id'],
                detailMaterialUsageData['jumlah'].toString(),
                detailMaterialUsageData['satuan']
              ][colIndex - 1]);
            }

            // Fetch material info using the MaterialService
            final materialId = detailMaterialUsageData['material_id'];
            final materialInfo =
                await MaterialService().getMaterialInfo(materialId);

            // Populate 'Nama Bahan' column with material name
            sheet
                .getRangeByIndex(rowIndex, 4)
                .setText(materialInfo != null ? materialInfo['nama'] : '');
            rowIndex++;
          }
        }

        if (i < materialUsagesQuerySnapshot.docs.length - 1) {
          // Add a separator line between material_usages
          for (var colIndex = 1; colIndex <= 6; colIndex++) {
            final cell = sheet.getRangeByIndex(rowIndex, colIndex);
            cell.cellStyle.borders.bottom.color = '#000000';
          }
          rowIndex++;
        }
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
    final materialUsages =
        materialUsagesQuerySnapshot.docs.map((doc) => doc.data()).toList();

    final font = await PdfGoogleFonts.nunitoExtraLight();
    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();

    bool hasData = false; // Add a flag to check if there's matching data

    for (var i = 0; i < materialUsages.length; i++) {
      final mu = materialUsages[i];
      final muDate = mu['tanggal_penggunaan'].toDate();

      // Check if the muDate is within the selected date range
      if ((startDate == null || muDate.isAfter(startDate)) &&
          (endDate == null || muDate.isBefore(endDate))) {
        hasData = true; // Set the flag to true if there's matching data

        final detailMaterialUsagesQuery = materialUsagesQuery
            .doc(mu['id'])
            .collection('detail_material_usages');
        final detailMaterialUsagesQuerySnapshot =
            await detailMaterialUsagesQuery.get();
        final detailMaterialUsages = detailMaterialUsagesQuerySnapshot.docs
            .map((doc) => doc.data())
            .toList();

        final pages = <pw.Widget>[];
        pages.add(
          pw.Header(
            text: 'Laporan Penggunaan Bahan',
            level: 0,
            textStyle: pw.TextStyle(
              font: font,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        );
        pages.add(
          pw.Header(
            text: 'Material Usage ID: ${mu['id']}',
            level: 1,
            textStyle: pw.TextStyle(
              font: font2,
              fontSize: 14,
            ),
          ),
        );
        pages.add(
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
                DateFormat('dd/MM/yyyy').format(muDate),
                mu['status_mu'].toString(),
                // Initialize these columns with empty strings
              ],
            ],
          ),
        );

        if (detailMaterialUsages.isNotEmpty) {
          pages.add(
            pw.Header(
              text: 'Detail Penggunaan Bahan',
              level: 2,
              textStyle: pw.TextStyle(
                font: font2,
                fontSize: 14,
              ),
            ),
          );
          pages.add(
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
          );
        }

        pdf.addPage(
          pw.MultiPage(
            pageTheme: pw.PageTheme(
              orientation: pw.PageOrientation.landscape,
              theme: pw.ThemeData.withFont(
                base: font1,
                bold: font2,
              ),
            ),
            build: (pw.Context context) => pages,
          ),
        );
      }
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
