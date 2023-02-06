import 'package:flutter/material.dart';
import 'package:bee_alive/widgets/nav_bar.dart';
import 'package:bee_alive/screens/setup/setup.dart';
import 'package:bee_alive/ui/ble.dart';

class ProfilePage extends StatefulWidget {
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 100),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            shadowColor: Colors.black45,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileButton(
                    Icons.add, "  Νέο Μελισσοκομείο", const SetupPage()),
                profileButton(
                    Icons.smoke_free, "  Καπνιστήρι", const BLEPage()),
                profileButton(Icons.logout, "  Έξοδος", const BLEPage()),
              ],
            ),
          )),
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
              Text(text),
            ],
          ),
        ));
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton(
      {required this.icon, required this.text, required this.route});

  final IconData icon;
  final String text;
  final Widget route;

  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
          textStyle: const TextStyle(fontSize: 20),
          backgroundColor: const Color(0x80E28525),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      onPressed: (() {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ClipOval(
              child: Container(
            color: const Color(0x42FFFFFF),
            child: Icon(
              icon,
              size: 30,
            ),
          )),
          Text(text),
        ],
      ),
    );
  }
}
