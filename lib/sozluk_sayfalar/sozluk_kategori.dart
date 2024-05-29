import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DetailPage.dart';

class sozluk_kategori extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> _fetchCategories() {
    return _firestore.collection('sozluk').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var phrasesList = [];
        doc.data().forEach((key, value) {
          if (key.startsWith('kelime')) {
            phrasesList.add({"ingilizce": value['ingilizce'], "turkce": value['turkce']});
          }
        });
        return {
          "kategori": doc.id,
          "phrases": phrasesList.map((item) => Map<String, String>.from(item)).toList(),
          "imageFile": 'resimler/${doc.id}.webp', // The image file path
        };
      }).toList();
    });
  }

  void _navigateToDetailPage(BuildContext context, Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailPage(category: category)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text("Kalıplar", style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("An error occurred!"));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var categories = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(20.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var category = categories[index];
              var imageFile = category['imageFile'];

              return Card(
                elevation: 4.0,
                child: InkWell(
                  onTap: () => _navigateToDetailPage(context, category),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Image.asset(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          category["kategori"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black, // Darker text color
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
