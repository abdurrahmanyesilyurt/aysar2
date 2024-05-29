import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class Game2 extends StatefulWidget {
  @override
  _Game2State createState() => _Game2State();
}

class _Game2State extends State<Game2> {
  String selectedOption = '';
  String videoUrl = '';
  List<String> options = [];
  bool isLoading = false;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  int questionCount = 0;
  String correctOption = '';
  VideoPlayerController? _controller;
  String userId = '';
  String gameTitle = 'Video Oyunu';
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
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('games2')
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
              String videoPath = questionData[4];

              String downloadUrl = await FirebaseStorage.instance
                  .ref(videoPath)
                  .getDownloadURL();

              setState(() {
                videoUrl = downloadUrl;
                selectedOption = '';
                options.shuffle();
                _controller?.dispose();
                _controller = VideoPlayerController.network(videoUrl)
                  ..initialize().then((_) {
                    setState(() {});
                    _controller!.play();
                  });
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
      score += 4; // Doğru cevap için 2 puan ekle
      feedbackMessage = 'Doğru!';
      backgroundColor = Colors.green;
    } else {
      wrongAnswers++;
      score -= 2; // Yanlış cevap için 1 puan çıkar
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text('Video Oyunu', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: _controller != null && _controller!.value.isInitialized
                      ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                      : Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Bu nedir?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            SizedBox(height: 20),
            ...options.map((option) => OptionButton(
              option: option,
              isSelected: selectedOption == option,
              onTap: () => onOptionSelected(option),
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
