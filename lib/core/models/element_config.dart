import 'package:flutter/material.dart';

enum AppLearningElement { water, earth, air, fire }

class ElementConfig {
  final AppLearningElement element;
  final String name;
  final String topic;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color primaryColor;
  final Color secondaryColor;
  final String route;

  const ElementConfig({
    required this.element,
    required this.name,
    required this.topic,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
    required this.route,
  });

  static List<ElementConfig> get allElements => [
    const ElementConfig(
      element: AppLearningElement.water,
      name: 'Agua',
      topic: 'Fluidez',
      subtitle: 'Speaking',
      description: 'Desarrolla tu fluidez hablando y leyendo en voz alta.',
      icon: Icons.waves,
      primaryColor: Color(0xFF00B0FF), // Bright Blue
      secondaryColor: Color(0xFF00E5FF), // Cyan
      route: '/reading',
    ),
    const ElementConfig(
      element: AppLearningElement.earth,
      name: 'Tierra',
      topic: 'Cimientos',
      subtitle: 'Gramática y Vocabulario',
      description: 'Construye una base sólida con lecciones estructuradas.',
      icon: Icons.terrain,
      primaryColor: Color(0xFF8D6E63), // Brown
      secondaryColor: Color(0xFFA1887F), // Lighter Brown
      route: '/earth',
    ),
    const ElementConfig(
      element: AppLearningElement.air,
      name: 'Aire',
      topic: 'Claridad',
      subtitle: 'Fonética y Pronunciación',
      description: 'Refina tu pronunciación para una comunicación clara.',
      icon: Icons.air,
      primaryColor: Color(0xFFB3E5FC), // Light Blue / Air
      secondaryColor: Color(0xFFE1F5FE), // Very Light Blue
      route: '/air',
    ),
    const ElementConfig(
      element: AppLearningElement.fire,
      name: 'Fuego',
      topic: 'Energía',
      subtitle: 'Inmersión y Pasión',
      description: 'Sumérgete en el idioma con contenido dinámico.',
      icon: Icons.local_fire_department,
      primaryColor: Color(0xFFFF5252), // Red
      secondaryColor: Color(0xFFFF8A80), // Coral/Pink
      route: '/fire',
    ),
  ];
}
