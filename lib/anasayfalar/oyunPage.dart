import 'package:flutter/material.dart';


class oyunPage extends StatelessWidget {
  const oyunPage({super.key});

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon:const Icon(Icons.person_rounded)),
        title: Text("Oyun Sayfasi", style: Theme.of(context).textTheme.headlineLarge,),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(isDark ? Icons.sunny : Icons.nights_stay_outlined))
        ],
      ),
      body: Center(
        child: Text("Oyun Sayfasi"),
      ),
    );
  }
}
