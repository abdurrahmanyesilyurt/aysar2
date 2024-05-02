import 'package:flutter/material.dart';


class siralamaPage extends StatelessWidget {
  const siralamaPage({super.key});

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){}, icon:const Icon(Icons.person_rounded)),
        title: Text("Sıralama Sayfasi", style: Theme.of(context).textTheme.headlineLarge,),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(isDark ? Icons.sunny : Icons.nights_stay_outlined))
        ],
      ),
      body: Center(
        child: Text("Siralama Sayfasi"),
      ),
    );
  }}


class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
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
      title: Text("Sıralamanız",style: Theme.of(context).textTheme.bodyLarge,),
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