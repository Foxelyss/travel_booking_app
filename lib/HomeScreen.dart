import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

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
              SizedBox(
                height: 320,
                width: 320,
                child: Image(image: AssetImage('assets/ad1.png')),
              ),
              SizedBox(
                height: 320,
                width: 320,
                child: Image(image: AssetImage('assets/ad2.png')),
              ),
            ]),
      )),
    );
  }
}
