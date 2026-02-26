import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFFA4A0C);
  static const Color primaryDark = Color(0xFFC03526);

  static const Color secondary = Color(0xFFFF0000);
  static const Color secondaryLight= Color(0xFFFF4B3A);


  static const Color onboardingBackground = Color(0xFFFF4B3A);

  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color backgroundPrimary = Color(0xFFF5F5F5);
  static const Color backgroundSecondary = Color(0xFFD9D9D9);

  static const Color whiteText = Color(0xFFFFFFFF);
  static const Color blackText = Color(0xFF000000);
  static const Color redText = Color(0xFFFF0000);
  static const Color greenText = Color(0xFF008000);
  // Text secondary with opacity
  static const Color opacityTextOne = Color(0x996B7280);
  static const Color opacityTextTwo = Color(0x806B7280);


   static const Color onboarding1Primary =Color(0xFFFF7A18) ;
  static const Color onboarding1Secondary = Color(0xFFFA4A0C);

  

  static const Color onboarding3Primary =Color(0xFFFF5F1F);
  static const Color onboarding3Secondary = Color(0xFFE63E00);

  static const Color onboarding2Primary = Color(0xFFFA4A0C);
  static const Color onboarding2Secondary =  Color(0xFFCC3A00);

  static const Color greyButtonBackground = Color(0xFFD9D9D9);
  static const Color yellowButtonBackground = Color(0xFFFFA500);
  static const Color redButtonBackground = Color(0xFFFF0000);

  static const Color tableAvailable = Color(0xFF008000);
  static const Color tableOccupied = Color(0xFF0000FF);
  static const Color tableREserved = Color(0xFFFFFF00);

  static const Color statusSuccess = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFA726);
  static const Color statusError = Color(0xFfEF4444);
  static const Color statusInfo = Color(0xFF3B82f7);


   // White with opacity
  static const Color white90 = Color(0xE6FFFFFF);
  static const Color white80 = Color(0xCCFFFFFF);
  static const Color white50 = Color(0x80FFFFFF);
  static const Color white30 = Color(0x4DFFFFFF);
  static const Color white20 = Color(0x33FFFFFF);


  // Black with opacity
  static const Color black20 = Color(0x33000000);

   // Border & Divider
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFEFF0F6);

  // Dark Border & Divider
  static const Color darkBorder = Color(0xFF2D3339);
  static const Color darkDivider = Color(0xFF252B33);

    // Item Status Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
  );


  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [ Color(0xFF008000),Color(0xFF4CAF50)],
  );


    // Item Status Gradients
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF0000),Color(0xFFFF4B3A)],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0000FF),Color(0xFF3B82f7) ],
  );

  static const LinearGradient yellowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFF00),Color(0xFFFFA726)],
  );
  
    static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8F9FE), Color(0xFFFFFFFF)],
  );

   static const List<BoxShadow> elevatedShadow = [
    BoxShadow(color: black20, blurRadius: 30, offset: Offset(0, 15)),
    BoxShadow(color: white30, blurRadius: 20, offset: Offset(0, 5)),
  ];





}
