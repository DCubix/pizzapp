import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
import 'package:pizzapp/pages/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = json.decode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(themeJson)!;
  runApp(PizzApp(theme));
}

class PizzApp extends StatelessWidget {
  const PizzApp(this.theme, {Key? key}) : super(key: key);

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizzapp',
      debugShowCheckedModeBanner: false,
      theme: theme.copyWith(
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}
