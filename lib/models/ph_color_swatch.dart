import 'package:flutter/material.dart';

class PhColorSwatch {
  const PhColorSwatch({
    required this.label,
    required this.color,
    required this.rgb,
    required this.hsv,
    required this.lab,
    required this.hex,
    required this.requirements,
    required this.steps,
  });

  final String label;
  final Color color;
  final String rgb;
  final String hsv;
  final String lab;
  final String hex;
  final List<String> requirements;
  final List<String> steps;
}
