import 'package:flutter/material.dart';

/// ParkKeys palette (same purple theme as Activity 8).
class AppColors {
  static const purple = Color(0xFF6941C6);
  static const darkPurple = Color(0xFF35245E);
  static const lightPurple = Color(0xFFF2EDFC);
  static const border = Color(0xFFEAE5F2);
  static const background = Color(0xFFF9F8FC);
  static const error = Color(0xFFB42318);
}

/// Shared choices for the Activity 9 report form (demo data only).
class AppConstants {
  static const transports = ['Multicab', 'Tricycle'];
  static const reportCategories = [
    'Queue skipping',
    'Unfair turn',
    'Overcharging',
    'Driver behavior',
    'Other',
  ];
}