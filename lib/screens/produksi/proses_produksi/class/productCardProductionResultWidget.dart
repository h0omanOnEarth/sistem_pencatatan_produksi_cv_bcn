// ignore: file_names
import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/produksi/proses_produksi/class/productCardProductionResult.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/services/productionOrderService.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdown_produk_detail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardProductionResultWidget extends StatefulWidget {
  final ProductCardDataProductionResult productCardData;
  final List<Map<String, dynamic>> productData;
  final List<ProductCardDataProductionResult> productCards;

  const ProductCardProductionResultWidget({
    required this.productCardData,
    required this.productCards,
    required this.productData
    });

  @override
  _ProductCardProductionResultWidgetState createState() => _ProductCardProductionResultWidgetState();
}

class _ProductCardProductionResultWidgetState extends State<ProductCardProductionResultWidget> {

  final productionOrderService = ProductionOrderService();

  @override
  void initState() {
    super.initState();
    // Initialize the jumlahController with the current 'jumlah' value
    widget.productCardData.jumlahController =
        TextEditingController(text: widget.productCardData.jumlahKonfirmasi);
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownProdukDetailWidget(
              label: 'Hasil Produksi',
              selectedValue: widget.productCardData.nomorHasilProduksi,
             onChanged: (newValue) async {
                final selectedProduct = widget.productData.firstWhere(
                  (product) => product['id'] == newValue,
                  orElse: () => {'nama': ''},
                );

                final productionOrderId = await productionOrderService.findProductionOrderId(selectedProduct['materialUsageId']);
                Map<String, dynamic>? product = await productionOrderService.getProductInfoForProductionOrder(productionOrderId!);

                setState(() {
                  widget.productCardData.nomorHasilProduksi = newValue;
                  widget.productCardData.satuan = selectedProduct['satuan'].toString();
                  widget.productCardData.jumlahHasil = selectedProduct['jumlahHasil'].toString();
                  widget.productCardData.namaBarang = product?['product_name'];
                  widget.productCardData.kodeBarang = product?['product_id'];
                });
              },
              products: widget.productData, // productData adalah daftar produk dari Firestore
            ),
      const SizedBox(height: 16.0,),
      Row(
        children: [
          Expanded(child:
            TextFieldWidget(
                label: 'Kode Barang',
                placeholder: '0',
                controller: TextEditingController(text: widget.productCardData.kodeBarang),
                isEnabled: false,
              ), 
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child:   
            TextFieldWidget(
                label: 'Nama Barang',
                placeholder: 'Nama Barang',
                controller: TextEditingController(text: widget.productCardData.namaBarang),
                isEnabled: false,
            ), 
          ),
        ],
       ),   
      const SizedBox(height: 16.0,),
      Row(
        children: [
          Expanded(child:
            TextFieldWidget(
                label: 'Jumlah Hasil',
                placeholder: '0',
                controller: TextEditingController(text: widget.productCardData.jumlahHasil),
                isEnabled: false,
              ), 
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child:   
            TextFieldWidget(
                label: 'Satuan',
                placeholder: 'Satuan',
                controller: TextEditingController(text: widget.productCardData.satuan),
                isEnabled: false,
            ), 
          ),
        ],
       ),   
      const SizedBox(height: 16.0,),
      TextFieldWidget(
            label: 'Jumlah Konfirmasi',
            placeholder: '0',
            controller: widget.productCardData.jumlahController,
              onChanged: (newValue) {
                  setState(() {
                    widget.productCardData.jumlahKonfirmasi = newValue;
                  });
                },
        ), 
      ],
    );
  }
}
