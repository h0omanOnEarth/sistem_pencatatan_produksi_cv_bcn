import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/customerService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/deliveryOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productService.dart';

class SuratJalanReport extends StatefulWidget {
  final String idShipment;

  const SuratJalanReport({
    Key? key,
    required this.idShipment,
  }) : super(key: key);

  @override
  State<SuratJalanReport> createState() => _SuratJalanReportState();
}

class _SuratJalanReportState extends State<SuratJalanReport> {
  var alamatPenerima;
  var deliveryOrderId;
  var tanggalPembuatan;
  var id;
  var totalPcs;
  var namaPelanggan;
  var metodePengiriman;
  var namaEkspedisi;

  List<Map<String, dynamic>> detailShipments = [];
  final ProductService productService = ProductService();
  final DeliveryOrderService deliveryOrderService = DeliveryOrderService();
  final CustomerOrderService customerOrderService = CustomerOrderService();
  final CustomerService customerService = CustomerService();
  late Future<void> _loadingData;

  @override
  void initState() {
    super.initState();
    _loadingData = _initAsync();
  }

  Future<void> _initAsync() async {
    await loadShipmentData();
  }

  Future<void> loadShipmentData() async {
    final shipmentSnapshot = await FirebaseFirestore.instance
        .collection('shipments')
        .doc(widget.idShipment)
        .get();

    if (shipmentSnapshot.exists) {
      setState(() {
        alamatPenerima = shipmentSnapshot.get('alamat_penerima');
        deliveryOrderId = shipmentSnapshot.get('delivery_order_id');

        final DateTime date =
            shipmentSnapshot.get('tanggal_pembuatan').toDate();
        final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
        tanggalPembuatan = dateFormat.format(date);

        id = shipmentSnapshot.get('id');
        totalPcs = shipmentSnapshot.get('total_pcs');
      });

      Map<String, dynamic>? doInfo =
          await deliveryOrderService.getDeliveryOrderInfo(deliveryOrderId);
      Map<String, dynamic>? coInfo = await customerOrderService
          .getCustomerOrderInfo(doInfo?['customerOrderId']);
      Map<String, dynamic>? custInfo =
          await customerService.getCustomerInfo(coInfo?['customer_id']);
      namaPelanggan = custInfo?['nama'];
      metodePengiriman = doInfo?['metodePengiriman'];
      namaEkspedisi = doInfo?['namaEkspedisi'];

      final detailSnapshot = await FirebaseFirestore.instance
          .collection('shipments')
          .doc(widget.idShipment)
          .collection('detail_shipments')
          .get();

      if (detailSnapshot.docs.isNotEmpty) {
        for (var doc in detailSnapshot.docs) {
          Map<String, dynamic> detail = doc.data();
          String productId = detail['product_id'];
          Map<String, dynamic> productInfo =
              await productService.fetchProductInfo(productId);
          String productName =
              productInfo.containsKey('nama') ? productInfo['nama'] : 'N/A';
          String banyaknya = productInfo.containsKey('banyaknya')
              ? productInfo['banyaknya'].toString()
              : 'N/A';
          detail['product_name'] = productName;
          detail['banyaknya'] = banyaknya;

          detailShipments.add(detail);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Surat Jalan Report'),
      ),
      body: FutureBuilder<void>(
        future: _loadingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle errors
            return const Center(child: Text('Error loading data'));
          } else {
            // Data has been loaded, build your UI
            return PdfPreview(
              allowPrinting: true,
              build: (format) => generateDocument(format),
            );
          }
        },
      ),
    );
  }

  Future<Uint8List> generateDocument(PdfPageFormat format) async {
    final doc = pw.Document();

    final font1 = await PdfGoogleFonts.openSansRegular();
    final font2 = await PdfGoogleFonts.openSansBold();
    final Uint8List logoImage =
        (await rootBundle.load('images/logo2.jpg')).buffer.asUint8List();

    doc.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: format.copyWith(
            marginBottom: 20.0, // Margin bawah
            marginLeft: 20.0, // Margin kiri
            marginRight: 20.0, // Margin kanan
            marginTop: 20.0, // Margin atas
          ),
          orientation: pw.PageOrientation.landscape,
          theme: pw.ThemeData.withFont(
            base: font1,
            bold: font2,
          ),
        ),
        build: (context) => [
          pw.Column(
            children: [
              // Logo dan alamat
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    child: pw.Image(pw.MemoryImage(logoImage),
                        width: 100, height: 100),
                  ),
                  pw.SizedBox(width: 20), // Tambahkan padding horizontal
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
                  pw.Text('Nomor Surat Jalan: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(id ?? 'N/A', style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              // Alamat penerima
              pw.Wrap(
                children: [
                  pw.Text(
                    'Alamat Penerima: ',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                  pw.Text(
                    alamatPenerima ?? 'N/A',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Metode Pengiriman: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(
                    metodePengiriman ?? 'N/A',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Nama Ekspedisi: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(
                    namaEkspedisi ?? 'N/A',
                    style: const pw.TextStyle(fontSize: 20),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Tanggal: ', style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(tanggalPembuatan ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text('Nama Pelanggan: ',
                      style: const pw.TextStyle(fontSize: 20)),
                  pw.Text(namaPelanggan ?? 'N/A',
                      style: const pw.TextStyle(fontSize: 20)),
                ],
              ),
              pw.SizedBox(height: 20),
              // Detail pengiriman
              pw.Header(text: 'Detail Pengiriman', level: 1),
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>[
                    'ID',
                    'Nama Produk',
                    'Banyaknya @dus',
                    'Jumlah Pengiriman',
                    'Jumlah Pengiriman Dus'
                  ],
                  for (var detail in detailShipments)
                    <String>[
                      detail['product_id'] ?? 'N/A',
                      detail['product_name']?.toString() ?? 'N/A',
                      detail['banyaknya']?.toString() ?? 'N/A',
                      detail['jumlah_pengiriman']?.toString() ?? 'N/A',
                      detail['jumlah_pengiriman_dus']?.toString() ?? 'N/A',
                    ],
                ],
              ),
              pw.SizedBox(height: 20),
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text('Total: ',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('${totalPcs?.toString()} Pcs',
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
          )
        ],
      ),
    );

    return doc.save();
  }
}
