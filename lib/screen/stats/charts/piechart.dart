import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class PiechartFoodSales extends StatefulWidget {
  const PiechartFoodSales({Key? key}) : super(key: key);

  @override
  _PiechartFoodSalesState createState() => _PiechartFoodSalesState();
}

bool _progressController = true;
List<Food> foodlist = [];
List<charts.Series<Food, String>> _seriesPieData = [];

class _PiechartFoodSalesState extends State<PiechartFoodSales> {
  DateTime date = DateTime.now();
  Future<void> foodsalechart() async {
    await FirebaseFirestore.instance.collection("menu").get().then((value) {
      for (DocumentSnapshot ds in value.docs) {
        foodlist.add(Food(ds['food'], 0));
      }
    });
    await FirebaseFirestore.instance
        .collection("Invoice")
        .where("date",
            isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day))
        .where("date",
            isLessThan: DateTime(date.year, date.month, date.day)
                .add(Duration(days: 1)))
        .get()
        .then((value) async {
      for (DocumentSnapshot ds in value.docs) {
        await FirebaseFirestore.instance
            .collection("Invoice")
            .doc(ds.id)
            .collection("invoice")
            .get()
            .then((value) {
          foodlist.forEach((element) {
            for (DocumentSnapshot ds in value.docs) {
              if (element.food == ds["food"]) {
                element.foodcount++;
              }
            }
          });
        });
      }
    });
    setState(() {
      _progressController = false;
    });
    a();
  }

  void a() {
    foodlist.forEach((element) {
      print(element.food);
      print(element.foodcount);
    });
  }

  _generateData() {
    var pieData = foodlist;
    _seriesPieData.add(charts.Series(
        id: "QWERTY",
        data: pieData,
        domainFn: (Food food, _) => food.food,
        measureFn: (Food food, _) => food.foodcount,
        labelAccessorFn: (Food food, _) => '${food.food} ${food.foodcount}'));
  }

  @override
  void initState() {
    super.initState();

    _progressController = true;

    foodlist = [];
    _seriesPieData = [];
    foodsalechart();
    _generateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: _progressController
          ? Center(child: CircularProgressIndicator())
          : charts.PieChart(
              _seriesPieData,
              defaultRenderer: new charts.ArcRendererConfig(
                  arcRendererDecorators: [
                    new charts.ArcLabelDecorator(
                        labelPosition: charts.ArcLabelPosition.inside)
                  ]),
            ),
    ));
  }
}

class Food {
  String food;
  int foodcount;
  Food(this.food, this.foodcount);
}
