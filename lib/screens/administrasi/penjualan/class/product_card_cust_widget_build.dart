import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/penjualan/class/product_card_customer_order.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdown_produk_detail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/dropdowndetail.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/text_field_widget.dart';

class ProductCardCustOrder extends StatefulWidget {
  final ProductCardDataCustomerOrder productCardData;
  final Function() updateTotalHargaProduk;
  final List<Map<String, dynamic>> productData;
  final List<ProductCardDataCustomerOrder> productCards;

  const ProductCardCustOrder({
    required this.productCardData,
    required this.updateTotalHargaProduk,
    required this.productData,
    required this.productCards,
  });

  @override
  State<ProductCardCustOrder> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCardCustOrder> {
  @override
  Widget build(BuildContext context) {
    return Card(
    elevation: 2,
    margin: const EdgeInsets.symmetric(vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: Colors.grey[300]!),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
                DropdownProdukDetailWidget(
                  label: 'Kode Produk',
                  selectedValue: widget.productCardData.kodeProduk,
                  onChanged: (newValue) {
                    setState(() {
                      if (!widget.productCards.any((card) => card.kodeProduk == newValue)) {
                        widget.productCardData.kodeProduk = newValue;
                        // Check if the product_id is already in productCards
                       final selectedProduct = widget.productData.firstWhere(
                        (product) => product['id'] == newValue,
                        orElse: () => {'nama': 'Nama Produk Tidak Ditemukan'},
                      );
                      widget.productCardData.namaProduk = selectedProduct['nama'];
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Produk sudah dipilih'),
                            duration: Duration(seconds: 2), // Duration to display the Snackbar
                          ),
                        );
                      }
                    });
                  },
                  products: widget.productData, // productData adalah daftar produk dari Firestore
                ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
              label: 'Nama Produk',
              placeholder: 'Nama Produk',
              controller: TextEditingController(text: widget.productCardData.namaProduk),
              isEnabled: false,
            ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
              label: 'Jumlah',
              placeholder: 'Jumlah',
              controller: widget.productCardData.jumlahController,
              onChanged: (value) {
              setState(() {
                widget.productCardData.jumlah = value;
                widget.productCardData.calculateSubtotal();
                widget.updateTotalHargaProduk(); // Panggil updateTotalHargaProduk
              });
            },
            ),
              const SizedBox(height: 8.0),
             DropdownDetailWidget(
            label: 'Satuan',
            items: const ['Pcs', 'Kg', 'Ons','Dus'],
            selectedValue: widget.productCardData.satuan,
            onChanged: (newValue) {
              setState(() {
                widget.productCardData.satuan = newValue;
              });
            },
          ),
              const SizedBox(height: 8.0),
              TextFieldWidget(
                label: 'Harga Satuan',
                placeholder: 'Harga Satuan',
                controller: widget.productCardData.hargaSatuanController,
                onChanged: (value) {
                setState(() {
                  widget.productCardData.hargaSatuan = value;
                  widget.productCardData.calculateSubtotal();
                  widget.updateTotalHargaProduk(); // Panggil updateTotalHargaProduk
                });
              },
              ),
              const SizedBox(height: 8.0),
             TextFieldWidget(
                label: 'Subtotal',
                placeholder: 'Subtotal',
                controller: TextEditingController(text: widget.productCardData.subtotal),
                isEnabled: false,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0), // Add the desired margin
          child: Container(
            width: double.infinity, // Make the button full width
            child: ElevatedButton(
              onPressed: () {
                // Handle delete button press
                setState(() {
                  widget.productCards.remove(widget.productCardData);
                  widget.updateTotalHargaProduk(); // Panggil updateTotalHargaProduk saat menghapus produk
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(10), // Add padding to the button
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Hapus',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
  }
}
