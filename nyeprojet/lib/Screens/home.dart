import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyeprojet/Screens/login.dart';
import 'package:nyeprojet/Screens/notification_page.dart';
import 'package:nyeprojet/Screens/urgence.dart';
import 'settings_screen.dart'; //
import '../widgets/nav_bar.dart';
import 'package:http/http.dart' as http;

class NyeHomePage extends StatefulWidget {
  const NyeHomePage({super.key});

  @override
  State<NyeHomePage> createState() => _NyeHomePageState();
}

class _NyeHomePageState extends State<NyeHomePage> {
  // --- Contrôle de l'ESP (API) active ou désactivée ---
  Future<void> controlESP(bool isOn) async {
    final url = isOn ? "http://IP_ESP/api/on" : "http://IP_ESP/api/off";

    try {
      await http.get(Uri.parse(url));
    } catch (e) {
      print("Erreur connexion ESP: $e");
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => Connexion()),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Connexion()),
      );
    }
  }

  int _selectedIndex = 0;

  // --- Variables Home ---
  bool _isNyeOpen = false;
  bool _isPowerSaveOn = false;
  final int _batteryLevel = 100;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        setState(() {
          _selectedIndex = 0;
        });
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

  void _togglePowerSave(bool newValue) {
    setState(() {
      _isPowerSaveOn = newValue;
    });
  }

  IconData _getBatteryIcon(int level) {
    if (level >= 85) return Icons.battery_full;
    if (level >= 70) return Icons.battery_6_bar;
    if (level >= 50) return Icons.battery_4_bar;
    if (level >= 25) return Icons.battery_2_bar;
    return Icons.battery_alert;
  }

  @override
  Widget build(BuildContext context) {
    // --- Liste des pages ---
    final List<Widget> pages = [
      _homePage(), // Home
      _alertPage(), // Alert
      _urgencePage(), // Urgence
      const SettingsScreen(), // Settings
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  // ----------------- Home Page -----------------
  Widget _homePage() {
    String statusText = _isNyeOpen
        ? "Votre œil est ouvert"
        : "Votre œil est fermé";
    String nyeStatusText = _isNyeOpen ? "ON" : "OFF";
    Color nyeCircleColor = _isNyeOpen ? Colors.green : Colors.red;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFF051650)),
                onPressed: logout,
              ),
            ),
            Text(
              statusText,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF051650),
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              // Lorsque l'utilisateur appuie sur le cercle,
              //on inverse l'état de l'œil et on envoie la requête à l'ESP
              onTap: () {
                bool newState = !_isNyeOpen;

                setState(() {
                  _isNyeOpen = newState;
                });

                controlESP(
                  newState,
                ); // Envoie la requête à l'ESP pour ouvrir ou fermer l'œil
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: nyeCircleColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    nyeStatusText,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            _buildBatteryPercentageCard(),
            const SizedBox(height: 20),
            _buildBatteryOptimizationCard(),
          ],
        ),
      ),
    );
  }

  // ----------------- Alert Page -----------------
  Widget _alertPage() {
    return const Center(
      child: Text(
        "Alert Page",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ----------------- Urgence Page -----------------
  Widget _urgencePage() {
    return const Center(
      child: Text(
        "Urgence Page",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ----------------- Batteries Widgets -----------------
  Widget _buildBatteryPercentageCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF123499),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Pourcentage de la batterie",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              RotatedBox(
                quarterTurns: 1,
                child: Icon(
                  _getBatteryIcon(_batteryLevel),
                  size: 42,
                  color: _batteryLevel <= 20 ? Colors.redAccent : Colors.white,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Text(
                  "$_batteryLevel%",
                  style: TextStyle(
                    fontSize: 12,
                    color: _batteryLevel <= 20 ? Colors.white : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryOptimizationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF051650),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Optimisation de la batterie:",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  "Activer le mode économie d'énergie",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Transform.scale(
                scale: 0.7,
                child: Switch(
                  value: _isPowerSaveOn,
                  onChanged: _togglePowerSave,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Le mode économie d'énergie permet d'allonger la vie de votre batterie le temps d'une recharge complète.",
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
