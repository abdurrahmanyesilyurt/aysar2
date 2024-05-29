import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

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
  int wrongAnswers = 0;
  int questionCount = 0;
  String correctOption = '';
  int score = 0;
  String userId = '';
  String gameTitle = 'Resim Oyunu';

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    fetchGameData();
  }

  Future<void> fetchGameData() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('games')
          .get();

      List<QueryDocumentSnapshot> documents = snapshot.docs;

      if (documents.isNotEmpty) {
        Random random = Random();
        int randomIndex = random.nextInt(documents.length);
        DocumentSnapshot selectedDoc = documents[randomIndex];

        Map<String, dynamic>? data = selectedDoc.data() as Map<String, dynamic>?;

        if (data != null) {
          List<String> questionKeys = data.keys.where((key) => key.startsWith('question')).toList();

          if (questionKeys.isNotEmpty) {
            String randomQuestionKey = questionKeys[random.nextInt(questionKeys.length)];
            List<dynamic> questionData = data[randomQuestionKey];
            if (questionData.length >= 5) {
              options = List<String>.from(questionData.sublist(0, 4));
              correctOption = questionData[0];
              String imagePath = questionData[4];

              String downloadUrl = await FirebaseStorage.instance
                  .ref(imagePath)
                  .getDownloadURL();

              setState(() {
                imageUrl = downloadUrl;
                selectedOption = '';
                options.shuffle();
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
      score += 2;
      feedbackMessage = 'Doğru!';
      backgroundColor = Colors.green;
    } else {
      wrongAnswers++;
      score -= 1;
      feedbackMessage = 'Yanlış!';
      backgroundColor = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          feedbackMessage,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 1),
      ),
    );

    setState(() {
      selectedOption = option;
    });

    Future.delayed(Duration(seconds: 2), () {
      if (questionCount < 5) {
        fetchGameData();
      } else {
        updateGameStats(userId, gameTitle, correctAnswers, wrongAnswers, score);
        showGameOverDialog();
      }
    });
  }

  void showGameOverDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Oyun Bitti!", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
              "Toplam Doğru Sayısı: $correctAnswers\nToplam Yanlış Sayısı: $wrongAnswers\nToplam Puan: $score",
              style: TextStyle(fontWeight: FontWeight.w500)),
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
      barrierDismissible: false,
    );
  }

  void exitGame() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text('Resim Oyunu', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
                color: selectedOption == option ? Colors.deepOrange : Colors.white,
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
  Future<void> updateGameStats(String userId, String gameTitle, int correctAnswers, int wrongAnswers, int score) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('gameStats')
        .doc(gameTitle);

    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      int currentCorrectAnswers = data['correctAnswers'] ?? 0;
      int currentWrongAnswers = data['wrongAnswers'] ?? 0;
      int currentScore = data['score'] ?? 0;

      currentCorrectAnswers += correctAnswers;
      currentWrongAnswers += wrongAnswers;
      currentScore += score;

      await docRef.update({
        'correctAnswers': currentCorrectAnswers,
        'wrongAnswers': currentWrongAnswers,
        'score': currentScore,
      });
    } else {
      await docRef.set({
        'correctAnswers': correctAnswers,
        'wrongAnswers': wrongAnswers,
        'score': score,
      });
    }
  }

}
