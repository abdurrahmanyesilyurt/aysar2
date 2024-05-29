import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Game3 extends StatefulWidget {
  const Game3({super.key});

  @override
  State<Game3> createState() => _Game3State();
}

class _Game3State extends State<Game3> {
  String selectedOption = '';
  List<String> options = [];
  bool isLoading = false;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int questionCount = 0;
  String correctOption = '';
  String question = '';
  String userId = '';
  String gameTitle = 'Kelime Oyunu';
  int score = 0;

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
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('games3').get();
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
              question = questionData[4];

              setState(() {
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
        if (questionCount >= 5) {
          updateGameStats(userId, gameTitle, correctAnswers, wrongAnswers, score);
          showResultDialog(); // 5. sorudan sonra sonucu göster
        }
      });
    }
  }

  void selectOption(String option) {
    setState(() {
      selectedOption = option;
    });

    if (option == correctOption) {
      correctAnswers++;
      score += 2; // Doğru cevap için 2 puan ekle
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doğru!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      wrongAnswers++;
      score -= 1; // Yanlış cevap için 1 puan çıkar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yanlış!'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (questionCount < 5) {
      fetchGameData(); // Yeni soru getir
    }
  }

  void showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oyun Bitti'),
          content: Text('Toplam doğru cevap sayınız: $correctAnswers\nToplam yanlış cevap sayınız: $wrongAnswers\nToplam puanınız: $score'),
          actions: [
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop(); // Dialogu kapat
                Navigator.of(context).pop(); // Oyundan çık
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text(
          'Kelime Oyunu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'resimler/bulut.jpeg',
                        fit: BoxFit.fill,
                      ),
                      Container(
                        alignment: Alignment(0.0, -0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            question,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ...options.map((option) => OptionButton(
              option: option,
              isSelected: selectedOption == option,
              onTap: () => selectOption(option),
            )).toList(),
          ],
        ),
      ),
    );
  }
  Future<Map<String, dynamic>> getGameStats(String userId, String gameTitle) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('gameStats')
        .doc(gameTitle)
        .get();
    return doc.data() ?? {};
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

class OptionButton extends StatelessWidget {
  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  OptionButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepOrange[100] : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.deepOrange : Colors.grey,
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                option,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.deepOrange : Colors.black,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
