import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:zerotel/screen/stats/charts/piechart.dart';
import 'package:pie_chart/pie_chart.dart';

class FinanceX extends StatefulWidget {
  const FinanceX({Key? key}) : super(key: key);

  @override
  _FinanceXState createState() => _FinanceXState();
}

final Map<String, double> sampleData = {
  "Flutter": 5,
  "React": 3,
  "Xamarin": 2,
  "Ionic": 2,
};

class _FinanceXState extends State<FinanceX> {
  @override
  Widget build(BuildContext context) {
    int sum = 0;

    return Scaffold(
      body: Center(
        child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('Invoice').get(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                snapshot.data.docs.forEach((value) {
                  sum = value['tot'] + sum;
                });
              }
              // return PieChart(data: sampleData);
              return Text("data");

              // return Text("loading");
            }),
      ),
    );
  }
}
