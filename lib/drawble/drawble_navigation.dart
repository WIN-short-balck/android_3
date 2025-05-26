import 'package:flutter/material.dart';
import 'package:giadienver1/home_Screens/add_room.dart';
import 'package:giadienver1/home_Screens/home.dart';
import 'package:giadienver1/home_Screens/locroom.dart';
import 'package:giadienver1/home_Screens/thietlapthanhtoan.dart';
import 'package:giadienver1/void/Bottom_navigation.dart';

class DrawerNavigation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerNavigation();
}

class _DrawerNavigation extends State<DrawerNavigation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.blue,
        child: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundImage: AssetImage("assets/images/logo.png",),
                ),
                accountName: Text("THE CHAMPION", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                accountEmail: null,
                decoration: BoxDecoration(color: Colors.blue),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text("Home"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Navigation(tile: "",)),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.add),
                title: Text("Thêm phòng"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddRoom()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text("thiết lập"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PriceSettingsScreen();
                  },));
                },
              ),
              ListTile(
                leading: Icon(Icons.filter_list_alt),
                title: Text("Lọc phòng"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FillRoom()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
