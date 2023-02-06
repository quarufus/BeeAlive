import 'package:flutter/material.dart';
import 'package:bee_alive/widgets/apiary_marker.dart';
import 'package:bee_alive/screens/setup/pages.dart';
import 'package:bee_alive/widgets/nav_bar.dart';

class ApiariesPage extends StatefulWidget {
  final Apiary apiary;
  final int index;

  const ApiariesPage({
    required this.index,
    required this.apiary,
    Key? key,
  }) : super(key: key);

  @override
  ApiariesPageState createState() => ApiariesPageState();
}

class ApiariesPageState extends State<ApiariesPage> {
  int opened = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Apiaries'),
          centerTitle: true,
          //backgroundColor: const Color(0xff7EBDC2),
          shadowColor: const Color(0x00000000),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8),
            child: PageView(
              controller: controller,
              children: getPages(widget.index),
            )),
        bottomNavigationBar: BottomNavBar(index: opened));
  }
}
