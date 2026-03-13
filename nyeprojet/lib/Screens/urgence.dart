import 'package:flutter/material.dart';
import 'package:nyeprojet/widgets/nav_bar.dart';

class Urgence extends StatefulWidget {
  const Urgence({super.key});

  @override
  State<Urgence> createState() => _UrgenceState();
}

class _UrgenceState extends State<Urgence> {
  int _selectedIndex = 2;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Ici tu peux naviguer vers d'autres pages si tu veux
    if (index == 0) {
      print("Notifications");
    } else if (index == 1) {
      print("Home");
    } else if (index == 2) {
      Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => const Urgence(),
    ));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),

      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: const [
            Text(
              "NYE",
              style: TextStyle(
                fontSize: 28,
                color: Color.fromARGB(255, 2, 7, 88),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "URGENCES",
              style: TextStyle(
                fontSize: 30,
                color: Color.fromARGB(255, 2, 7, 88),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 30,
          crossAxisSpacing: 30,
          childAspectRatio: 0.8,
          children: [
            urgenceBox("lib/images/police-car.png", "Police",),
            urgenceBox("lib/images/fire.png", "Pompier"),
            urgenceBox("lib/images/ambulance.png", "Ambulance"),
            urgenceBox("lib/images/lock.png", "Sécurité"),
            
          ],
        ),
      ),
      bottomNavigationBar: nav_bar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget urgenceBox(String image, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 10, 51, 140),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromARGB(255, 9, 28, 74), width: 4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            width: 70,
          ),

          SizedBox(height: 10),

          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}