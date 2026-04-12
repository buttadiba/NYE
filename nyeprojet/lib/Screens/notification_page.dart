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
}