import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';

class FakturPenjualanReport extends StatefulWidget {
  final String idInvoice;

  const FakturPenjualanReport({Key? key, required this.idInvoice})
      : super(key: key);

  @override
  State<FakturPenjualanReport> createState() => _FakturPenjualanReportState();
}

class _FakturPenjualanReportState extends State<FakturPenjualanReport> {
  var tanggalPembuatan;
  var metodePembayaran;
  var nomorRekening;
  var id;
  var deliveryOrderId;
  var total;
  var totalPcs;
  List<Map<String, dynamic>> detailInvoices = [];
  ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadInvoiceData() async {
    final invoiceSnapshot = await FirebaseFirestore.instance
        .collection('invoices')
        .doc(widget.idInvoice)
        .get();

    if (invoiceSnapshot.exists) {
      setState(() {
        tanggalPembuatan = invoiceSnapshot.get('tanggal_pembuatan');
        metodePembayaran = invoiceSnapshot.get('metode_pembayaran');
        nomorRekening = invoiceSnapshot.get('nomor_rekening') ?? '-';
        total = invoiceSnapshot.get('total');
        totalPcs = invoiceSnapshot.get('total_produk');
        id = invoiceSnapshot.get('id');
        deliveryOrderId = invoiceSnapshot.get('shipment_id');
      });

      final detailSnapshot = await FirebaseFirestore.instance
          .collection('invoices')
          .doc(widget.idInvoice)
          .collection('detail_invoices')
          .get();

      if (detailSnapshot.docs.isNotEmpty) {
        for (var doc in detailSnapshot.docs) {
          Map<String, dynamic> detail = doc.data();
          String productId = detail['product_id'];
          int harga = detail['harga'];
          int jumlah = detail['jumlah_pengiriman'];
          int subtotal = harga * jumlah;

          // Ambil data produk jika diperlukan
          // Misalnya, fetchProductInfo(productId) harus diimplementasikan.
          Map<String, dynamic> productInfo =
              await productService.fetchProductInfo(productId);
          String productName =
              productInfo.containsKey('nama') ? productInfo['nama'] : 'N/A';

          // Tambahkan informasi harga dan subtotal
          detail['harga'] = harga;
          detail['subtotal'] = subtotal;

          // Contoh jika Anda ingin mengambil nama produk
          detail['product_name'] = productName;

          detailInvoices.add(detail);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faktur Penjualan Report'),
      ),
      body: PdfPreview(
        allowPrinting: true,
        build: (format) => generateDocument(format),
      ),
    );
  }

  Future<Uint8List> generateDocument(PdfPageFormat format) async {
    final doc = pw.Document();

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();
    final Uint8List logoImage =
        (await rootBundle.load('images/logo2.jpg')).buffer.asUint8List();

    await loadInvoiceData();

    doc.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          pageFormat: format.copyWith(
            marginBottom: 20.0,
            marginLeft: 20.0,
            marginRight: 20.0,
            marginTop: 20.0,
          ),
          orientation: pw.PageOrientation.landscape,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),
        build: (context) {
          return pw.Column(
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    child: pw.Image(pw.MemoryImage(logoImage),
                        width: 100, height: 100),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CV. Berlian Cangkir Nusantara',
                          style: const pw.TextStyle(fontSize: 20)),
                      pw.Text(
                          'Jl. Panglima Sudirman No.9, Sidoarjo, Jawa Timur',
                          style: const pw.TextStyle(fontSize: 20)),
                      pw.Text('031 - 7881911',
                          style: const pw.TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Text('Nomor Faktur: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(id ?? 'N/A', style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Tanggal Pembuatan: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(
                      tanggalPembuatan != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(tanggalPembuatan.toDate())
                          : 'N/A', // Sesuaikan dengan format tanggal yang sesuai
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Metode Pembayaran: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(metodePembayaran ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Nomor Rekening: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(nomorRekening ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Nomor Surat Jalan: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(deliveryOrderId ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Header(text: 'Detail Faktur', level: 1),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'ID',
                    'Nama Produk',
                    'Jumlah',
                    'Harga',
                    'Subtotal',
                  ],
                  for (var detail in detailInvoices)
                    <String>[
                      detail['product_id'] ?? 'N/A',
                      detail['product_name']?.toString() ?? 'N/A',
                      detail['jumlah_pengiriman']?.toString() ?? 'N/A',
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                          .format(detail['harga'] ?? 0),
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                          .format(detail['subtotal'] ?? 0),
                    ],
                ],
              ),
              pw.SizedBox(height: 16.0),
              // Total Pcs
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total Pcs:',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      '${NumberFormat.decimalPattern().format(totalPcs)} Pcs',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total:',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                          .format(total),
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 16.0),
              // Tempat tanda tangan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tanda Tangan Penerima:',
                          style: const pw.TextStyle(fontSize: 20)),
                      pw.SizedBox(height: 36.0),
                      pw.Text('__________________________',
                          style: const pw.TextStyle(fontSize: 20)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Tanda Tangan Pengirim:',
                          style: const pw.TextStyle(fontSize: 20)),
                      pw.SizedBox(height: 36.0),
                      pw.Text('__________________________',
                          style: const pw.TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}
