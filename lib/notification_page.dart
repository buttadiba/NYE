import 'package:flutter/material.dart';

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
  // Liste de données mutable pour l'interactivité
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.menu, color: Colors.grey),
        title: const Text(
          "NYE",
          style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        centerTitle: true,
        actions: [const SizedBox(width: 48)], // Pour centrer parfaitement le titre
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text(
              "ALERTES",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D47A1),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                
                // Animation simple d'entrée (Slide + Fade)
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
          ),
        ],
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
          SnackBar(content: Text("${alert['title']} supprimée"), action: SnackBarAction(label: "Annuler", onPressed: (){})),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(25)),
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
              // Action dynamique au clic
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
                          style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "* ${alert["time"]}",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
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
}