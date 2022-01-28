import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Food {
  String food;
  int foodcount;
  Food(this.food, this.foodcount);
}

bool _progressController = true;
List<Food> foodlist = [];

class FoodwiseStats extends StatefulWidget {
  const FoodwiseStats({Key? key}) : super(key: key);

  @override
  _FoodwiseStatsState createState() => _FoodwiseStatsState();
}

class _FoodwiseStatsState extends State<FoodwiseStats> {
  DateTime date = DateTime.now();
  Future<void> foodsalechart() async {
    await FirebaseFirestore.instance
        .collection("menu")
        .orderBy("cag", descending: false)
        .get()
        .then((value) {
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
  }

  @override
  void initState() {
    super.initState();

    _progressController = true;

    foodlist = [];

    foodsalechart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _progressController
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: foodlist.length,
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(foodlist[index].food),
                      subtitle: Text(foodlist[index].foodcount.toString()));
                }));
  }
}
