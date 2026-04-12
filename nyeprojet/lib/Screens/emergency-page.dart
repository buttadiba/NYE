import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmergencyPage extends StatefulWidget {
  final String type;

  const EmergencyPage({super.key, required this.type});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final MapController mapController = MapController();
  List suggestions = [];
  LatLng? currentLocation;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
    Future.delayed(Duration(milliseconds: 500), () {
      mapController.move(currentLocation!, 15);
    });
    
  }
  void selectLocation(dynamic place) {
    final lat = double.parse(place["lat"]);
    final lon = double.parse(place["lon"]);

    setState(() {
      currentLocation = LatLng(lat, lon);
      suggestions = [];
    });

    mapController.move(LatLng(lat, lon), 15);
  }

  Future<void> sendEmergency() async {
    var url = Uri.parse("http://192.168.1.17:5000/emergency");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "type": widget.type,
        "lat": currentLocation!.latitude,
        "lng": currentLocation!.longitude,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Urgence envoyée 🚨")),
    );
  }
  void saveLocation(LatLng point) async {
    var url = Uri.parse("http://192.168.1.17:5000/location");

    await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "lat": point.latitude,
        "lng": point.longitude,
      }),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📍 Localisation enregistrée")),
    );
  }

  void callEmergency() async {
    final Map<String, String> numbers = {
      "police": "80001125",
      "ambulance": "76291470",
      "pompier": "20228081",
      "protection civile": "20239511",
    };

    // appel aux agences de securite selon le type d'urgence
    String key = widget.type.toLowerCase().trim();

    String number = numbers[key] ?? "80001125"; // par défaut,  on appeler la police

    print("TYPE = $key");
    print("NUMBER = $number");

    final Uri uri = Uri(scheme: 'tel', path: number);
    await launchUrl(uri);
  }
    Future<void> fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        suggestions = jsonDecode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Urgence : ${widget.type}", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 15, 1, 84),
        
      ),
      
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                  initialCenter: currentLocation!,
                  initialZoom: 15,

                  onTap: (tapPosition, point) {
                    saveLocation(point);

                    // deplacemr le point sur la carte
                    mapController.move(point, 15);
                  },
                ),
                  children: [
                    TileLayer(
                      urlTemplate: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
                      subdomains: ['a', 'b', 'c'],
                    ),
                    

                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLocation!,
                          width: 50,
                          height: 50,
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
                Positioned(
                  top: 20,
                  left: 15,
                  right: 15,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher un lieu...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      fetchSuggestions(value);
                    },
                  ),
                ),
                if (suggestions.isNotEmpty)
                Positioned(
                  top: 80,
                  left: 15,
                  right: 15,
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(suggestions[index]["display_name"]),
                          onTap: () {
                            selectLocation(suggestions[index]);
                          },
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        color: Colors.white70,
                        padding: EdgeInsets.all(5),
                        child: Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),

                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.all(15),
                    ),
                    onPressed: sendEmergency,
                    child: const Text("🚨 Envoyer l'urgence"),
                  ),
                ),

                Positioned(
                  bottom: 90,
                  right: 20,
                  child: FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 10, 205, 23),
                    onPressed: callEmergency,
                    child: const Icon(Icons.call),
                  ),
                ),
              ],
            ),
    );
  }
}