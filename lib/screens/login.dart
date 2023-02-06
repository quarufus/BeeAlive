import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  LoginPage({
    String usrname = "",
    String passwrd = "",
    Key? key,
  }) :super (key: key);

  final _text = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: Form(
              child: TextField(
                controller: _text,
              )
            )
          ),
          Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(10),
              child: Form(
                  child: TextField(
                    controller: _text,
                  )
              )
          ),
        ],
      ),
    );
  }
}