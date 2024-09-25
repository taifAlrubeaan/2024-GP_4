import 'package:flutter/material.dart';

class NavigationDestination extends StatelessWidget {
  final Icon icon;
  final Icon selectedIcon;
  final String label;

  const NavigationDestination({super.key, 
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  factory NavigationDestination.fromJson(Map<String, dynamic> json) {
    return NavigationDestination(
      icon: json['icon'] ?? const Icon(Icons.dashboard_customize_outlined, color: Colors.white),
      selectedIcon: json['selectedIcon'] ?? const Icon(Icons.dashboard_customize, color: Colors.white),
      label: json['label'] ?? 'Destination',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'icon': icon,
      'selectedIcon': selectedIcon,
      'label': label,
    };
  }

  NavigationDestination copyWith({
    Icon? icon,
    Icon? selectedIcon,
    String? label,
  }) {
    return NavigationDestination(
      icon: icon ?? this.icon,
      selectedIcon: selectedIcon ?? this.selectedIcon,
      label: label ?? this.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: Colors.white));
  }
}