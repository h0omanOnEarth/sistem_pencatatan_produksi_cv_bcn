import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final Widget formScreen;
  final String? routes;
  final String? routeName;

  const CustomAppBar({
    required this.title,
    required this.formScreen,
    this.routes,
    this.routeName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double fontSize = 24.0; // Ukuran font default

    return SizedBox(
      height: 80,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const SizedBox(width: 8.0),
                Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                    onTap: () {
                      if (kIsWeb) {
                        Routemaster.of(context).push(routes!);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24.0),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: RichText(
                    text: TextSpan(
                      text: title,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      children: [
                        if (MediaQuery.of(context).size.width <= 600)
                          const TextSpan(
                            text: '\n', // Tambahkan baris baru jika di layar HP
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.brown,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                    onPressed: () {
                      if (routeName == null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => formScreen,
                          ),
                        );
                      } else {
                        Routemaster.of(context).push(routeName!);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
