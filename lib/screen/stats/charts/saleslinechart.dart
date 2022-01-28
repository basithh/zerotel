import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SaleLineChart extends StatefulWidget {
  const SaleLineChart({Key? key}) : super(key: key);

  @override
  _SaleLineChartState createState() => _SaleLineChartState();
}

bool _progressController = true;
List<Sale> salelist = [];
List<charts.Series<Sale, String>> _seriesPieData = [];

class _SaleLineChartState extends State<SaleLineChart> {
  DateTime date = DateTime.now().add(Duration(days: 1));
  Future<void> foodsalechart() async {
    List sum = [];
    for (int i = 0; i < 6; i++) {
      await FirebaseFirestore.instance
          .collection("Invoice")
          .where("date",
              isGreaterThanOrEqualTo: DateTime(date.year, date.month, date.day)
                  .subtract(Duration(days: i + 1)))
          .where("date",
              isLessThan: DateTime(date.year, date.month, date.day)
                  .subtract(Duration(days: i)))
          .get()
          .then((value) {
        for (DocumentSnapshot ds in value.docs) {
          sum.add(ds['tot']);
        }
        if (sum.isEmpty) {
          salelist.add(Sale(
              DateTime(date.year, date.month, date.day)
                  .subtract(Duration(days: i + 1))
                  .day
                  .toString(),
              0));
        } else {
          salelist.add(Sale(
              DateTime(date.year, date.month, date.day)
                  .subtract(Duration(days: i + 1))
                  .day
                  .toString(),
              sum.reduce((a, b) => a + b)));
        }
      });
      sum = [];
    }
    setState(() {
      _progressController = false;
    });
    salelist = new List.from(salelist.reversed);
    a();
  }

  void a() {
    salelist.forEach((element) {
      print(element.date);
      print(element.sales);
    });
  }

  _generateData() {
    _seriesPieData.add(charts.Series(
        id: "SaleLineChart",
        data: salelist,
        domainFn: (Sale sale, _) => sale.date,
        measureFn: (Sale sale, _) => sale.sales,
        labelAccessorFn: (Sale sale, _) => '${sale.date}'));
  }

  @override
  void initState() {
    super.initState();

    _progressController = true;

    salelist = [];
    _seriesPieData = [];
    foodsalechart();
    _generateData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Container(
        child: _progressController
            ? Center(child: CircularProgressIndicator())
            : charts.BarChart(
                _seriesPieData,
              ),
      ),
    ));
  }
}

class Sale {
  String date;
  int sales;
  Sale(this.date, this.sales);
}
