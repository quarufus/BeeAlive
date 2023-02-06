import 'package:flutter/material.dart';
import 'package:bee_alive/widgets/nav_bar.dart';
import 'package:bee_alive/screens/map.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  int index = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
          child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  profileButton(Icons.close, "  Διαγραφή Μελισσοκομείου",
                      const MapPage()),
                  profileButton(Icons.language, "  Γλώσσα", const MapPage()),
                  profileButton(
                      Icons.account_circle, "  Λογαριασμός", const MapPage()),
                  profileButton(
                      Icons.format_paint, "  Εμφάνιση", const MapPage())
                ],
              ))),
      bottomNavigationBar: BottomNavBar(index: index),
    );
  }

  Widget profileButton(icon, text, route) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextButton(
          style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 20),
              //foregroundColor: const Color(0xffffffff),
              backgroundColor: const Color(0x80E28525),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
          onPressed: (() {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => route));
          }),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipOval(
                  child: Container(
                color: const Color(0x42FFFFFF),
                child: Icon(
                  icon,
                  size: 30,
                ),
              )),
              Flexible(
                  child: Text(
                text,
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
        ));
  }
}
