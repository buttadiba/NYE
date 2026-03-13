import 'package:flutter/material.dart';

class nav_bar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const nav_bar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Container(
      
      height: 70,
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 2, 7, 88), // couleur barre de navigation
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.notifications_outlined, 0),
          _buildNavItem(Icons.home, 1),
          _buildNavItem(Icons.error_outline, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    
    return IconButton(
      onPressed: () => onItemTapped(index),
      icon: Icon(
        icon,
        size: 28,
        color: selectedIndex == index
            ? const Color.fromARGB(255, 91, 149, 247)
            : Colors.white,
      ),
    );
  }
}