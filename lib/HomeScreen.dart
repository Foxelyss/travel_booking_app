import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Future<void> asda() async {
  http.Response asdsd = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  print(jsonDecode(asdsd.body));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Container(
          color: Colors.blueGrey,
          height: 120,
          width: 120,
          child: Text("Туры со скидкой 50%"),
        ),
        Container(
          color: Colors.blueGrey,
          height: 120,
          width: 120,
          child: Text("Туры со скидкой 50%"),
        ),
      ],
    ));
  }
}
