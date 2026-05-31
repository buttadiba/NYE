import 'package:flutter/material.dart';
import 'package:nyeprojet/Screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nyeprojet/Screens/home.dart';
import 'package:nyeprojet/Screens/notification_page.dart';
import 'package:nyeprojet/Screens/urgence.dart';
import 'package:nyeprojet/widgets/nav_bar.dart';

// Couleurs Principales
class AppColors {
  static const richBlack = Color(0xFF00072D);
  static const darkGreen = Color(0xFF051650);
  static const bangladeshGreen = Color(0xFF0A2472);
  static const caribbeanGreen = Color(0xFF123499);
  static const pureWhite = Color(0xFFFFFFFF);
  static const lightBg = Color(0xFFEEF2FF);
  static const divider = Color(0xFFD0D9F5);
  static const textDark = Color(0xFF00072D);
  static const textMuted = Color(0xFF6B7FC4);
}

// l ecran de parametres de l application
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name = prefs.getString('name') ?? "Utilisateur";
      email = prefs.getString('email') ?? "email@gmail.com";
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

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
        // On est déjà sur la page profil
        break;
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('email');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Connexion()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                children: [
                  _ProfileCard(name: name, email: email, onLogout: logout),
                  const SizedBox(height: 28),
                  const _SectionLabel('Mon compte'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    items: [
                      _SettingsTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Gérer mon profil',
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        label: 'Mot de passe et sécurité',
                      ),

                      // Le tile pour choisir la langue de l'application
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: 'Langues',
                        isLast: true,
                        onTap: () {
                          //afficher la boîte de dialogue pour choisir la langue
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Choisir la langue"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: const Text("Français"),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    ListTile(
                                      title: const Text("English"),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionLabel('Préférences'),
                  const SizedBox(height: 8),
                  _SettingsGroup(
                    items: [
                      // Le tile pour afficher les informations sur l'application " A propos de nous"
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: 'À propos de nous',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("À propos de NYE"),
                                content: const Text(
                                  "NYE est un système intelligent de sécurité conçu pour détecter les intrusions et les dangers tels que le feu en temps réel. "
                                  "Grâce à un dispositif connecté (ESP32) et une application mobile, NYE permet de surveiller votre environnement, "
                                  "envoyer des alertes instantanées et améliorer votre sécurité au quotidien.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Fermer"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const _SettingsTile(
                        icon: Icons.palette_outlined,
                        label: 'Thème',
                      ),
                      // numero d urgence tile
                      _SettingsTile(
                        icon: Icons.emergency_outlined,
                        label: 'Numéros des urgences',
                        isLast: true,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Numéros d'urgence"),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "En cas d'urgence, vous pouvez contactez rapidement les services suivants :",
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(height: 12),

                                    Text("👮 Police : 80 00 11 25"),
                                    SizedBox(height: 6),

                                    Text("🚑 Ambulance : 76 29 14 70"),
                                    SizedBox(height: 6),

                                    Text("🛡 Sécurité : 20 23 95 11"),
                                    SizedBox(height: 6),

                                    Text("🚒 Pompiers : 20 22 80 81"),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Fermer"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const _SectionLabel('Assistance'),
                  const SizedBox(height: 8),
                  const _SettingsGroup(
                    items: [
                      _SettingsTile(
                        icon: Icons.devices_outlined,
                        label: 'Vos dispositifs',
                      ),
                      _SettingsTile(
                        icon: Icons.help_outline_rounded,
                        label: "Centre d'aide",
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── App Bar ──────────────────────────────────────────────────────────────────
class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Icon(Icons.menu_rounded, color: AppColors.bangladeshGreen, size: 26),
          const SizedBox(width: 14),
          Text(
            'RÉGLAGES',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.5,
              color: AppColors.bangladeshGreen,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Profile Card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onLogout;

  const _ProfileCard({
    required this.name,
    required this.email,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.bangladeshGreen.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.bangladeshGreen,
                      AppColors.caribbeanGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      email.isNotEmpty ? email : email,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onLogout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );
  }
}

// Tile de section
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

// Groupe de paramètres
class _SettingsGroup extends StatelessWidget {
  final List<_SettingsTile> items;
  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.bangladeshGreen.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

// parametre de chaque tile de la page de parametres
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLast;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.isLast = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(20),
            bottom: isLast ? const Radius.circular(20) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lightBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.bangladeshGreen, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            thickness: 1,
            indent: 68,
            endIndent: 18,
            color: AppColors.divider,
          ),
      ],
    );
  }
}
