import 'dart:convert';

import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:travel_booking_app/Config.dart';
import 'package:travel_booking_app/ServerAPI.dart';
import 'package:travel_booking_app/Transport.dart';

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  late final _pagingController = PagingController<int, Transport>(
    getNextPageKey: (state) => (state.keys?.last ?? 0) + 1,
    fetchPage: (pageKey) => searchTransport(pageKey),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) =>
            PagedListView<int, Transport>(
          state: state,
          fetchNextPage: fetchNextPage,
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => createTransporting(item),
          ),
        ),
      );

  int wantedTime = 0;
  int mean = -1;
  int pointA = 1;
  int pointB = 2;

  Future<List<Transport>> searchTransport(int page) async {
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/search/search', {
      'point_a': '$pointA',
      'point_b': '$pointB',
      'quantity': '12',
      'wanted_time': '$wantedTime',
      'mean': '$mean',
      'page': '$page'
    }));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));

    return Transport.fromJsonList(pointsJson);
  }

  Widget createTransporting(Transport obj) {
    var time = "";
    var diff = obj.end.difference(obj.start);
    var hours = diff.inHours - diff.inDays * 24;

    if (diff.inDays != 0) {
      time += "${diff.inDays} Дней ";
    }
    if (hours != 0) {
      time += "$hours Часов";
    }

    return DefaultTextStyle(
        style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255)),
        child: Card(
            child: InkWell(
                onTap: obj.freeSpaceCount == 0
                    ? null
                    : () => {openAboutTransportMenu(context, obj)},
                child: Container(
                    padding: EdgeInsets.all(9),
                    child: Column(
                      spacing: 10,
                      children: [
                        Text(obj.mean),
                        Row(
                          children: [
                            Text(DateFormat('dd.MM.yyyy\nHH:mm')
                                .format(obj.start)),
                            Expanded(
                              child: Row(children: <Widget>[
                                Expanded(child: Divider()),
                                Text(time),
                                Expanded(child: Divider()),
                              ]),
                            ),
                            Text(
                              DateFormat('dd.MM.yyyy\nHH:mm').format(obj.end),
                              textAlign: TextAlign.right,
                            )
                          ],
                        ),
                        Text(obj.company),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          spacing: 6,
                          children: [
                            Text("${obj.freeSpaceCount}/${obj.spaceCount}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300)),
                            Text("${obj.price}₽",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                          ],
                        )
                      ],
                    )))));
  }

  void openAboutTransportMenu(context, Transport transport) {
    var time = "";
    var diff = transport.end.difference(transport.start);
    var hours = diff.inHours - diff.inDays * 24;

    if (diff.inDays != 0) {
      time += "${diff.inDays} Дней ";
    }
    if (hours != 0) {
      time += "$hours Часов";
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Scaffold(
              appBar: AppBar(title: const Text('О транспорте')),
              body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Маршрут: ${transport.name}'),
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color.fromARGB(
                                              255, 0, 189, 183)),
                                      color:
                                          Color.fromARGB(255, 154, 255, 252)),
                                  child: Text(transport.startPoint),
                                ),
                                Expanded(child: Divider()),
                                Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          width: 2,
                                          color: const Color.fromARGB(
                                              255, 254, 215, 102)),
                                      color:
                                          Color.fromARGB(255, 255, 248, 225)),
                                  child: Text(
                                    transport.endPoint,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Chip(
                                    label: Text(DateFormat('dd.MM.yyyy HH:mm')
                                        .format(transport.start))),
                                Expanded(
                                  child: Divider(),
                                ),
                                Chip(
                                    label: Text(
                                  DateFormat('dd.MM.yyyy HH:mm')
                                      .format(transport.end),
                                ))
                              ],
                            ),
                            Text('Приблизительное время поездки: $time'),
                            Text(
                                'Выполняется компанией ${transport.company}\nОсуществляется перевозка ${transport.mean}'),
                            Chip(
                                label: Text(
                                    "${transport.freeSpaceCount}/${transport.spaceCount} мест свободны")),
                            ElevatedButton(
                              onPressed: () {
                                openBookingMenu(context, transport.id);
                              },
                              child: const Text('Забронировать'),
                            ),
                          ],
                        )),
                  )));
        });
      }),
    );

    // openBookingMenu(context, obj.id);
  }

  final _formKey = GlobalKey<FormState>();
  final mysurnameController = TextEditingController();
  final mynameController = TextEditingController();
  final mymidnameController = TextEditingController();
  final mypassController = MaskedTextController(mask: '0000 000000');
  final myphoneController = MaskedTextController(mask: '8 (000) 000 00-00');
  final myMailController = TextEditingController();

  String? nameTest(value) {
    var reg = RegExp("^([А-Яа-я]{3,30})\$");
    if (value == null || value.isEmpty || !reg.hasMatch(value)) {
      return 'Введите настоящие данные';
    }
    return null;
  }

  void openBookingMenu(context1, idx) {
    showDialog(
        context: context1,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(0),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text("Введите ваши данные"),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Фамилия"),
                              TextFormField(
                                  decoration: InputDecoration.collapsed(
                                      hintText: 'Фамилия'),
                                  controller: mysurnameController,
                                  validator: nameTest),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Имя"),
                              TextFormField(
                                  decoration: InputDecoration.collapsed(
                                      hintText: 'Имя'),
                                  controller: mynameController,
                                  validator: nameTest),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Отчество"),
                              TextFormField(
                                  decoration: InputDecoration.collapsed(
                                      hintText: 'Отчество'),
                                  controller: mymidnameController,
                                  validator: nameTest),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Паспорт"),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Паспорт'),
                                controller: mypassController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 11) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Телефон"),
                              TextFormField(
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Телефон'),
                                controller: myphoneController,
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.length < 17) {
                                    return 'Введите правильный телефон';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Эл. почта"),
                              TextFormField(
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Эл. почта'),
                                controller: myMailController,
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
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  Serverapi.book(
                                      idx,
                                      mynameController.text,
                                      mysurnameController.text,
                                      mymidnameController.text,
                                      myMailController.text,
                                      int.parse(mypassController.unmasked),
                                      int.parse(myphoneController.unmasked));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Принято!')),
                                  );
                                } catch (asd) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Не забронировано из-за соединения с сетью!')),
                                  );
                                }

                                Navigator.of(context).pop();
                                Navigator.of(context1).pop();
                              }
                            },
                            child: const Text('Забронировать билет'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
