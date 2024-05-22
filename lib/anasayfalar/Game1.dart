import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Game1 extends StatefulWidget {
  @override
  _Game1State createState() => _Game1State();
}

class _Game1State extends State<Game1> {
  String selectedOption = '';
  String imageUrl = '';
  List<String> options = [];
  bool isLoading = false;
  int correctAnswers = 0;
  int questionCount = 0;
  String correctOption = '';

  @override
  void initState() {
    super.initState();
    fetchGameData();
  }

  Future<void> fetchGameData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Firestore'dan tüm soruları çek
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('games')
          .get();

      // Tüm belgeleri listeye dönüştür
      List<QueryDocumentSnapshot> documents = snapshot.docs;

      if (documents.isNotEmpty) {
        // Rastgele bir belge seç
        Random random = Random();
        int randomIndex = random.nextInt(documents.length);
        DocumentSnapshot selectedDoc = documents[randomIndex];

        // Rastgele seçilen belgeden verileri al
        Map<String, dynamic>? data = selectedDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          // Belgedeki tüm "question" anahtarlarını alın
          List<String> questionKeys = data.keys.where((key) => key.startsWith('question')).toList();

          if (questionKeys.isNotEmpty) {
            // Rastgele bir "question" anahtarı seç
            String randomQuestionKey = questionKeys[random.nextInt(questionKeys.length)];
            List<dynamic> questionData = data[randomQuestionKey];
            if (questionData.length >= 5) {
              options = List<String>.from(questionData.sublist(0, 4)); // İlk 4 eleman seçenekler
              correctOption = questionData[0]; // Doğru seçenek
              String imagePath = questionData[4]; // 5. eleman resim yolu

              // Firebase Storage'dan indirme URL'sini al
              String downloadUrl = await FirebaseStorage.instance
                  .ref(imagePath)
                  .getDownloadURL();

              setState(() {
                imageUrl = downloadUrl;
                selectedOption = '';
                options.shuffle(); // Seçenekleri karıştır
              });
            } else {
              print('Error: Question data does not have enough elements.');
            }
          } else {
            print('Error: No question fields found in the document.');
          }
        } else {
          print('Error: Document data is null.');
        }
      } else {
        print('Error: No documents found in the collection.');
      }
    } catch (e) {
      print('Error fetching game data: $e');
    } finally {
      setState(() {
        isLoading = false;
        questionCount++;
      });
    }
  }

  void onOptionSelected(String option) {
    String feedbackMessage = '';
    bool isCorrect = option == correctOption;

    Color backgroundColor;
    if (isCorrect) {
      correctAnswers++;
      feedbackMessage = 'Doğru!';
      backgroundColor = Colors.green; // Yeşil arka plan
    } else {
      feedbackMessage = 'Yanlış!.';
      backgroundColor = Colors.red; // Kırmızı arka plan
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feedbackMessage,
          style: TextStyle(color: Colors.white), // SnackBar metin rengi
        ),
        backgroundColor: backgroundColor, // SnackBar arka plan rengi
        duration: Duration(seconds: 1),
      ),
    );

    setState(() {
      selectedOption = option;
    });

    // Cevap verildikten sonra bir süre bekleyip yeni soru yükle
    Future.delayed(Duration(seconds: 2), () {
      if (questionCount < 5) {
        fetchGameData();
      } else {
        showGameOverDialog();
      }
    });
  }


  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Oyun Bitti!",style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text("Toplam Doğru Sayısı: $correctAnswers",style: TextStyle(fontWeight: FontWeight.w500),),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                exitGame();
              },
            ),
          ],
        );
      },
      barrierDismissible: false, // Çarpı butonunu kapatır
    );
  }

  void exitGame() {
    Navigator.of(context).pop(); // Dialogu kapat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text('Resim Oyunu',style: TextStyle(fontWeight: FontWeight.bold),),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Image.network(
                      imageUrl,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Which one is this?',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ...options.map((option) => GestureDetector(
              onTap: () {
                onOptionSelected(option);
              },
              child: Card(
                color: selectedOption == option
                    ? Colors.deepOrange
                    : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: option,
                        groupValue: selectedOption,
                        onChanged: (value) {
                          onOptionSelected(value!);
                        },
                      ),
                      Text(
                        option,
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}
