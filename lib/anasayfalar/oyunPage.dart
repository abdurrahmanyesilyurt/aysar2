import 'package:flutter/material.dart';

import 'Game1.dart';
import 'Game2.dart';
import 'Game3.dart';

class oyunPage extends StatefulWidget {
  @override
  _oyunPageState createState() => _oyunPageState();
}

class _oyunPageState extends State<oyunPage> {
  final List<Map<String, dynamic>> games = [
    {'name': 'Resim', 'description': 'Resimdeki Nesnenin \nIngilizcesini Bulma \nOyunu', 'image': 'game1.webp'},
    {'name': 'Video', 'description': 'Videodaki Repliği\n Çevirme Oyunu', 'image': 'game2.webp'},
    {'name': 'Kelime', 'description': 'Kelime Veya Cümle \nÇevirme Oyunu', 'image': 'game3.png'},
  ]; // Oyunlar için liste

  String selectedGameImage = '';
  final Map<String, Widget> gamePages = {
    'Resim': Game1(),
    'Video': Game2(),
    'Kelime': Game3(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.deepOrange,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              'Oyun Seçimi',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.deepOrange, // Ekranın arka plan rengi
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  if (selectedGameImage.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => gamePages[games.firstWhere((game) => game['image'] == selectedGameImage)['name']]!),
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.0),top: Radius.circular(20.0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: selectedGameImage.isNotEmpty
                      ? Image.asset(
                    'resimler/$selectedGameImage',
                    fit: BoxFit.cover,
                  )
                      : Center(child: Text('Lütfen bir oyun seçin'),
                  ),
                  height: MediaQuery.of(context).size.height * 0.8, // Ekran yüksekliğinin %80'ı kadar
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 150.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: games.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedGameImage = games[index]['image'];
                      });
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              games[index]['name'], // Oyun adı
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              games[index]['description'], // Oyun açıklaması
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}