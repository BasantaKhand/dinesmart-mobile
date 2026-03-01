import 'package:dinesmart_app/app/theme/app_theme.dart';
import 'package:dinesmart_app/features/splash/presentation/pages/splash_page.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  


  @override
  Widget build(BuildContext context) {
    return MaterialApp( 
      title: 'Dinesmart Application',
      debugShowCheckedModeBanner: false,
      theme:AppTheme.lightTheme,
      home: const SplashPage()
    );
  }
}