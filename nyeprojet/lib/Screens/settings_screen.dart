import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Réglages',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'AvantGarde',
        scaffoldBackgroundColor: const Color(0xFFEEF2FF),
      ),
      home: const SettingsScreen(),
    );
  }
}

// ── Couleurs Principales, été données 
class AppColors {
  static const richBlack      = Color(0xFF00072D);
  static const darkGreen      = Color(0xFF051650);
  static const bangladeshGreen = Color(0xFF0A2472);
  static const caribbeanGreen = Color(0xFF123499);
  static const white          = Color(0xFF5EAF73); 
  static const pureWhite      = Color(0xFFFFFFFF);
  static const lightBg        = Color(0xFFEEF2FF);
  static const divider        = Color(0xFFD0D9F5);
  static const textDark       = Color(0xFF00072D);
  static const textMuted      = Color(0xFF6B7FC4);
}

// ── Screen ───────────────────────────────────────────────────────────────────
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            const _AppBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: const [
                  _ProfileCard(),
                  SizedBox(height: 28),
                  _SectionLabel('Mon compte'),
                  SizedBox(height: 8),
                  _SettingsGroup(items: [
                    _SettingsTile(icon: Icons.person_outline_rounded,    label: 'Gérer mon profil'),
                    _SettingsTile(icon: Icons.lock_outline_rounded,       label: 'Mot de passe et sécurité'),
                    _SettingsTile(icon: Icons.notifications_none_rounded, label: 'Notifications'),
                    _SettingsTile(icon: Icons.language_rounded,           label: 'Langues', isLast: true),
                  ]),
                  SizedBox(height: 28),
                  _SectionLabel('Préférences'),
                  SizedBox(height: 8),
                  _SettingsGroup(items: [
                    _SettingsTile(icon: Icons.info_outline_rounded,       label: 'À propos de nous'),
                    _SettingsTile(icon: Icons.palette_outlined,           label: 'Thème'),
                    _SettingsTile(icon: Icons.emergency_outlined,         label: 'Numéros des urgences', isLast: true),
                  ]),
                  SizedBox(height: 28),
                  _SectionLabel('Assistance'),
                  SizedBox(height: 8),
                  _SettingsGroup(items: [
                    _SettingsTile(icon: Icons.devices_outlined,           label: 'Vos dispositifs'),
                    _SettingsTile(icon: Icons.help_outline_rounded,       label: "Centre d'aide", isLast: true),
                  ]),
                  SizedBox(height: 32),
                  _LogoutButton(),
                  SizedBox(height: 16),
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
  const _ProfileCard();

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
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.bangladeshGreen, AppColors.caribbeanGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oumar Doumbia',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'doumbiaoumar02006@gmail.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────
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

// ── Settings Group ────────────────────────────────────────────────────────────
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

// ── Settings Tile ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLast;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
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
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
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

// ── Logout Button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bangladeshGreen, AppColors.caribbeanGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.bangladeshGreen.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                'Se déconnecter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Navigation ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.richBlack,
        boxShadow: [
          BoxShadow(
            color: AppColors.richBlack.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(icon: Icons.notifications_none_rounded, isActive: false),
              _NavItem(icon: Icons.home_outlined, isActive: false),
              _NavItem(icon: Icons.error_outline_rounded, isActive: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;

  const _NavItem({required this.icon, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: isActive
          ? BoxDecoration(
              color: AppColors.bangladeshGreen.withOpacity(0.3),
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        icon,
        color: isActive ? AppColors.pureWhite : AppColors.textMuted,
        size: 26,
      ),
    );
  }
}
