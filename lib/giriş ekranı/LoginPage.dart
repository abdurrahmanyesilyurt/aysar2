import 'dart:ui';
import 'package:aysar2/giri%C5%9F%20ekran%C4%B1/kayitSayfa.dart';
import 'package:aysar2/merkezSayfa.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase/auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthService _authService = AuthService();
  bool _loading = false;
  bool _obscure2Text = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedLoginInfo();
  }

  _loadSavedLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        _emailController.text = prefs.getString('email') ?? '';
        _passwordController.text = prefs.getString('password') ?? '';
      } else {
        _emailController.clear();
        _passwordController.clear();
      }
    });
  }

  _saveLoginInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      prefs.setString('email', _emailController.text);
      prefs.setString('password', _passwordController.text);
      prefs.setBool('rememberMe', true);
    } else {
      prefs.remove('email');
      prefs.remove('password');
      prefs.setBool('rememberMe', false);
    }
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
                        Image.asset('resimler/aysarlogo.jpeg', height: yukseklik/10),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Checkbox(
                              activeColor: Colors.black,
                              value: _rememberMe,
                              onChanged: (bool? value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                            ),
                            Text('Beni Hatırla',style: TextStyle(fontSize: genislik/27),),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _loading ? null : _signIn,
                          child: _loading
                              ? CircularProgressIndicator(color: Colors.white,)
                              : Text('Giriş Yap',style: TextStyle(color: Colors.black,fontSize: genislik/30),),
                        ),
                        SizedBox(
                            height: yukseklik/40
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => kayitSayfa()));
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: yukseklik/1000,
                                width: genislik/5,
                                color: Colors.black,
                              ),
                              Text(
                                "Kayıt ol",
                                style: TextStyle(color: Colors.black,fontSize: genislik/20),
                              ),
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

  Future<bool> _onBackPressed() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Merlab uygulamasından çıkmak istiyor musunuz?',style: TextStyle(fontSize: 16),),
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

  void _signIn() async {
    _saveLoginInfo();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });
      String email = _emailController.text.trim();
      String password = _passwordController.text.trim();

      try {
        await _authService.signIn(email, password);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => merkezSayfa()),
        );


      } catch (e) {
        print('Hata: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kullanıcı adı veya şifre hatalı'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _loading = false;
      });
    }
  }

}
