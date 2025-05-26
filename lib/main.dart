
import 'package:flutter/material.dart';
import 'package:giadienver1/home_Screens/add_room.dart';
import 'package:giadienver1/home_Screens/thanhtoan.dart';
import 'package:giadienver1/screens_in/champion.dart';
import 'package:giadienver1/void/Bottom_navigation.dart';
import 'package:giadienver1/home_Screens/home.dart';




void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Color(0xFFFAFBF3),
      ),
      home: const ChampionScreens()
    );
  }
}
