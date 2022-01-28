import 'package:flutter/material.dart';
import 'package:zerotel/screen/order/menu/menu.dart';
import 'package:zerotel/screen/order/menu/recipt.dart';

class MenuOrder extends StatefulWidget {
  final String tableno;
  MenuOrder(this.tableno);

  @override
  _MenuOrderState createState() => _MenuOrderState();
}

class _MenuOrderState extends State<MenuOrder> {
  @override
  Widget build(BuildContext context) {
    final tab = new TabBar(tabs: <Tab>[
      new Tab(
        icon: new Icon(Icons.cabin),
        child: Text('Menu'),
      ),
      new Tab(
        icon: new Icon(Icons.receipt),
        child: Text('Recipt'),
      ),
    ]);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Table - ' + widget.tableno),
            bottom: tab,
          ),
          body: TabBarView(
            children: [Menutab(widget.tableno), ReciptPage(widget.tableno)],
          )),
    );
  }
}
