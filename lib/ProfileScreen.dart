import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

Future<void> asda() async {
  http.Response asdsd = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  print(jsonDecode(asdsd.body));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static var myphoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        TextField(
          decoration: InputDecoration.collapsed(hintText: 'Эл. почта'),
          controller: myphoneController,
        ),
        TextButton(onPressed: asda, child: Text("Чеки")),
        TextButton(onPressed: asda, child: Text("Отмена бронирования")),
        TextButton(
            onPressed: () {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            },
            child: Text("Выход"))
      ],
    ));
  }
}
