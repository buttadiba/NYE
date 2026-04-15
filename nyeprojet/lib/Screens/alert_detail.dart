import 'package:flutter/material.dart';

class AlertDetailPage extends StatelessWidget {
  final Map alert;

  const AlertDetailPage({super.key, required this.alert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Détails de l'alerte")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert['title'] ?? "",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text("Subtitle: ${alert['subtitle'] ?? ""}"),
            Text("Description: ${alert['description'] ?? ""}"),
            Text("Status: ${alert['status'] ?? ""}"),
            Text("Time: ${alert['time'] ?? ""}"),

            const SizedBox(height: 20),

            if (alert['photo'] != null && alert['photo'] != "")
              Image.network(
                "http://192.168.1.53:5000/uploads/${alert['photo']}",
              ),
          ],
        ),
      ),
    );
  }
}
