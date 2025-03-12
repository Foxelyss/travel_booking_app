import 'dart:convert';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'dart:async';

final serverURI = 'foxelyss-ms7c95.lan:8080';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static var _formKey = GlobalKey<FormState>();
  static var myEmailController = TextEditingController();
  static var mypassController = MaskedTextController(mask: '0000 000000');
  static List<dynamic> _offers = <dynamic>[];

  Future<void> getbookings() async {
    http.Response asdsd =
        await http.get(Uri.http(serverURI, '/api/booking/books', {
      "transporting": '1',
      "email": '${myEmailController.text}',
      "passport": '${mypassController.text}'
    }));

    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    _offers = jsonDecode(utf8.decode(asdsd.bodyBytes)) as List;
  }

  Future<void> returnbook(transporting, id) async {
    http.Response asdsd =
        await http.post(Uri.http(serverURI, '/api/booking/return', {
      "transporting": '$transporting',
      "email": myEmailController.text,
      'phone': '123',
      "passport": mypassController.text,
      'id': '$id'
    }));

    print(utf8.decode(asdsd.bodyBytes));
    // var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
  }

  void bookings(context1) {
    Navigator.push(
      context1,
      MaterialPageRoute(builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Scaffold(
              appBar: AppBar(title: const Text('Чеки')),
              body: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 450),
                      child: ListView.builder(
                        itemCount: _offers.length,
                        itemBuilder: (context, index) {
                          return createTransporting(context, _offers[index]);
                        },
                      ),
                    ),
                  )));
        });
      }),
    );
  }

  Widget createTransporting(context, obj) {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.white),
          color: Color.fromARGB(255, 219, 219, 219)),
      child: Column(
        children: [
          Text("Маршрут: ${obj["name"]} Компании ${obj["company_name"]}"),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Из:\n${obj["start_point"]}"),
              Text(
                  "На время:\n${DateFormat('dd.MM.yyyy\nH:m').format(DateTime.parse(obj["arrival"]))}"),
              Text("В:\n${obj["end_point"]}")
            ],
          ),
          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("№ чека ${obj["id"]}"),
              TextButton(
                  onPressed: () {
                    returnBook(context, int.parse(obj["transporting"]),
                        int.parse(obj["id"]));
                    getbookings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Обновление данных!')),
                    );
                  },
                  child: Text("Отказаться"))
            ],
          ),
        ],
      ),
    );
  }

  void returnBook(context, transporting, id) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                      onPressed: () {
                        returnbook(transporting, id);
                        Navigator.of(context).pop();
                      },
                      child: Text("Подтвердить!")),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 4, right: 4, top: 2, bottom: 9),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Эл. почта:"),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration:
                        InputDecoration.collapsed(hintText: 'Эл. почта'),
                    controller: myEmailController,
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      var re = RegExp(
                          r'^([A-Za-z0-9.]{1,50})@([A-Za-z0-9.]{1,50})\.([A-Za-z0-9.]{1,5})$');

                      if (value == null ||
                          value.isEmpty ||
                          !re.hasMatch(value)) {
                        return 'Введите правильный эл. адрес';
                      }
                      return null;
                    },
                  ),
                  Text("Паспорт:"),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration.collapsed(hintText: 'Паспорт'),
                    controller: mypassController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Просмотр данных!')),
                  );

                  await getbookings();

                  if (_offers.isEmpty) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Чеков нет или неверные данные!')),
                    );
                  } else {
                    bookings(context);
                  }
                }
              },
              child: const Text('Чеки'),
            ),
            Spacer(),
            TextButton(
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
                child: Text("Выход"))
          ],
        ));
  }
}
