import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const NavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 1, 5, 72), // couleur barre de navigation
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 0, "Home"),
          _buildNavItem(Icons.settings, 1, "Alertes"),
          _buildNavItem(Icons.warning_amber_outlined, 2, "Urgences"),
          _buildNavItem(Icons.error_outline, 3, "Settings"),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => onItemTapped(index),
          icon: Icon(
            icon,
            size: 28,
            color: selectedIndex == index
                ? const Color.fromARGB(255, 91, 149, 247)
                : Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: selectedIndex == index
                ? const Color.fromARGB(255, 91, 149, 247)
                : Colors.white,
          ),
        ),
      ],
    );
  }
}