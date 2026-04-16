import 'package:flutter/material.dart';

class HomeNavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const HomeNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

const homeNavDestinations = [
  HomeNavDestination(
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_rounded,
    label: 'Dashboard',
  ),
  HomeNavDestination(
    icon: Icons.fitness_center_outlined,
    selectedIcon: Icons.fitness_center_rounded,
    label: 'Workouts',
  ),
  HomeNavDestination(
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_rounded,
    label: 'Exercises',
  ),
  HomeNavDestination(
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart_rounded,
    label: 'History',
  ),
  HomeNavDestination(
    icon: Icons.person_outline_rounded,
    selectedIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];
