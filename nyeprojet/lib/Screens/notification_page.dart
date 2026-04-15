import 'dart:async';
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
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
    timer = Timer.periodic(
      const Duration(seconds: 30),
      (Timer t) => fetchAlerts(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> fetchAlerts() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.53:5000/alerts'),
      );

      print("RAW: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _alerts = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });

        print("OK ALERTS: ${_alerts.length}");
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NyeHomePage()),
        );
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => AlertPage()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (_) => Urgence()));
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SettingsScreen()),
        );
        break;
    }
  }

  Widget _buildAlertCard(Map alert, int index) {
    String title = alert['title'] ?? "";
    String status = alert['status'] ?? "";
    String time = alert['time'] ?? "";

    Color statusColor = status.toLowerCase().contains("résol")
        ? Colors.green
        : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AlertDetailPage(alert: alert)),
        );
      },

      child: Container(
        margin: const EdgeInsets.only(bottom: 18),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          // 🔥 TU GARDE TON LED EFFECT
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
          border: Border.all(color: statusColor.withOpacity(0.8), width: 1.5),
        ),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
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

              // 👉 flèche sans changer ton design
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _alerts.isEmpty
          ? const Center(child: Text('Aucune alerte trouvée.'))
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(_alerts[index], index);
              },
            ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

// Dummy AlertDetailPage implementation
class AlertDetailPage extends StatelessWidget {
  final Map alert;

  const AlertDetailPage({Key? key, required this.alert}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(alert['title'] ?? 'Détail de l\'alerte')),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut: ${alert['status'] ?? ''}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Heure: ${alert['time'] ?? ''}',
              style: const TextStyle(fontSize: 16),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
