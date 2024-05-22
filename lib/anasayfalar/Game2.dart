import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math';

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
  int questionCount = 0;
  String correctOption = '';
  VideoPlayerController? _controller;

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
          .collection('games2')
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
              String videoPath = questionData[4]; // 5. eleman video yolu

              // Firebase Storage'dan indirme URL'sini al
              String downloadUrl = await FirebaseStorage.instance
                  .ref(videoPath)
                  .getDownloadURL();

              setState(() {
                videoUrl = downloadUrl;
                selectedOption = '';
                options.shuffle(); // Seçenekleri karıştır
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
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text('Video Oyunu',style: TextStyle(fontWeight: FontWeight.bold),),
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
