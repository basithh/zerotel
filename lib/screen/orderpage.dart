import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zerotel/screen/order/menu/menumain.dart';
import 'package:zerotel/screen/order/order/openorder.dart';
import 'package:zerotel/screen/order/ordermain.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[TableLane(), OpenOrder()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table/Parcel'),
      ),
      body: Center(child: _widgetOptions[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Table',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe),
            label: 'Orders',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}

class TableLane extends StatelessWidget {
  const TableLane({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Query tablelist = FirebaseFirestore.instance
        .collection("table")
        .orderBy("tablename", descending: false);
    return FutureBuilder(
      future: tablelist.get(),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError) {
          return Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        return SafeArea(
          child: GridView.builder(
              itemCount: snapshot.data.docs.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return TableCard(snapshot.data!.docs[index]["tablename"]);
              }),
        );
      },
    );
  }
}

class TableCard extends StatelessWidget {
  final String tableno;
  TableCard(this.tableno);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return MenuOrder(tableno);
            }),
          );
        },
        child: Center(
            child: Text(
          tableno,
          style: TextStyle(fontSize: 32),
        )),
      ),
    );
  }
}
