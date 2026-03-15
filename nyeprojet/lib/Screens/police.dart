import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Police extends StatefulWidget {
  const Police({super.key});

  @override
  State<Police> createState() => _PoliceState();
}

class _PoliceState extends State<Police> {

  // Position actuelle de l'utilisateur
  LatLng? userLocation;

  // Position sélectionnée sur la carte (marqueur rouge)
  LatLng? selectedLocation;

  // Numéro de téléphone de la police
  final String policePhoneNumber = "80001115";

  // Controller pour la barre de recherche
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserLocation(); // récupérer la position au démarrage
  }

  /// Fonction pour récupérer la position GPS de l'utilisateur
  Future<void> getUserLocation() async {

    // Demande de permission pour accéder à la localisation
    LocationPermission permission = await Geolocator.requestPermission();

    // Récupérer la position actuelle
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Mettre à jour les variables
    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      selectedLocation = userLocation; // par défaut le marqueur est sur la position actuelle
    });
  }

  /// Fonction pour rechercher une adresse via OpenStreetMap Nominatim
  Future<void> searchAddress(String address) async {

    try {

      // Construire l'URL pour la requête Nominatim
      final url = Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$address&format=json");

      final response = await http.get(url);

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        if (data.isNotEmpty) {

          // Récupérer la première localisation correspondante
          double lat = double.parse(data[0]["lat"]);
          double lon = double.parse(data[0]["lon"]);

          setState(() {
            selectedLocation = LatLng(lat, lon); // déplacer le marqueur
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Adresse non trouvée")),
          );
        }

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur serveur")),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur lors de la recherche")),
      );
    }
  }

  /// Fonction pour appeler la police
  void callPolice() async {

    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: policePhoneNumber,
    );

    await launchUrl(phoneUri);
  }

  /// Fonction pour envoyer la localisation par SMS
  void sendLocation() async {

    if(selectedLocation != null){

      // Création du lien Google Maps avec latitude et longitude
      String link =
          "https://www.google.com/maps?q=${selectedLocation!.latitude},${selectedLocation!.longitude}";

      final Uri smsUri = Uri(
        scheme: 'sms',
        queryParameters: {
          'body': 'Ma localisation: $link'
        },
      );

      await launchUrl(smsUri);
    }
  }

  @override
  Widget build(BuildContext context) {

    // Si la localisation n'est pas encore récupérée
    if(userLocation == null){
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Urgence",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 4, 4, 96),
      ),

      body: Stack(
        children: [

          /// Carte interactive
          FlutterMap(

            options: MapOptions(
              initialCenter: userLocation!,
              initialZoom: 15,

              /// Cliquer sur la carte pour déplacer le marqueur
              onTap: (tapPosition, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),

            children: [

              /// Couche OpenStreetMap
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.app',
              ),

              /// Marqueur
              MarkerLayer(
                markers: [
                  Marker(
                    point: selectedLocation!,
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  )
                ],
              )
            ],
          ),

          /// Barre de recherche d'adresse
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: TextField(

              controller: searchController,

              decoration: InputDecoration(
                hintText: "Rechercher un lieu ou une adresse",
                filled: true,
                fillColor: Colors.white,

                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),

                  onPressed: () {
                    searchAddress(searchController.text);
                  },
                ),
              ),
            ),
          ),

          /// Bouton envoyer localisation par SMS
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(

              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),

              onPressed: sendLocation,

              child: const Text(
                "Envoyer la localisation",
                style: TextStyle(fontSize: 16,color: Colors.white),
              ),
            ),
          ),

          /// le Bouton pour appeler la police
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 9, 34, 146),
              onPressed: callPolice,
              child: const Icon(Icons.call),
            ),
          )

        ],
      ),
    );
  }
}