import 'package:flutter/material.dart';
import 'package:giadienver1/void/call.dart';
import 'package:giadienver1/home_Screens/home.dart';
import 'package:giadienver1/void/profile.dart';


class Navigation extends StatefulWidget{
  const Navigation({super.key,required this.tile});
  final String tile;

  @override
  State<StatefulWidget> createState()=>_Navigation();

}

class _Navigation extends State<Navigation>{
  var selected_screens= 0;


  final List<Widget> ListScrean=[
    Home(),
    // RoomSelector(),
    MhSupport(title: "Screen Support"),
    Account(title: "Screan profile"),
  ] ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
      ListScrean[selected_screens],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selected_screens,
        onTap: (value) => _onPress(value),
        items: const<BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.home),label: "HOME"),
        // BottomNavigationBarItem(icon: Icon(Icons.filter_alt_rounded),label: "Fillter"),
        BottomNavigationBarItem(icon: Icon(Icons.phone),label: "Contact"),
        BottomNavigationBarItem(icon: Icon(Icons.people),label: "Profile")
      ]
      ),
      );
    
  }
void _onPress(int value){
  setState(() {
    selected_screens = value;
  });
}

}