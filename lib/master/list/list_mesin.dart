import 'package:flutter/material.dart';
import 'package:sistem_manajemen_produksi_cv_bcn/master/form/form_mesin.dart';

class ListMasterMesinScreen extends StatefulWidget {
  static const routeName = '/list_master_mesin_screen';

  const ListMasterMesinScreen({super.key});
  @override
  State<ListMasterMesinScreen> createState() => _ListMasterMesinScreenState();
}

class _ListMasterMesinScreenState extends State<ListMasterMesinScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 80,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(width: 8.0),
                            Align(
                              alignment: Alignment.topLeft,
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
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
                            SizedBox(width: 24.0),
                            const Text(
                              'Mesin',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: screenWidth*0.30),
                            Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.brown,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.add),
                                color: Colors.white,
                                onPressed: () {
                                    Navigator.push(context,MaterialPageRoute( builder: (context) => FormMasterMesinScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24.0), // Add spacing between header and cards
                  // Search Bar and Filter Button
                        Row(
                          children: [
                            Container(
                              child: buildSearchBar(),
                              width: screenWidth * 0.75, // Adjust the width as needed
                            ),
                            SizedBox(width: 16.0), // Add spacing between search bar and filter button
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.grey[400]!),
                              ),
                              child: IconButton(
                                icon: Icon(Icons.filter_list),
                                onPressed: () {
                                  // Handle filter button press
                                },
                              ),
                            ),
                          ],
                        ),
                // Create 6 cards
                SizedBox(height: 16.0,),
                buildCard('Card 1', 'This is a small description for Card 1'),
                buildCard('Card 2', 'This is a small description for Card 2'),
                buildCard('Card 3', 'This is a small description for Card 3'),
                buildCard('Card 4', 'This is a small description for Card 4'),
                buildCard('Card 5', 'This is a small description for Card 5'),
                buildCard('Card 6', 'This is a small description for Card 6'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(String title, String description) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 4), // Add spacing between title and description
            Text(
              description,
              style: const TextStyle(
                color: Colors.grey, // Set text color to grey
                fontSize: 12, // Set a smaller font size
              ),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 8.0,),
          ],
        ),
      ),
    );
  }
  
// Search Bar
Widget buildSearchBar() {
  return TextField(
    decoration: InputDecoration(
      hintText: 'Search...',
      prefixIcon: Icon(
        Icons.search,
        color: Colors.grey[400], // Ubah warna ikon search menjadi abu-abu 400
      ),
      filled: true,
      fillColor: Colors.white,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    ),
  );
}

}

