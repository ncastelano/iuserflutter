import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import 'authentication/authentication_controller.dart';
import 'home/mute_controller.dart';
import 'login/login_screen.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  cameras = await availableCameras();

  Get.put(AuthenticationController());
  Get.put(MuteController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'iUser',
      debugShowCheckedModeBanner: false,

      // Adicionando traduções para o Quill
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('pt'),
      ],

      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,

        // Textos principais
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          titleMedium: TextStyle(color: Colors.white70),
        ),

        // Input / TextField
        inputDecorationTheme: const InputDecorationTheme(
          errorStyle: TextStyle(color: Colors.redAccent),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
        ),

        // Cursor e seleção de texto (TextField)
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,             // cor do caret
          selectionColor: Colors.white24,        // cor do fundo da seleção
          selectionHandleColor: Colors.white,    // "thumb" da seleção
        ),

        // Slider
        sliderTheme: SliderThemeData(
          thumbColor: Colors.white,              // cor do thumb
          activeTrackColor: Colors.greenAccent,  // cor da barra ativa
          inactiveTrackColor: Colors.white30,    // cor da barra inativa
          overlayColor: Colors.greenAccent.withOpacity(0.2),
          valueIndicatorColor: Colors.greenAccent,
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.selected) ? Colors.greenAccent : Colors.white54,
          ),
          trackColor: MaterialStateProperty.resolveWith<Color>(
                (states) => states.contains(MaterialState.selected) ? Colors.greenAccent.withOpacity(0.5) : Colors.white30,
          ),
        ),

        // FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.greenAccent,
          foregroundColor: Colors.black,
        ),

        // ElevatedButton
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),

        // ColorScheme (para botões e outros widgets que usam cores do tema)
        colorScheme: ColorScheme.dark(
          primary: Colors.greenAccent,   // usado em botões e outros controles
          secondary: Colors.greenAccent, // remove roxo padrão
        ),
      ),


      home: const LoginScreen(),
    );
  }
}
