  import 'package:aysar2/profil_sayfalar/profilEditPage.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';


  class profilPage extends StatelessWidget {
    const profilPage({super.key});

    Future<Map<String, dynamic>> getUserInfo(String userId) async {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return doc.data() ?? {}; // Doküman varsa veriyi, yoksa boş bir map döndür.
    }
    @override
    Widget build(BuildContext context) {
      final userID=FirebaseAuth.instance.currentUser?.uid;
      var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
      return Scaffold(
        backgroundColor: Colors.blueGrey,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey,
          leading: IconButton(onPressed: (){}, icon:const Icon(Icons.person_rounded)),
          title: Text(
            "Profil",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),        actions: [
            IconButton(onPressed: (){}, icon: Icon(isDark ? Icons.sunny : Icons.nights_stay_outlined))
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: getUserInfo(userID!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(),);
                    }
                    if (snapshot.hasError) {
                      return Text("HATA : ${snapshot.error}");
                    }
                    final userInfo = snapshot.data!;
                    return Column(
                      children: [
                        SizedBox(
                          width: 120, height: 120,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: userInfo["photoUrl"] != null && userInfo["photoUrl"].isNotEmpty
                                ? Image.network(userInfo["photoUrl"], fit: BoxFit.cover)
                                : Image.asset('resimler/aysarlogo.png', fit: BoxFit.cover), // Varsayılan profil resmi
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("${userInfo["userName"]}",style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),), // Örnek kullanıcı adı
                        Text("${userInfo["email"]}",style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),), // Örnek bilgi metni
                        const SizedBox(height: 20,),
                        SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ProfileEditPage(
                                  currentUserName: userInfo['userName'] ?? '',
                                  currentEmail: userInfo['email'] ?? '',
                                  currentSifre: userInfo['sifre'],
                                  currentPhotoUrl: userInfo['photoUrl'] ?? '',
                                )),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                            child: const Text("Profil Düzenle", style: TextStyle(color: Colors.white),),
                          ),
                        ),
                        const SizedBox(height: 30,),
                        const Divider(),
                        const SizedBox(height: 10,),
                        ProfileWidget(title: "Resim Oyunu", userId: userID),
                        ProfileWidget(title: "Video Oyunu", userId: userID),
                        ProfileWidget(title: "Kelime Oyunu", userId: userID),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
  Future<Map<String, dynamic>> getGameStats(String userId, String gameTitle) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).collection('gameStats').doc(gameTitle).get();
    return doc.data() ?? {};
  }



  class ProfileWidget extends StatelessWidget {
    final String title; // Parametre olarak alınan title
    final String userId; // Kullanıcı ID'si

    const ProfileWidget({
      super.key,
      required this.title, // Bu parametre artık zorunlu
      required this.userId, // Kullanıcı ID'si de zorunlu
    });

    @override
    Widget build(BuildContext context) {
      return ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.blue.withOpacity(0.1),
          ),
          child: const Icon(Icons.control_point, color: Colors.white,),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),),
        trailing: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: const Icon(Icons.chevron_right, size: 18.0, color: Colors.grey,),
        ),
        children: <Widget>[
          FutureBuilder<Map<String, dynamic>>(
            future: getGameStats(userId, title),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text("HATA: ${snapshot.error}");
              }
              final gameStats = snapshot.data ?? {};
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Doğru Sayısı: ${gameStats['correctAnswers'] ?? 'Veri yok'}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text("Yanlış Sayısı: ${gameStats['wrongAnswers'] ?? 'Veri yok'}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    const SizedBox(height: 5),
                    Text("Puanı: ${gameStats['score'] ?? 'Veri yok'}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
                  ],
                ),
              );
            },
          ),
        ],
      );
    }
  }
