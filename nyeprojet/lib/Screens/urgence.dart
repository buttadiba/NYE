import 'package:flutter/material.dart';
import 'package:nyeprojet/Screens/home.dart';
import 'package:nyeprojet/Screens/notification_page.dart';
import 'package:nyeprojet/Screens/settings_screen.dart';
import 'package:nyeprojet/widgets/nav_bar.dart';
import 'emergency-page.dart';

class Urgence extends StatefulWidget {
  const Urgence({super.key});

  @override
  State<Urgence> createState() => _UrgenceState();
}

class _UrgenceState extends State<Urgence> {
  int _selectedIndex = 2; // Pour la nav bar

  void _onItemTapped(int index) {
  setState(() {
    _selectedIndex = index;
  });

  switch(index) {
    case 0:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  NyeHomePage()),
        );
      break;
    case 1:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  AlertPage()),
        );
      break;
    case 2:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) =>  Urgence())
        );
      break;
    case 3:
      Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SettingsScreen())
        );
      break;
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = 20;
    double spacing = 20;
    int columns = 2;

    // Largeur des containers
    double totalSpacing = padding * 2 + spacing * (columns - 1);
    double boxWidth = (screenWidth - totalSpacing) / columns;

    // Hauteur un peu plus grande que largeur (ratio)
    double boxHeight = boxWidth * 1.5;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 238, 238),
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "URGENCES",
          style: TextStyle(
            fontSize: 30,
            color: Color.fromARGB(255, 2, 7, 88),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: boxWidth / boxHeight,
          ),
          children: [
            urgenceBox("lib/images/police-car.png", "Police", () {
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmergencyPage(type: "police"),
              ),
            );
            }, boxWidth, boxHeight),
            urgenceBox("lib/images/fire.png", "Pompier", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyPage(type: "Pompier")),
              );
            }, boxWidth, boxHeight),
            urgenceBox("lib/images/ambulance.png", "Ambulance", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyPage(type: "Ambulance")),
              );
            }, boxWidth, boxHeight),
            urgenceBox("lib/images/lock.png", "Sécurité", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EmergencyPage(type: "protection civile")),
              );
            }, boxWidth, boxHeight),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget urgenceBox(String image, String title, VoidCallback onTap, double width, double height) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 51, 140),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(255, 9, 28, 74), width: 4),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              image,
              width: 70,
              height: 70,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}