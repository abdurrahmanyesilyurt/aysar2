import 'package:flutter/material.dart';

class Game3 extends StatefulWidget {
  const Game3({super.key});

  @override
  State<Game3> createState() => _Game3State();
}

class _Game3State extends State<Game3> {
  String selectedOption = '';

  void selectOption(String option) {
    setState(() {
      selectedOption = option;
    });

    // Cevap kontrolü ve kullanıcıya bildirim
    if (option == 'CorrectOption') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Doğru!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Yanlış!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        title: Text('Kelime Oyunu',style: TextStyle(fontWeight: FontWeight.bold),),
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
                        'resimler/bulut.jpeg', // Fotoğrafı buraya ekleyin
                        fit: BoxFit.fill  ,
                      ),
                      Container(
                        alignment: Alignment(0.0, -0.5), // Yazıyı üst-orta hizalar
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Text(
                            'Bu cümleyi buraya yazın', // Cümle buraya gelecek
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
            ...['Option 1', 'Option 2', 'Option 3', 'CorrectOption'].map((option) => OptionButton(
              option: option,
              isSelected: selectedOption == option,
              onTap: () => selectOption(option),
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
