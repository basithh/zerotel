import 'package:flutter/material.dart';
import 'package:zerotel/screen/stats/charts/piechart.dart';
import 'package:zerotel/screen/stats/charts/saleslinechart.dart';
import 'package:zerotel/screen/stats/stat/foodwise.dart';

class Statspage extends StatelessWidget {
  const Statspage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                TileStats("FoodPie", Icons.pie_chart, PiechartFoodSales()),
                TileStats("Sale(5 DAY)", Icons.show_chart, SaleLineChart()),
                TileStats("Stats", Icons.show_chart, FoodwiseStats()),
              ],
            ),
          ))
        ],
      ),
    );
  }
}

class TileStats extends StatelessWidget {
  final String insidetext;
  final IconData iconw;
  final Widget pagere;

  const TileStats(this.insidetext, this.iconw, this.pagere);

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
