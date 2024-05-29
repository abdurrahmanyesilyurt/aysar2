import 'package:flutter/material.dart';

class SiralamaPage extends StatelessWidget {
  final List<User> users = [
    User(name: 'Alice', game1Score: 90, game2Score: 85, game3Score: 88, imageUrl: 'https://via.placeholder.com/150'),
    User(name: 'Bob', game1Score: 75, game2Score: 80, game3Score: 70, imageUrl: 'https://via.placeholder.com/150'),
    User(name: 'Charlie', game1Score: 95, game2Score: 92, game3Score: 90, imageUrl: 'https://via.placeholder.com/150'),
    User(name: 'David', game1Score: 60, game2Score: 65, game3Score: 70, imageUrl: 'https://via.placeholder.com/150'),
    User(name: 'Eve', game1Score: 70, game2Score: 75, game3Score: 80, imageUrl: 'https://via.placeholder.com/150'),
  ];

  @override
  Widget build(BuildContext context) {
    // Kullanıcıları toplam puanlarına göre sıralıyoruz
    users.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(
        title: Text(
          'SIRALAMA',
          style: TextStyle(color: Colors.white), // Yazı rengi
        ),
        backgroundColor: Colors.deepPurple, // Arka plan rengi
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 1. kullanıcı
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(users[0].imageUrl),
                    ),
                    SizedBox(height: 8),
                    Text(
                      users[0].name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                    Text(
                      'Total: ${users[0].totalScore}',
                      style: TextStyle(fontSize: 16,color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            // 2. ve 3. kullanıcılar
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(users[1].imageUrl),
                      ),
                      SizedBox(height: 8),
                      Text(
                        users[1].name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total: ${users[1].totalScore}',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 130,
                  height: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.brown,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(users[2].imageUrl),
                      ),
                      SizedBox(height: 8),
                      Text(
                        users[2].name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Total: ${users[2].totalScore}',
                        style: TextStyle(fontSize: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Diğer kullanıcılar
            Expanded(
              child: ListView.builder(
                itemCount: users.length - 3,
                itemBuilder: (context, index) {
                  final user = users[index + 3];
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(user.imageUrl),
                      ),
                      title: Text(user.name),
                      trailing: Text('Total: ${user.totalScore}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  String name;
  int game1Score;
  int game2Score;
  int game3Score;
  int totalScore;
  String imageUrl; // Resim URL'si

  User({
    required this.name,
    required this.game1Score,
    required this.game2Score,
    required this.game3Score,
    required this.imageUrl, // Resim URL'si parametresi
  }) : totalScore = game1Score + game2Score + game3Score;
}
