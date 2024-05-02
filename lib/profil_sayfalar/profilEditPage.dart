import 'dart:io';
import 'dart:ui';

import 'package:aysar2/profil_sayfalar/profilPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEditPage extends StatefulWidget {
  final String currentUserName;
  final String currentEmail;
  final String currentPhotoUrl;
  final String currentSifre;


  const ProfileEditPage({
    Key? key,
    required this.currentUserName,
    required this.currentEmail,
    required this.currentSifre,
    this.currentPhotoUrl = '',
  }) : super(key: key);

  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final userID=FirebaseAuth.instance.currentUser?.uid;
  late TextEditingController _userNameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscure2Text = true;
  final _formKey = GlobalKey<FormState>();
  String? _profilePhotoUrl; // Kullanıcının profil fotoğrafı URL'si için yeni bir durum değişkeni

  Future<XFile?> pickImageFromCamera() async {
    final imagePicker = ImagePicker();
    final XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    return pickedFile;
  }
  Future<String?> uploadImageToFirebase(XFile? imageFile) async {
    if (imageFile == null) return null;

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child("profileImages/$userID.jpg");
    UploadTask uploadTask = ref.putFile(File(imageFile.path));

    await uploadTask;
    String downloadUrl = await ref.getDownloadURL();
    return downloadUrl;
  }
  Future<void> updateUserProfilePhoto(String photoUrl) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'photoUrl': photoUrl,
    });

  }
  Future<void> updateEmailAndPassword(String newEmail, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // E-postayı güncelle
      await user.verifyBeforeUpdateEmail(newEmail).catchError((error) {
        print("E-posta güncellenirken hata: $error");
      });

      // Şifreyi güncelle
      await user.updatePassword(newPassword).catchError((error) {
        // Hata yönetimi
        print("Şifre güncellenirken hata: $error");
      });
    }
  }

  Future<void> updateUserNameAndPhoto(String userId, String email,String sifre,String userName) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'email': email,
      'sifre': sifre,
      'userName': userName,
    }).catchError((error) {
      // Hata yönetimi
      print("Firestore güncellenirken hata: $error");
    });
  }
  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.currentUserName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _passwordController = TextEditingController(text: widget.currentSifre); // Şifre için başlangıçta boş bir kontrolcü
    _profilePhotoUrl = widget.currentPhotoUrl; // Başlangıçta geçerli fotoğraf URL'sini kullan

  }
  Future<bool> _onBackPressed() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Kaydetmeden Çıkmak İstiyor Musunuz?',style: TextStyle(fontSize: 16),),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Hayır',style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Evet',style: TextStyle(color: Colors.black),),
          ),
        ],
      ),
    ) ?? false;
  }
  @override
  void dispose() {
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double genislik = MediaQuery.of(context).size.width;
    double yukseklik = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('resimler/arkaplan.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                constraints: BoxConstraints.expand(),
              ),
            ),
            Center(
              child: Container(
                margin: EdgeInsets.all(yukseklik/54),
                padding: EdgeInsets.all(yukseklik/54),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(yukseklik/54),
                  gradient: LinearGradient(
                    colors: [Colors.white, Colors.white],
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () async {
                            XFile? imageFile = await pickImageFromCamera();
                            String? photoUrl = await uploadImageToFirebase(imageFile);
                            if (photoUrl != null) {
                              await updateUserProfilePhoto(photoUrl);
                              setState(() {
                                _profilePhotoUrl = photoUrl; // Profil fotoğrafı URL'sini güncelle
                              });
                            }
                          },
                          child: SizedBox(
                            width: 100, height: 300,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              // Yeni profil fotoğrafını veya varsayılanı göster
                              child: _profilePhotoUrl != null && _profilePhotoUrl!.isNotEmpty
                                  ? Image.network(_profilePhotoUrl!, fit: BoxFit.cover)
                                  : Image.asset('resimler/aysarlogo.jpeg', fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        SizedBox(height: yukseklik/50),
                        TextFormField(
                          controller: _userNameController,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            labelText: 'Kullanıcı Adı',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(yukseklik/50),
                            ),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Kullanıcı Adı boş olamaz';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: yukseklik/50),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'E-posta',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(yukseklik/50),
                            ),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'E-posta boş olamaz';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: yukseklik/50),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscure2Text,
                          decoration: InputDecoration(
                            labelText: 'Şifre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure2Text ? Icons.visibility : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscure2Text = !_obscure2Text;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Şifre boş olamaz';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height:yukseklik/100),

                        SizedBox(
                            height: yukseklik/40
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => profilPage()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: yukseklik/1000,
                                width: genislik/5,
                                color: Colors.black,
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                 if (_formKey.currentState!.validate()) {
                                        await updateEmailAndPassword(_emailController.text, _passwordController.text);
                                        await updateUserNameAndPhoto(FirebaseAuth.instance.currentUser!.uid,_emailController.text,_passwordController.text,_userNameController.text);

                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profil güncellendi')));
                                        Navigator.pop(context);
                                        }
                                        },

                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue, side: BorderSide.none, shape: const StadiumBorder()),
                                  child: const Text("KAYDET", style: TextStyle(color: Colors.white),)),


                              Container(
                                height: yukseklik/1000,
                                width: genislik/5,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
