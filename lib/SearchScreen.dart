import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:travel_booking_app/Point.dart';
import 'package:travel_booking_app/Transport.dart';
import 'package:travel_booking_app/TransportingMeans.dart';
import 'package:travel_booking_app/Config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.title});
  final String title;

  @override
  State<SearchScreen> createState() => Searchscreen();
}

class Searchscreen extends State<SearchScreen> {
  List<Transport> _offers = <Transport>[];

  static List<Point> points = [];
  static List<TransportingMeans> means = [];
  static int pointA = -1;
  static int pointB = -1;
  static String pointAStr = "";
  static String pointBStr = "";
  int counter = 0;
  DateTime? selectedDate;
  bool nextGoing = false;

  Future<void> getPoints() async {
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/search/points'));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));
    points = Point.fromJsonList(pointsJson);
  }

  Future<void> getMeans() async {
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/search/means'));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
    var meansJson = jsonDecode(utf8.decode(response.bodyBytes));
    means = TransportingMeans.fromJsonList(meansJson);
    means.add(asd123);
  }

  Future<void> searchTransport() async {
    int wantedTime =
        nextGoing ? 0 : selectedDate!.millisecondsSinceEpoch ~/ 1000;
    print(wantedTime);
    int _mean = mean == null ? -1 : mean!;
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/search/search', {
      'point_a': '$pointA',
      'point_b': '$pointB',
      'quantity': '12',
      'wanted_time': '$wantedTime',
      'mean': '$_mean'
    }));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));

    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  Future<void> book(int transporting, String name, String surname,
      String middleName, String email, int passport, int phone) async {
    http.Response response =
        await http.post(Uri.http(serverURI, '/api/booking/book', {
      "transporting": "$transporting",
      "name": name,
      "surname": surname,
      "middle_name": middleName,
      "email": email,
      "passport": "$passport",
      "phone": "$phone"
    }));
    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(children: [
          InkWell(
            child: searchHint(),
            onTap: () {
              openSearchMenu(context);
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _offers.length,
              itemBuilder: (context, index) {
                return createTransporting(_offers[index]);
              },
            ),
          )
        ]));
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
      child: Container(
          child: Container(

              // color: Colors.white,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2, color: Colors.white),
                  color: Color.fromARGB(255, 181, 229, 236)),
              child: Column(children: [
                Container(
                  // color: Colors.amber,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 2, color: Colors.white),
                      color: Color.fromARGB(255, 54, 180, 199)),
                  child: Column(
                    children: [
                      Text(time),
                      Row(
                        children: [
                          Text(DateFormat('dd.MM.yyyy\nH:m').format(obj.start)),
                          Expanded(
                            child: Row(children: <Widget>[
                              Expanded(child: Divider()),
                              Text(obj.mean),
                              Expanded(child: Divider()),
                            ]),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy\nH:m').format(obj.end),
                            textAlign: TextAlign.right,
                          )
                        ],
                      ),
                      Text(obj.company),
                    ],
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text("${obj.freespacecount}/${obj.spacecount}"),
                  TextButton(
                    onPressed: obj.freespacecount == 0
                        ? null
                        : () => {openAboutTransportMenu(context, obj)},
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(Colors.blueAccent),
                      foregroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 255, 255, 255)),
                    ),
                    child: Text("${obj.price}₽"),
                  )
                ])
              ]))),
    );
  }

  Widget searchHint() {
    return Container(
      padding: EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("От"), Text("До")],
          ),
          Row(
            children: [
              Text(pointAStr),
              Expanded(child: Divider()),
              Text(
                pointBStr,
                textAlign: TextAlign.right,
              )
            ],
          ),
          Text(
            selectedDate == null || nextGoing
                ? (pointA == -1
                    ? "Нажмите чтобы изменить критерии поиска"
                    : "За всё время")
                : DateFormat('На dd.MM.yyyy H:m\nПо близости ко времени')
                    .format(selectedDate!),
          )
        ],
      ),
    );
  }

  int? mean;
  static Point none =
      Point(id: -1, town: "", name: "Выберете город", region: "region");
  static TransportingMeans asd123 =
      TransportingMeans(id: -1, name: "Все виды транспорта");
  void openSearchMenu(context) {
    getPoints();
    getMeans();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            var date = selectedDate;
            return SizedBox(
              // height: MediaQuery.of(context).size.height * 0.3,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: !nextGoing
                              ? () async {
                                  DatePicker.showDateTimePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime.now(),
                                      maxTime: DateTime(2030, 6, 7),
                                      onChanged: (date) {
                                    print('change $date');
                                  }, onConfirm: (date) {
                                    var pickedDate = date;
                                    pickedDate = date;
                                    setModalState(() {
                                      selectedDate = pickedDate;
                                    });
                                    setState(() {
                                      selectedDate = pickedDate;
                                    });
                                    print('confirm $date');
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.ru);
                                }
                              : null,
                          label: Text(
                            date == null
                                ? "Выберете время"
                                : DateFormat('dd.MM.yyyy H:m').format(date),
                          ),
                        ),
                        Row(
                          children: [
                            Text("Грядущие"),
                            Checkbox(
                              value: nextGoing,
                              onChanged: (bool? a) {
                                setModalState(() {
                                  nextGoing = a!;
                                });
                                setState(() {});
                              },
                            )
                          ],
                        )
                      ]),
                    ],
                  ),
                  Row(
                    children: [
                      Text("От: "),
                      Expanded(
                        child: DropdownSearch<Point>(
                          items: (f, cs) => points,
                          compareFn: (i, s) => i.isEqual(s),
                          selectedItem: points.firstWhere(
                              (el) => el.id == pointA,
                              orElse: () => none),
                          popupProps: PopupProps.menu(
                              showSearchBox: true,
                              disabledItemFn: (item) => item == 'Item 3',
                              fit: FlexFit.loose),
                          onChanged: (newValue) {
                            pointA = newValue?.id ?? -1;
                            pointAStr = newValue?.name ?? "Нет";
                            setState(() {});
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Text("В: "),
                      Expanded(
                        child: DropdownSearch<Point>(
                            items: (f, cs) => points,
                            compareFn: (i, s) => i.isEqual(s),
                            selectedItem: points.firstWhere(
                                (el) => el.id == pointB,
                                orElse: () => none),
                            popupProps: PopupProps.menu(
                                showSearchBox: true,
                                disabledItemFn: (item) => item == 'Item 3',
                                fit: FlexFit.loose),
                            onChanged: (newValue) {
                              pointB = newValue?.id ?? -1;
                              pointBStr = newValue?.name ?? "Нет";
                              setState(() {});
                            }),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownSearch<TransportingMeans>(
                            items: (f, cs) => means,
                            compareFn: (i, s) => i.isEqual(s),
                            selectedItem: means.firstWhere(
                                (el) => el.id == mean,
                                orElse: () => asd123),
                            popupProps: PopupProps.menu(fit: FlexFit.loose),
                            onChanged: (newValue) {
                              mean = newValue?.id ?? -1;
                            }),
                      )
                    ],
                  ),
                  TextButton(
                      onPressed: pointA == -1 ||
                              pointB == -1 ||
                              (nextGoing == false && selectedDate == null)
                          ? null
                          : () {
                              setState(() {
                                searchTransport();
                                print(123123);
                                counter++;
                              });
                              Navigator.of(context).pop();
                            },
                      child: Text("Искать!")),
                ],
              ),
            );
          });
        });
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
          var date = selectedDate;
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
                                Text(transport.start_point),
                                Expanded(child: Divider()),
                                Text(
                                  transport.end_point,
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                            Row(
                              children: [
                                Text(DateFormat('dd.MM.yyyy\nH:m')
                                    .format(transport.start)),
                                Expanded(
                                  child: Divider(),
                                ),
                                Text(
                                  DateFormat('dd.MM.yyyy\nH:m')
                                      .format(transport.end),
                                  textAlign: TextAlign.right,
                                )
                              ],
                            ),
                            Text('Приблизительное время поездки: $time'),
                            Text(
                                'Выполняется компанией ${transport.company}. Осуществляется перевозка ${transport.mean}'),
                            Chip(
                                label: Text(
                                    "${transport.freespacecount}/${transport.spacecount} мест свободны")),
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
                                  book(
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
