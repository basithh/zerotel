import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AddFood extends StatelessWidget {
  const AddFood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Menufood menufood = new Menufood("", "", 0);
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Text("Cag"),
              TextField(
                onChanged: (value) {
                  menufood.cag = value;
                },
              ),
              Text("food"),
              TextField(
                onChanged: (value) {
                  menufood.food = value;
                },
              ),
              Text("Price"),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                onChanged: (value) {
                  menufood.price = int.parse(value);
                },
              ),
              TextButton(
                  onPressed: () async {
                    Map<String, dynamic> menudata = {
                      "cag": menufood.cag,
                      "food": menufood.food,
                      "price": menufood.price
                    };
                    await FirebaseFirestore.instance
                        .collection("menu")
                        .add(menudata);
                  },
                  child: Text("Submit"))
            ],
          ),
        ),
      ),
    );
  }
}

class Menufood {
  String cag;
  String food;
  int price;

  Menufood(this.cag, this.food, this.price);
}
