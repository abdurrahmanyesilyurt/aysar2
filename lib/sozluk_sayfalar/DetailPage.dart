import 'package:flutter/material.dart';
class DetailPage extends StatelessWidget {
  final Map<String, dynamic> category;

  DetailPage({required this.category});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> phrases = category["phrases"];
    return Scaffold(
      appBar: AppBar(
        title: Text('${category["kategori"] ?? "Kategori"} İfadeleri'),
      ),
      body: ListView.builder(
        itemCount: phrases.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              color: Colors.grey[300],
              child: Container(
                padding: EdgeInsets.all(15),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrases[index]["ingilizce"] ?? "Bilgi yok", // Null değilse göster, değilse alternatif metin
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8,),
                    Text(
                      phrases[index]["turkce"] ?? "Bilgi yok", // Null değilse göster, değilse alternatif metin
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
