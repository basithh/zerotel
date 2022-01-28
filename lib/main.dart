import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zerotel/screen/editspage.dart';
import 'package:zerotel/screen/kitchen/mainkitchen.dart';
import 'package:zerotel/screen/menu/settings.dart';
import 'package:zerotel/screen/orderpage.dart';
import 'package:zerotel/screen/stats/charts/foodpiechart.dart';
import 'package:zerotel/screen/stats/charts/piechart.dart';
import 'package:zerotel/screen/stats/stats.dart';
import 'package:zerotel/screen/statspage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            SafeArea(
                child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: GridView.count(
                primary: false,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                children: <Widget>[
                  TileCage("Order", Icons.restaurant_menu, OrderPage()),
                  TileCage("Stats", Icons.insights, Statspage()),
                  TileCage("Edits", Icons.edit, Editspage()),
                  TileCage("Expense", Icons.assignment_late, OrderPage()),
                  TileCage("Suggestion", Icons.emoji_objects, OrderPage()),
                  TileCage("Request", Icons.request_page, OrderPage()),
                  TileCage("Kitchen", Icons.blender, KitchenGround()),
                  TileCage("About", Icons.grid_3x3, OrderPage()),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}

class TileCage extends StatelessWidget {
  final String insidetext;
  final IconData iconw;
  final Widget pagere;

  const TileCage(this.insidetext, this.iconw, this.pagere);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return pagere;
              }),
            );
          },
          child: Container(
            child: Column(
              children: [
                Icon(
                  iconw,
                  size: 123,
                ),
                Text(
                  insidetext,
                  style: TextStyle(fontSize: 30),
                )
              ],
            ),
          )),
    );
  }
}
