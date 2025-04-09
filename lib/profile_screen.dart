import 'dart:convert';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:travel_booking_app/config.dart';
import 'package:travel_booking_app/server_api.dart';
import 'package:travel_booking_app/ticket.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static final _formKey = GlobalKey<FormState>();
  static var myEmailController = TextEditingController();
  static var mypassController = MaskedTextController(mask: '0000 000000');
  static List<Ticket> _offers = <Ticket>[];

  Future<void> getbookings() async {
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/booking/books', {
      "transporting": '1',
      "email": myEmailController.text,
      "passport": mypassController.text
    }));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    _offers = Ticket.fromJsonList(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  Future<void> returnbook(transporting, id) async {
    http.Response response =
        await http.post(Uri.http(serverURI, '/api/booking/return', {
      "transporting": '$transporting',
      "email": myEmailController.text,
      'phone': '123',
      "passport": mypassController.text,
      'id': '$id'
    }));

    if (response.statusCode == 200) {
    } else {
      // throw Exception('Error');
    }
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
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      return createTransporting(
                          context, _offers[index], setModalState);
                    },
                  ),
                ),
              ),
            ),
          );
        });
      }),
    );
  }

  Widget createTransporting(context, Ticket obj, StateSetter modalSetter) {
    var time = "";
    var diff = obj.end.difference(obj.start);
    var hours = diff.inHours - diff.inDays * 24;

    if (diff.inDays != 0) {
      time += "${diff.inDays} ${ServerAPI.russianDays(diff.inDays)}";
    }
    if (hours != 0) {
      time += "$hours ${ServerAPI.russianHours(hours)}";
    }

    return Card(
      child: Container(
        padding: EdgeInsets.all(9),
        child: Column(
          spacing: 10,
          children: [
            Text.rich(
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
              TextSpan(
                text: "",
                children: <TextSpan>[
                  TextSpan(
                      text: "Маршрут: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: "${obj.name}\n",
                  ),
                  TextSpan(
                      text: "Компании: ",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(
                    text: "${obj.company}\n",
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(obj.startPoint),
                Expanded(child: Divider()),
                Text(obj.endPoint),
              ],
            ),
            Row(
              children: [
                Text.rich(
                  TextSpan(
                    text: "",
                    children: <TextSpan>[
                      TextSpan(
                          text: DateFormat('dd.MM.yyyy\n').format(obj.start),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: DateFormat('HH:mm').format(obj.start),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(children: <Widget>[
                    Expanded(child: Divider()),
                    Text("   $time   "),
                    Expanded(child: Divider()),
                  ]),
                ),
                Text.rich(
                  textAlign: TextAlign.end,
                  TextSpan(
                    text: "",
                    children: <TextSpan>[
                      TextSpan(
                          text: DateFormat('dd.MM.yyyy\n').format(obj.end),
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(
                        text: DateFormat('HH:mm').format(obj.end),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(obj.mean),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("№ чека ${obj.id}"),
                Text(
                    "${obj.price.toStringAsFixed(2).replaceFirst(".", ",")} ₽"),
                TextButton(
                    onPressed: DateTime.now().difference(obj.start).inSeconds <=
                            0
                        ? () {
                            returnBook(
                                context, obj.transporting, obj.id, modalSetter);

                            getbookings();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Обновление данных!')),
                            );
                          }
                        : null,
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: BorderSide(style: BorderStyle.none)),
                    child: Text("Отказаться"))
              ],
            ),
          ],
        ),
      ),
    );
  }

  void returnBook(context, transporting, id, StateSetter stateSetter) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Вы уверены?",
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 16),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                              style: TextButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  side: BorderSide(style: BorderStyle.none)),
                              onPressed: () {
                                _offers.removeAt(
                                    _offers.indexWhere((a) => a.id == id));
                                try {
                                  (() async {
                                    returnbook(transporting, id);
                                  }).withRetries(3);

                                  try {
                                    _offers.removeAt(
                                        _offers.indexWhere((a) => a.id == id));
                                  } catch (a) {
                                    ();
                                  }
                                } catch (q) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Проблема с сервисом!')),
                                  );
                                }
                                stateSetter(() {
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text("Подтвердить!")),
                        )
                      ],
                    )
                  ],
                ),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding:
            const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Реквизиты билетов",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(18))),
                    ),
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
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Серия и номер паспорта',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(18)))),
                    controller: mypassController,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 10) {
                        return 'Введите корректные данные паспорта';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 15, maxHeight: 30),
            ),
            Text(
              "Управление",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: ElevatedButton.icon(
                  icon: Icon(CupertinoIcons.tickets),
                  style: ButtonStyle(
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Просмотр данных!')),
                      );
                      getbookings();
                      try {
                        await getbookings.withRetries(3);
                      } catch (q) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Проблема с сервисом!')),
                          );
                        }
                      }

                      if (_offers.isEmpty) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Чеков нет или неверные данные!')),
                          );
                        }
                      } else {
                        if (context.mounted) {
                          bookings(context);
                        }
                      }
                    }
                  },
                  label: const Text('Чеки'),
                ))
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    icon: Icon(Icons.logout_rounded),
                    style: ButtonStyle(
                      alignment: Alignment.centerLeft,
                      iconColor: WidgetStatePropertyAll(Colors.red),
                    ),
                    label: Text(
                      "Выход из приложения",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ));
  }
}
