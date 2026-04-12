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
  LatLng? userLocation;
  LatLng? selectedLocation;

  final String policePhoneNumber = "80001115";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  // Récupère la position GPS de l'utilisateur
  Future<void> getUserLocation() async {
<<<<<<< HEAD
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      print("Permission refusée définitivement");
      return;
    }

=======
    await Geolocator.requestPermission();
>>>>>>> b0c0c1f50e88b73fc3d29c8411c00a205be0ef7f
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      selectedLocation = userLocation;
    });
  }

  // Recherche d'adresse via Nominatim
  Future<void> searchAddress(String address) async {
    try {
      final url = Uri.parse(
          "https://nominatim.openstreetmap.org/search?q=$address&format=json");
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.nyeprojet',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]["lat"]);
          double lon = double.parse(data[0]["lon"]);
          setState(() {
            selectedLocation = LatLng(lat, lon);
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

  // Appel de la police
  void callPolice() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: policePhoneNumber);
    await launchUrl(phoneUri);
  }

  // Envoyer la localisation par SMS
  void sendLocation() async {
    if (selectedLocation != null) {
      String link =
          "https://www.google.com/maps?q=${selectedLocation!.latitude},${selectedLocation!.longitude}";
      final Uri smsUri = Uri(
        scheme: 'sms',
        queryParameters: {'body': 'Ma localisation: $link'},
      );
      await launchUrl(smsUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userLocation == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Urgence"),
        backgroundColor: const Color.fromARGB(255, 4, 4, 96),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
<<<<<<< HEAD
              initialCenter: userLocation!,
              initialZoom: 15,
=======
              center: userLocation!,
              zoom: 15,
>>>>>>> b0c0c1f50e88b73fc3d29c8411c00a205be0ef7f
              onTap: (tap, point) {
                setState(() {
                  selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.nyeprojet',
              ),
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
                  ),
                ],
              ),
            ],
          ),

          // Barre de recherche
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
                  onPressed: () => searchAddress(searchController.text),
                ),
              ),
            ),
          ),

          // Bouton envoyer localisation
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              onPressed: sendLocation,
              child: const Text(
                "Envoyer la localisation",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),

          // Bouton appeler police
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(255, 9, 34, 146),
              onPressed: callPolice,
              child: const Icon(Icons.call),
            ),
          ),
        ],
      ),
    );
  }
}