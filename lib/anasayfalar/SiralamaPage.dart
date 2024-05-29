import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SiralamaPage extends StatefulWidget {
  @override
  _SiralamaPageState createState() => _SiralamaPageState();
}

class _SiralamaPageState extends State<SiralamaPage> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
    });

    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance.collection('users').get();
      List<QueryDocumentSnapshot> userDocuments = userSnapshot.docs;

      if (userDocuments.isNotEmpty) {
        List<User> fetchedUsers = [];
        for (var userDoc in userDocuments) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          String userId = userDoc.id;

          // Game stats for each game
          int game1Score = await getGameScore(userId, 'Resim Oyunu');
          int game2Score = await getGameScore(userId, 'Video Oyunu');
          int game3Score = await getGameScore(userId, 'Kelime Oyunu');

          fetchedUsers.add(User(
            name: userData['userName'] ?? 'Unknown',
            game1Score: game1Score,
            game2Score: game2Score,
            game3Score: game3Score,
            imageUrl: userData['photoUrl'] ?? 'https://via.placeholder.com/150',
          ));
        }

        // Kullanıcıları toplam puanlarına göre sıralıyoruz
        fetchedUsers.sort((a, b) => b.totalScore.compareTo(a.totalScore));
        setState(() {
          users = fetchedUsers;
        });
      }
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<int> getGameScore(String userId, String gameTitle) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('gameStats')
          .doc(gameTitle)
          .get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['score'] ?? 0;
      }
    } catch (e) {
      print('Error fetching game score for $userId and $gameTitle: $e');
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
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
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            if (users.isNotEmpty) buildTopUsers(),
            Expanded(child: buildOtherUsers()),
          ],
        ),
      ),
    );
  }

  Widget buildTopUsers() {
    return Column(
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
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Total: ${users[0].totalScore}',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        // 2. ve 3. kullanıcılar
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (users.length > 1) buildTopUserCard(users[1], Colors.grey),
            if (users.length > 2) buildTopUserCard(users[2], Colors.brown),
          ],
        ),
      ],
    );
  }

  Widget buildTopUserCard(User user, Color color) {
    return Container(
      width: 140,
      height: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(user.imageUrl),
          ),
          SizedBox(height: 8),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'Total: ${user.totalScore}',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget buildOtherUsers() {
    return ListView.builder(
      itemCount: users.length > 3 ? users.length - 3 : 0,
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
