<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:nyeprojet/Screens/home.dart';
import 'package:nyeprojet/Screens/settings_screen.dart';
import 'package:nyeprojet/widgets/nav_bar.dart';
import 'urgence.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const NYEApp());

class NYEApp extends StatelessWidget {
  const NYEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AlertPage(),
    );
  }
}

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  int _selectedIndex = 1;

  List<dynamic> _alerts = [];
  bool isLoading = true;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => NyeHomePage()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AlertPage()));
        break;
      case 2:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => Urgence()));
        break;
      case 3:
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => SettingsScreen()));
        break;
    }
  }

  Future<void> fetchAlerts() async {
    var url = Uri.parse("http://192.168.1.17:5000/alerts");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _alerts = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ALERTES",
          style: TextStyle(
            fontSize: 28,
            color: Color.fromARGB(255, 2, 38, 92),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                return _buildAlertCard(alert, index);
              },
            ),

      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildAlertCard(Map alert, int index) {
    String title = alert['title'] ?? "Alerte";
    String time = alert['time'] ?? "";

    // status (si backend ne donne pas, on simule)
    String status = alert['status'] ?? "En attente";

    Color statusColor;
    if (status.toLowerCase().contains("résol")) {
      statusColor = Colors.green;
    } else {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        // 🔥 LED GLOW EFFECT
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.6),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],

        color: Colors.white,
        border: Border.all(
          color: statusColor.withOpacity(0.8),
          width: 1.5,
        ),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Row(
          children: [
            // 🔴 ICON STATUS
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor.withOpacity(0.15),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: statusColor,
                size: 30,
              ),
            ),

            const SizedBox(width: 15),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "📱 Intrusion détectée à $time",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
=======
import 'package:flutter/material.dart';
import 'package:nyeprojet/Screens/home.dart';
import 'package:nyeprojet/Screens/settings_screen.dart';
import 'package:nyeprojet/widgets/nav_bar.dart';
import 'urgence.dart'; //  page Urgence

void main() => runApp(const NYEApp());

class NYEApp extends StatelessWidget {
  const NYEApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const AlertPage(),
    );
  }
}

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => _AlertPageState();
}

class _AlertPageState extends State<AlertPage> {
  int _selectedIndex = 1; // Pour la nav bar

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
  final List<Map<String, dynamic>> _alerts = [
    {
      "title": "Intrusion détectée",
      "place": "Salle du personnel",
      "time": "Il y a 10 minutes",
      "color": const Color(0xFFE64A19),
    },
    {
      "title": "Perte de connexion",
      "place": "Caméra Accueil",
      "time": "Il y a 45 minutes",
      "color": const Color(0xFFF57C00),
    },
    {
      "title": "Mouvement détecté",
      "place": "Vitrine avant",
      "time": "Il y a 2 heures",
      "color": const Color(0xFF1976D2),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ALERTES",
          style: TextStyle(
            fontSize: 28,
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [const SizedBox(width: 48)],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        itemCount: _alerts.length,
        itemBuilder: (context, index) {
          final alert = _alerts[index];

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 400 + (index * 150)),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildAlertCard(alert, index),
          );
        },
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert, int index) {
    return Dismissible(
      key: Key(alert['title'] + index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() => _alerts.removeAt(index));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${alert['title']} supprimée"),
            action: SnackBarAction(label: "Annuler", onPressed: () {}),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: alert['color'].withOpacity(0.5), width: 2),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () {
              print("Détails pour : ${alert['title']}");
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(Icons.notifications_active, color: Colors.black, size: 28),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert["title"],
                          style: TextStyle(
                            color: alert["color"],
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alert["place"],
                          style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "* ${alert["time"]}",
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
>>>>>>> b0c0c1f50e88b73fc3d29c8411c00a205be0ef7f
}