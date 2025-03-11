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
      child: Expanded(
          child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 12,
            children: <Widget>[
              Container(
                color: Colors.blueGrey,
                height: 320,
                width: 320,
                child: Image(image: AssetImage('assets/ad1.png')),
              ),
              Container(
                color: Colors.blueGrey,
                height: 320,
                width: 320,
                child: Image(image: AssetImage('assets/ad2.png')),
              ),
            ]),
      )),
    );
  }
}
