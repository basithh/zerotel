import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Food {
  String food;
  int foodcount;
  Food(this.food, this.foodcount);
}

List invoiceid = [];
List<Food> foodlist = [];
List<charts.Series<Food, String>> seriesPieData = [];
_generateData() {
  var pieData = foodlist;
  seriesPieData.add(charts.Series(
      id: "QWERTY",
      data: pieData,
      domainFn: (Food food, _) => food.food,
      measureFn: (Food food, _) => food.foodcount,
      labelAccessorFn: (Food food, _) => '${food.foodcount}'));
}

class FoodPieChart extends StatefulWidget {
  const FoodPieChart({Key? key}) : super(key: key);

  @override
  _FoodPieChartState createState() => _FoodPieChartState();
}

class _FoodPieChartState extends State<FoodPieChart> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection("menu").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }
              snapshot.data!.docs.forEach((element) {
                foodlist.add(Food(element["food"], 0));
              });
              return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection("Invoice")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Something went wrong');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text("Loading");
                    }
                    snapshot.data!.docs.forEach((element) {
                      FirebaseFirestore.instance
                          .collection("Invoice")
                          .doc(element.id)
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
                    });
                    _generateData();
                    return charts.PieChart(
                      seriesPieData,
                      behaviors: [
                        new charts.DatumLegend(
                            outsideJustification:
                                charts.OutsideJustification.endDrawArea,
                            horizontalFirst: false)
                      ],
                    );
                  });
            }),
      ),
    );
  }
}
