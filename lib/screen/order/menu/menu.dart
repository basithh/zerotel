import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zerotel/screen/order/menu/menumain.dart';
import 'package:zerotel/screen/order/menu/recipt.dart';

class Menutab extends StatefulWidget {
  final String tableno;
  Menutab(this.tableno);

  @override
  _MenutabState createState() => _MenutabState();
}

class _MenutabState extends State<Menutab> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Drawer(
      elevation: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          OrderButton("Send it to Kitchen", widget.tableno, () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => MenuOrder(widget.tableno),
              ),
            );
          }),
          SizedBox(
            height: 10,
          ),
          Expanded(child: MenuCardList()),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

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
        await FirebaseFirestore.instance
            .collection("table")
            .doc(widget.tableno)
            .update({"isOrdering": true});
        listmenucard.forEach((element) async {
          Map<String, dynamic> orderdata = {
            'food': element.name,
            'cag': element.cag,
            'price': element.price,
            'counter': element.counter,
            'date': DateTime.now(),
            'plated': false,
            'table': widget.tableno
          };
          if (element.counter > 0) {
            await FirebaseFirestore.instance
                .collection("table")
                .doc(widget.tableno)
                .collection("ordering")
                .add(orderdata);
          }
        });

        setState(() {
          widget.reseter();
          listmenucard.forEach((element) {
            element.counter = 0;
          });
        });
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

class Listmenu {
  String cag;
  String name;
  int price;
  int counter;

  Listmenu(this.cag, this.name, this.price, this.counter);
}

List<Listmenu> listmenucard = [];

class MenuCardList extends StatefulWidget {
  const MenuCardList({Key? key}) : super(key: key);
  @override
  @override
  _MenuCardListState createState() => _MenuCardListState();
}

class _MenuCardListState extends State<MenuCardList> {
  void initState() {
    super.initState();
    listmenucard = [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('menu')
          .orderBy("cag", descending: false)
          .get(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong Contact AiMZero Engineers');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (_, index) {
              listmenucard.add(Listmenu(
                snapshot.data!.docs[index]['cag'],
                snapshot.data!.docs[index]['food'],
                snapshot.data!.docs[index]['price'],
                0,
              ));
              return CounterMenuCard(
                  snapshot.data!.docs[index]['cag'],
                  snapshot.data!.docs[index]['food'],
                  snapshot.data!.docs[index]['price'],
                  listmenucard[index].counter,
                  index);
            });
      },
    );
  }
}

class CounterMenuCard extends StatefulWidget {
  final String cag;
  final String food;
  final int price;
  final int counter;
  final int index;
  CounterMenuCard(this.cag, this.food, this.price, this.counter, this.index);

  @override
  _CounterMenuCardState createState() => _CounterMenuCardState();
}

class _CounterMenuCardState extends State<CounterMenuCard> {
  int counter = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          listmenucard[widget.index].counter++;
          counter++;
        });
      },
      onLongPress: () {
        setState(() {
          if (counter > 0) {
            listmenucard[widget.index].counter--;
            print(listmenucard[widget.index].counter.toString());
          }
        });
      },
      child: MenuCard(widget.cag, widget.food, widget.price,
          listmenucard[widget.index].counter),
    );
  }
}

class MenuCard extends StatelessWidget {
  final String cag;
  final String food;
  final int price;
  final int counter;
  MenuCard(this.cag, this.food, this.price, this.counter);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (counter > 0) ? Colors.red : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    cag,
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text("Rs " + price.toString(),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
                flex: 3,
                child: Center(
                    child: Text(counter.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))))
          ],
        ),
      ),
    );
  }
}
