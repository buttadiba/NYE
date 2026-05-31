import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AlertDetailPage extends StatefulWidget {
  final Map alert;

  const AlertDetailPage({super.key, required this.alert});

  @override
  State<AlertDetailPage> createState() => _AlertDetailPageState();
}

class _AlertDetailPageState extends State<AlertDetailPage> {
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    // Initialiser le statut sélectionné en fonction de l'alerte

    final rawStatus = widget.alert['status'] ?? "attente";

    if (rawStatus == "Résolue" || rawStatus == "resolved") {
      selectedStatus = "resolved";
    } else if (rawStatus == "En cours" || rawStatus == "en_cours") {
      selectedStatus = "en_cours";
    } else {
      selectedStatus = "attente";
    }
  }

  Future<void> updateStatus(String newStatus) async {
    try {
      final response = await http.put(
        Uri.parse(
          "http://192.168.1.112:5000/alerts/${widget.alert['alert_id']}",
        ),
        // headers et body pour la mise à jour du statut
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": newStatus}),
      );

      if (response.statusCode == 200) {
        setState(() {
          selectedStatus = newStatus;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Statut mis à jour")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Erreur mise à jour")));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String imageUrl =
        "http://192.168.1.112:5000/uploads/${widget.alert['photo']}";

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          //  APP BAR AVEC IMAGE (si disponible) le TITRE  et un badge de statut
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            iconTheme: const IconThemeData(color: Colors.white),

            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.alert['title'] ?? "Alerte",
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.black54,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              // background de l'appbar : image si dispo, sinon couleur unie
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.alert['photo'] != null &&
                      widget.alert['photo'] != "")
                    Image.network(imageUrl, fit: BoxFit.cover)
                  else
                    Container(color: const Color.fromARGB(255, 1, 5, 72)),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///  STATUS BADGE (style actuel + dynamique)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: selectedStatus == "resolved"
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      selectedStatus,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// DROPDOWN POUR CHANGER LE STATUT (avec appel API pour mise à jour)
                  /// liste des status : attente, en_cours, resolved
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: InputDecoration(
                      labelText: "Changer statut",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: ["attente", "en_cours", "resolved"]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        updateStatus(value);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION CARD
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.alert['description'] ?? "",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// INFOS CARD
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            Icons.info,
                            "Détails",
                            widget.alert['subtitle'] ?? "",
                          ),
                          const Divider(),
                          _buildInfoRow(
                            Icons.access_time,
                            "Heure",
                            widget.alert['time'] ?? "",
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 6, 2, 88)),
        const SizedBox(width: 10),
        Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }
}
