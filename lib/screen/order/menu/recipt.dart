import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zerotel/screen/orderpage.dart';

class ReciptPage extends StatefulWidget {
  final String tableno;
  ReciptPage(this.tableno);

  @override
  _ReciptPageState createState() => _ReciptPageState();
}

class _ReciptPageState extends State<ReciptPage> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 20.0,
      child: Column(
        children: [
          ReciptOrderCard("Item Name", "P/U", "QTY", "Price", true),
          Expanded(child: ReciptLister(widget.tableno)),
          OrderButton('Finalise', widget.tableno, () {})
        ],
      ),
    );
  }
}

class OrderCal {
  String itemname;
  int price;
  int qty;
  int tot;
  OrderCal(this.itemname, this.price, this.qty, this.tot);
}

List<OrderCal> orderlist = [];

class ReciptLister extends StatefulWidget {
  final String tableno;
  ReciptLister(this.tableno);

  @override
  _ReciptListerState createState() => _ReciptListerState();
}

class _ReciptListerState extends State<ReciptLister> {
  @override
  Widget build(BuildContext context) {
    Query reciptlist = FirebaseFirestore.instance
        .collection('table')
        .doc(widget.tableno)
        .collection("ordering")
        .orderBy("date", descending: false);
    return FutureBuilder(
      future: reciptlist.get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong Contact AiMZero Engineers');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        // print(snapshot.data!['ordering'][0]['food'].toString());
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, index) {
              orderlist.add(OrderCal(
                  snapshot.data!.docs[index]['food'],
                  snapshot.data!.docs[index]['price'],
                  snapshot.data!.docs[index]['counter'],
                  (snapshot.data!.docs[index]['price'] *
                      snapshot.data!.docs[index]['counter'])));
              return ReciptOrderCard(
                  snapshot.data!.docs[index]['food'],
                  snapshot.data!.docs[index]['price'].toString(),
                  snapshot.data!.docs[index]['counter'].toString(),
                  (snapshot.data!.docs[index]['price'] *
                          snapshot.data!.docs[index]['counter'])
                      .toString(),
                  snapshot.data!.docs[index]['plated']);
            });
      },
    );
  }
}

class ReciptOrderCard extends StatefulWidget {
  String itemname;
  String perprice;
  String qty;
  String total;
  bool plated;
  ReciptOrderCard(
      this.itemname, this.perprice, this.qty, this.total, this.plated);

  @override
  _ReciptOrderCardState createState() => _ReciptOrderCardState();
}

class _ReciptOrderCardState extends State<ReciptOrderCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(flex: 6, child: Text(widget.itemname)),
            Expanded(flex: 2, child: Text(widget.perprice)),
            Expanded(flex: 2, child: Text(widget.qty)),
            Expanded(flex: 2, child: Text(widget.total)),
            Expanded(flex: 2, child: widget.plated ? Text("Y") : Text("N")),
          ],
        ),
      ),
    );
  }
}

bool _disablebutton = true;

class OrderButton extends StatefulWidget {
  final String menuname;
  final String tableno;
  final Function reseter;

  OrderButton(this.menuname, this.tableno, this.reseter);

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        setState(() {
          _disablebutton = true;
        });
        int _sum = 0;
        orderlist.forEach((element) {
          _sum = _sum + element.tot;
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AlertTotal(_sum, widget.tableno),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        child: Center(
            child: Text(widget.menuname,
                style: TextStyle(color: Colors.black, fontSize: 20))),
      ),
    );
  }
}

class AlertTotal extends StatefulWidget {
  final int Total;

  final String table;

  AlertTotal(this.Total, this.table);

  @override
  _AlertTotalState createState() => _AlertTotalState();
}

class _AlertTotalState extends State<AlertTotal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: sendinvoice(widget.Total, widget.table),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total  " + widget.Total.toString(),
                        style: TextStyle(fontSize: 30),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderPage(),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.red,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Only Enter Yes",
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                          )),
                      Text("Order " + snapshot.data.toString())
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            // By default, show a loading spinner
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

Future sendinvoice(int total, String table) async {
  String idInovice1 = "";
  print("objecterr");
  await FirebaseFirestore.instance
      .collection('Invoice')
      .orderBy("date", descending: true)
      .limit(1)
      .get()
      .then((value) {
    if (value.docs.isEmpty) {
      idInovice1 = 1.toString();
    } else {
      idInovice1 = (int.parse(value.docs[0].id) + 1).toString();
    }
  });
  await FirebaseFirestore.instance
      .collection('Invoice')
      .doc(idInovice1)
      .set({"tot": total, "date": DateTime.now()});
  print(orderlist.length);
  orderlist.forEach((element) async {
    Map<String, dynamic> orderdata = {
      'food': element.itemname,
      'price': element.price,
      'counter': element.qty,
      'total': element.tot
    };
    await FirebaseFirestore.instance
        .collection('Invoice')
        .doc(idInovice1)
        .collection("invoice")
        .add(orderdata);
  });
  await FirebaseFirestore.instance
      .collection("table")
      .doc(table)
      .update({"isOrdering": false});

  await FirebaseFirestore.instance
      .collection("table")
      .doc(table)
      .collection("ordering")
      .get()
      .then((value) async {
    for (DocumentSnapshot ds in value.docs) {
      await ds.reference.delete();
    }
  });
  orderlist = [];
  return idInovice1;
}
