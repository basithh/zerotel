import 'package:flutter/material.dart';

class MenuEnter extends StatefulWidget {
  const MenuEnter({Key? key}) : super(key: key);

  @override
  _MenuEnterState createState() => _MenuEnterState();
}

class _MenuEnterState extends State<MenuEnter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                  border: InputBorder.none,
                  labelText: 'Enter Name',
                  hintText: 'Enter Your Name'),
            )
          ],
        ),
      ),
    );
  }
}
