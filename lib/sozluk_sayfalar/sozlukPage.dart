import 'package:aysar2/sozluk_sayfalar/sozluk_kategori.dart';
import 'package:aysar2/sozluk_sayfalar/sozluk_kelimeler.dart';
import 'package:flutter/material.dart';

class SozlukPage extends StatelessWidget {
  void _navigateToWordsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => sozluk_kelimeler()),
    );
  }

  void _navigateToPhrasesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => sozluk_kategori()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.g_translate)),
        title: Text("Sözlük Sayfası", style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => _navigateToWordsPage(context),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("resimler/kelimeler.webp"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => _navigateToPhrasesPage(context),
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("resimler/kaliplar.webp"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "",
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
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
