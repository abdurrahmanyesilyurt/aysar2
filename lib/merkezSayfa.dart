import 'package:aysar2/anasayfalar/oyunPage.dart';
import 'package:aysar2/anasayfalar/siralamaPage.dart';
import 'package:aysar2/profil_sayfalar/profilPage.dart';
import 'package:aysar2/sozluk_sayfalar/sozlukPage.dart';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart'; // Import animations package
class merkezSayfa extends StatefulWidget {
  @override
  _merkezSayfaState createState() => _merkezSayfaState();
}

class _merkezSayfaState extends State<merkezSayfa> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    oyunPage(),
    siralamaPage(),
    SozlukPage(),
    profilPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal, // For train-hopping-like animation
            child: child,
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: 'AnaSayfa', backgroundColor: Colors.deepOrange),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Sıralama', backgroundColor: Colors.deepPurple),
          BottomNavigationBarItem(icon: Icon(Icons.translate), label: 'Sözlük', backgroundColor: Colors.cyan),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil', backgroundColor: Colors.cyan),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.shifting,
      ),
    );
  }
}
