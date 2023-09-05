import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pengembalian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/form_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/administrasi/pembelian/list_pesanan_pembelian.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/screens/notifikasi_screen.dart';

class MainPembelianAdministrasiScreen extends StatefulWidget {
  static const routeName = '/main_pembelian_administrasi';
  const MainPembelianAdministrasiScreen({Key? key});

  @override
  State<MainPembelianAdministrasiScreen> createState() => _MainMasterAdministrasiScreenState();
}

class _MainMasterAdministrasiScreenState extends State<MainPembelianAdministrasiScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/background_white.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 30),
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
                                builder: (context) => NotifikasiScreen(),
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
                    const CardItem(icon: Icons.point_of_sale, textA: 'Pesanan Pembelian', textB: 'Memodifikasi dan melihat pesanan pembelian', pageRoute: ListPesananPembelian()),
                    const CardItem(icon: Icons.shopping_cart_checkout, textA: 'Pesanan Pengembalian', textB: 'Memodifikasi dan melihat pesanan pengembalian', pageRoute: FormPengembalianPesananScreen()),
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



class CardItem extends StatelessWidget {
  final IconData icon;
  final String textA;
  final String textB;
  final Widget pageRoute; // New property to specify the page route

  const CardItem({
    required this.icon,
    required this.textA,
    required this.textB,
    required this.pageRoute,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
              Navigator.push(context,MaterialPageRoute( builder: (context) => pageRoute,),
            );
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0), // Set corner radius
          side: const BorderSide(
            color: Colors.grey, // Set border color
            width: 1.0, // Set border width
          ),
        ),
        child: Container(
          height: 100.0, // Set the desired height of the card
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 40.0, // Set the width for the icon
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    icon,
                    size: 36, // Customize the icon size
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Center the text vertically
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      textA,
                      style: const TextStyle(
                        fontSize: 18, // Customize the font size
                        fontWeight: FontWeight.bold, // Make the text bold
                      ),
                    ),
                    Text(textB),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
