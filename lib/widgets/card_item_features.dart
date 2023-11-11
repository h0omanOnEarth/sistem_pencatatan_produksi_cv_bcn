import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class CardItem extends StatelessWidget {
  final IconData icon;
  final String textA;
  final String textB;
  final String pageRoute; // New property to specify the page route
  final Widget? pageWidget;

  const CardItem(
      {required this.icon,
      required this.textA,
      required this.textB,
      required this.pageRoute,
      this.pageWidget});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight =
        screenHeight * 0.16; // Sesuaikan dengan persentase yang Anda inginkan

    return GestureDetector(
      onTap: () {
        //   Navigator.push(context,MaterialPageRoute( builder: (context) => pageRoute,),
        // );
        if (kIsWeb) {
          Routemaster.of(context).push(pageRoute);
        } else {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => pageWidget!));
        }
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
          height: cardHeight, // Set the desired height of the card
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 40.0, // Set the width for the icon
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    icon,
                    size: 36, // Customize the icon size
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the text vertically
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
