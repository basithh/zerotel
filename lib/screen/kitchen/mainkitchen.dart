import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class KitchenGround extends StatefulWidget {
  const KitchenGround({Key? key}) : super(key: key);

  @override
  _KitchenGroundState createState() => _KitchenGroundState();
}

class _KitchenGroundState extends State<KitchenGround> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("table")
            .where("isOrdering", isEqualTo: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (!snapshot.hasData) {
            return Text("No order Found");
          }

          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (_, index) {
                return KitchenCard(snapshot.data!.docs[index]["tablename"]);
              });
        },
      ),
    );
  }
}

class KitchenCard extends StatefulWidget {
  String tablename;
  KitchenCard(this.tablename);

  @override
  _KitchenCardState createState() => _KitchenCardState();
}

class _KitchenCardState extends State<KitchenCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Text(
              "Table " + widget.tablename,
              style: TextStyle(fontSize: 20),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("table")
                  .doc(widget.tablename)
                  .collection("ordering")
                  .where("plated", isEqualTo: false)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!snapshot.hasData) {
                  return Text("No order Found");
                }

                return SizedBox(
                  child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (_, index) {
                        print(snapshot.data!.docs[index]["food"]);
                        return CardinsideText(
                            snapshot.data!.docs[index]["food"],
                            snapshot.data!.docs[index]["counter"],
                            widget.tablename,
                            snapshot.data!.docs[index].id);
                      }),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class CardinsideText extends StatefulWidget {
  String food;
  int count;
  String table;
  String id;
  CardinsideText(this.food, this.count, this.table, this.id);

  @override
  _CardinsideTextState createState() => _CardinsideTextState();
}

class _CardinsideTextState extends State<CardinsideText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Expanded(flex: 6, child: Text(widget.food)),
          Expanded(flex: 2, child: Text(widget.count.toString())),
          Expanded(
              flex: 2,
              child: TextButton(
                child: Text("Plate"),
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("table")
                      .doc(widget.table)
                      .collection("ordering")
                      .doc(widget.id)
                      .update({"plated": true});
                },
              ))
        ],
      ),
    );
  }
}
