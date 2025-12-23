// lib/theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const primary = Colors.blue;
  static const primaryLight = Color(0xFF64B5F6);
  static const primaryDark = Color(0xFF1976D2);

  // Background colors
  static const background = Color(0xFFF5F5F5);
  static const cardBackground = Colors.white;
  static const drawerBackground = Color(0xFF1F2937);
  static const drawerHeaderBackground = Color(0xFF111827);

  // Text colors
  static const textPrimary = Colors.black;
  static const textSecondary = Color(0xFF6B7280);
  static const textDrawer = Colors.white;
  static const textDrawerSecondary = Color(0xFF9CA3AF);

  // Status colors
  static const statusConfirmed = Colors.green;
  static const statusPending = Colors.orange;
  static const statusCompleted = Colors.blue;
  static const statusCancelled = Colors.red;
  static const statusLowStock = Colors.orange;
  static const statusOutOfStock = Colors.red;
  static const statusInStock = Colors.green;
  static const statusPaid = Colors.green;
  static const statusUnpaid = Colors.red;

  // Border colors
  static const borderLight = Color(0xFF374151);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardColor: AppColors.cardBackground,
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.drawerBackground,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}