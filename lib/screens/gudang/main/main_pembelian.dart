import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/list/list_material_receive.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/gudang/pembelian/list/list_purchase_request.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/widgets/card_item_features.dart';

class MainPembelianGudangScreen extends StatefulWidget {
  static const routeName = '/gudang/pembelian';
  const MainPembelianGudangScreen({Key? key});

  @override
  State<MainPembelianGudangScreen> createState() =>
      _MainPembelianGudangScreenState();
}

class _MainPembelianGudangScreenState extends State<MainPembelianGudangScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background_white.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16)
                    .add(const EdgeInsets.only(top: 30)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 20.0),
                          child: const Text(
                            'Pembelian',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Handle notification button press
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const NotifikasiScreen(),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 20.0),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.notifications,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const CardItem(
                      icon: Icons.shopping_cart,
                      textA: 'Permintaan Pembelian',
                      textB: 'Memodifikasi dan melihat permintaan pembelian',
                      pageRoute: ListPurchaseRequest.routeName,
                      pageWidget: ListPurchaseRequest(),
                    ),
                    const CardItem(
                      icon: Icons.note_add_sharp,
                      textA: 'Penerimaan Bahan',
                      textB: 'Memodifikasi dan melihat penerimaan bahan',
                      pageRoute: ListMaterialReceive.routeName,
                      pageWidget: ListMaterialReceive(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
