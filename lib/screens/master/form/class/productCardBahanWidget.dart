import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/master/form/class/productCardDataBahan.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdown_produk_detail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdowndetail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardBahanWidget extends StatefulWidget {
  final ProductCardDataBahan productCardData;
  final List<Map<String, dynamic>> productData;
  final List<ProductCardDataBahan> productCards;
  final bool isEnabled;

  const ProductCardBahanWidget({
    super.key,
    required this.productCardData,
    required this.productData,
    required this.productCards,
    this.isEnabled = true,
  });

  @override
  _ProductCardBahanWidgetState createState() => _ProductCardBahanWidgetState();
}

class _ProductCardBahanWidgetState extends State<ProductCardBahanWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize the jumlahController with the current 'jumlah' value
    widget.productCardData.jumlahController =
        TextEditingController(text: widget.productCardData.jumlah);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownProdukDetailWidget(
          label: 'Nama Bahan',
          selectedValue: widget.productCardData.kodeBahan,
          onChanged: (newValue) {
            setState(() {
              // Check if the product_id is already in productCards
              if (!widget.productCards
                  .any((card) => card.kodeBahan == newValue)) {
                widget.productCardData.kodeBahan = newValue;
                final selectedProduct = widget.productData.firstWhere(
                  (product) => product['id'] == newValue,
                  orElse: () => {'nama': 'Nama Bahan Tidak Ditemukan'},
                );
                widget.productCardData.namaBahan = selectedProduct['id'];
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bahan sudah dipilih'),
                    duration: Duration(
                        seconds: 2), // Duration to display the Snackbar
                  ),
                );
              }
            });
          },
          products: widget
              .productData, // productData adalah daftar produk dari Firestore
          isEnabled: widget.isEnabled,
        ),
        const SizedBox(height: 8.0),
        TextFieldWidget(
          label: 'Kode Bahan',
          placeholder: 'Kode Bahan',
          controller:
              TextEditingController(text: widget.productCardData.namaBahan),
          isEnabled: false,
        ),
        const SizedBox(
          height: 16.0,
        ),
        if (widget.productCardData.namaBatch !=
            null) // Periksa apakah namaBatch tidak null
          DropdownDetailWidget(
            label: 'Batch',
            items: const ['Penggilingan', 'Pencampuran', 'Sheet', 'Pencetakan'],
            selectedValue: widget.productCardData.namaBatch ?? '',
            onChanged: (newValue) {
              setState(() {
                widget.productCardData.namaBatch = newValue;
              });
            },
            isEnabled: widget.isEnabled,
          ),
        if (widget.productCardData.namaBatch != null)
          const SizedBox(
            height: 16.0,
          ),
        Row(
          children: [
            Expanded(
              child: TextFieldWidget(
                label: 'Jumlah',
                placeholder: '0',
                controller: widget.productCardData.jumlahController,
                onChanged: (newValue) {
                  setState(() {
                    widget.productCardData.jumlah = newValue;
                  });
                },
                isEnabled: widget.isEnabled,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: DropdownDetailWidget(
                label: 'Satuan',
                items: const ['Pcs', 'Kg', 'Ons', 'Ton', 'Roll'],
                selectedValue: widget.productCardData.satuan,
                onChanged: (newValue) {
                  setState(() {
                    widget.productCardData.satuan = newValue;
                  });
                },
                isEnabled: widget.isEnabled,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
