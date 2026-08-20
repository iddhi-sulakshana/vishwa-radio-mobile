import 'package:flutter/material.dart';
import 'package:vishwa_radio/navigation/app_routes.dart';
import 'package:vishwa_radio/screens/splash_screen.dart';
import 'package:vishwa_radio/theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vishwa Radio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bgDeep,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.orbit,
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
      routes: AppRoutes.table,
    );
  }
}
