import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

Future<void> asda() async {
  http.Response asdsd = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  print(jsonDecode(asdsd.body));
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text("Учётка  "),
        // TextButton(onPressed: asda, child: Text("Обновить данные")),
        TextButton(onPressed: asda, child: Text("Чеки")),
        TextButton(onPressed: asda, child: Text("Отмена бронирования")),
        TextButton(onPressed: asda, child: Text("Выход"))
      ],
    ));
  }
}
