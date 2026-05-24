import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/question_generation_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => QuestionGenerationProvider()),
      ],
      child: const HireNovaAI(),
    ),
  );
}

//HN-FUUA9Q
//PASS-NKFFHE
//INV-PKJ6V6
class HireNovaAI extends StatelessWidget {
  const HireNovaAI({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'HireNova AI',

      theme: AppTheme.lightTheme,

      darkTheme: AppTheme.darkTheme,

      themeMode: themeProvider.currentTheme,

      home: const SplashScreen(),
    );
  }
}
