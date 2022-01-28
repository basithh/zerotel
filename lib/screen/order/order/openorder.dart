import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zerotel/screen/orderpage.dart';

class OpenOrder extends StatefulWidget {
  const OpenOrder({Key? key}) : super(key: key);

  @override
  _OpenOrderState createState() => _OpenOrderState();
}

class _OpenOrderState extends State<OpenOrder> {
  @override
  Widget build(BuildContext context) {
    Query tablelist = FirebaseFirestore.instance
        .collection("table")
        .where("isOrdering", isEqualTo: true);
    return FutureBuilder(
      future: tablelist.get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.data.docs.length == 0) {
          return Text("No order Found");
        }
        return GridView.builder(
            itemCount: snapshot.data.docs.length,
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
            itemBuilder: (BuildContext context, int index) {
              return TableCard(snapshot.data!.docs[index]["tablename"]);
            });
      },
    );
  }
}
