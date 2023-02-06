import 'package:bee_alive/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:bee_alive/screens/profile.dart';
import 'package:bee_alive/screens/settings.dart';

class BottomNavBar extends StatefulWidget {
  //final int index = 0;

  const BottomNavBar({required this.index, Key? key}) : super(key: key);
  final int index;

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(5),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BottomNavigationBar(
              showSelectedLabels: false,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              backgroundColor: const Color(0xffE28525),
              elevation: 0,
              currentIndex: widget.index,
              selectedItemColor: Colors.white,
              unselectedItemColor: const Color(0xff555555),
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline), label: ''),
                BottomNavigationBarItem(
                    icon: Icon(
                      Icons.hexagon_outlined,
                      size: 40,
                    ),
                    label: '1',
                    backgroundColor: Colors.red),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined), label: '2')
              ],
              onTap: (tapIndex) {
                switch (tapIndex) {
                  case 0:
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ProfilePage()));
                    break;
                  case 1:
                    if (widget.index != 1) Navigator.pop(context);
                    break;
                  case 2:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SettingsPage()));
                    break;
                }
              },
            )));
  }
}

class Navbar extends StatefulWidget {
  final List<String> elemTags;
  final List<Icon> icons;
  final int current;
  final Function(int) onPressed;

  const Navbar(
      this.elemTags, this.icons, this.current, this.onPressed, Key? key)
      : super(key: key);

  @override
  NavbarState createState() => NavbarState();
}

class NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _getChildren(),
    );
  }

  List<Widget> _getChildren() {
    List<Widget> ret = [];
    for (int i = 0; i < widget.elemTags.length; i++) {
      ret.add(Expanded(
        child: NavbarElement(
            tag: widget.elemTags[i],
            icon: widget.icons[i],
            press: widget.onPressed,
            position: i,
            opened: widget.current == i,
            color: const Color(0xff282828)),
      ));
    }
    return ret;
  }
}

class NavbarElement extends StatefulWidget {
  final String tag;
  final Icon icon;
  final Color color;
  final int position;
  final bool opened;
  final Function(int) press;

  const NavbarElement(
      {required this.tag,
      required this.icon,
      required this.press,
      required this.position,
      required this.opened,
      required this.color,
      Key? key})
      : super(key: key);

  @override
  NavbarElementState createState() => NavbarElementState();
}

class NavbarElementState extends State<NavbarElement> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.press(widget.position);
      },
      child: Container(
          margin: const EdgeInsets.all(0.0),
          decoration: const BoxDecoration(color: Color(0xff888888)),
          height: 75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Stack(
              children: [
                AnimatedPositioned(
                  right: 0,
                  left: 0,
                  top: widget.opened ? -50 : 0,
                  bottom: 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                      curve: Curves.easeInOut,
                      opacity: widget.opened ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: widget.icon),
                ),
                AnimatedPositioned(
                  right: 0,
                  left: 0,
                  bottom: widget.opened ? 0 : -50,
                  top: 0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedOpacity(
                    curve: Curves.easeInOut,
                    opacity: widget.opened ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.tag,
                          style: TextStyle(
                              color: widget.color,
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: const EdgeInsets.all(5.0),
                          height: 5,
                          width: 5,
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(2.5),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
