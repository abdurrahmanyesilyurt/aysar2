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
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon:const Icon(Icons.person_rounded)),
        title: Text("Profil", style: Theme.of(context).textTheme.headlineMedium,),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(isDark ? Icons.sunny : Icons.nights_stay_outlined))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FutureBuilder<Map<String,dynamic>>(
                future: getUserInfo(userID!),
                builder: (context,snapshot){
                  if(snapshot.connectionState==ConnectionState.waiting){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  if(snapshot.hasError){
                    return Text("HATA : ${snapshot.error}");
                  }
                  final userInfo = snapshot.data!;
                  print("${userInfo["email"]}");
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
                      Text("${userInfo["userName"]}",style: Theme.of(context).textTheme.headlineSmall,), // Örnek kullanıcı adı
                      Text("${userInfo["email"]}",style: Theme.of(context).textTheme.headlineSmall,), // Örnek bilgi metni
                      const SizedBox(height: 20,),
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                            onPressed: (){
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
                              child: const Text("Profil Düzenle", style: TextStyle(color: Colors.white),)),
                      ),
                      const SizedBox(height: 30,),
                      const Divider(),
                      const SizedBox(height: 10,),
                      ProfileWidget(title: "Sıralama",),
                      ProfileWidget(title: "Oyun 1",),
                      ProfileWidget(title: "Oyun 2",),
                      ProfileWidget(title: "Oyun 3",),
                      ProfileWidget(title: "Oyun 4",),

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


class ProfileWidget extends StatelessWidget {
  final String title; // Parametre olarak alınan title

  const ProfileWidget({
    super.key,
    required this.title, // Bu parametre artık zorunlu

  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.blue.withOpacity(0.1),
        ),
        child: const Icon(Icons.control_point, color: Colors.blue,),
      ),
      title: Text(title,style: Theme.of(context).textTheme.bodyLarge,),
      trailing: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: const Icon(Icons.chevron_right,size: 18.0,color: Colors.grey,),
      ),
    );
  }
}