import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:travel_booking_app/Point.dart';
import 'package:travel_booking_app/Transport.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.title});
  final String title;

  @override
  State<SearchScreen> createState() => Searchscreen();
}

class Searchscreen extends State<SearchScreen> {
  List<Transport> _offers = <Transport>[];

  static List<Point> points = [];
  static int pointA = -1;
  static int pointB = -1;
  static String pointAStr = "";
  static String pointBStr = "";
  int counter = 0;
  DateTime? selectedDate;
  bool nextGoing = false;

  final serverURI = 'foxelyss-ms7c95.lan:8080';

  Future<void> getPoints() async {
    http.Response asdsd =
        await http.get(Uri.http(serverURI, '/api/search/points'));

    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    points = Point.fromJsonList(pointsJson);
  }

  Future<void> searchTransport() async {
    int wanted_time =
        nextGoing ? 0 : selectedDate!.millisecondsSinceEpoch ~/ 1000;
    print(wanted_time);
    http.Response asdsd =
        await http.get(Uri.http(serverURI, '/api/search/search', {
      'point_a': '$pointA',
      'point_b': '$pointB',
      'quantity': '12',
      'wanted_time': '$wanted_time'
    }));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  Future<void> getPoint() async {
    http.Response asdsd =
        await http.get(Uri.http(serverURI, '/api/search/points'));

    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    points = Point.fromJsonList(pointsJson);
  }

  //api/booking

  Future<void> book(int i) async {
    http.Response asdsd = await http
        .get(Uri.http(serverURI, '/api/booking/book', {'transporting': '$i'}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  Future<void> getbookings() async {
    http.Response asdsd = await http.get(Uri.http(serverURI,
        '/api/booking/books', {'point_a': '$pointA', 'point_b': '$pointB'}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

//api/business

  Future<void> addTransport() async {
    http.Response asdsd =
        await http.get(Uri.http(serverURI, '/api/business/add_transport', {}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

//api/about

  Future<void> aboutTransport() async {
    http.Response asdsd = await http.get(Uri.http(serverURI,
        '/api/about/transport', {'point_a': '$pointA', 'point_b': '$pointB'}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  Future<void> aboutCompany() async {
    http.Response asdsd = await http.get(Uri.http(serverURI,
        '/api/about/company', {'point_a': '$pointA', 'point_b': '$pointB'}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  //api/admin

  Future<void> addPoint() async {
    http.Response asdsd = await http.get(Uri.http(serverURI,
        '/api/admin/add_point', {'point_a': '$pointA', 'point_b': '$pointB'}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  Future<void> createCompany() async {
    http.Response asdsd = await http.get(Uri.http(
        serverURI,
        '/api/admin/create_company',
        {'point_a': '$pointA', 'point_b': '$pointB'}));
    print(pointA);
    print(pointB);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
    var pointsJson = jsonDecode(utf8.decode(asdsd.bodyBytes));
    setState(() {
      _offers = Transport.fromJsonList(pointsJson);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                        : () => {openBookingMenu(context, obj.id)},
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
                ? "За всё время"
                : DateFormat('На dd.MM.yyyy H:m\nПо близости ко времени')
                    .format(selectedDate!),
          )
        ],
      ),
    );
  }

  static Point none =
      Point(id: -1, town: "", name: "Выберете город", region: "region");
  void openSearchMenu(context) {
    getPoints();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            var date = selectedDate;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
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

  final _formKey = GlobalKey<FormState>();

  void openBookingMenu(context, asd) {
    showDialog(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            var date = selectedDate;
            return SafeArea(
              child: Container(
                padding: EdgeInsets.all(0),
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Введите ваши данные"),
                        IntrinsicWidth(
                            child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              TextFormField(
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Фамилия'),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration:
                                    InputDecoration.collapsed(hintText: 'Имя'),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Отчество'),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Пасспорт'),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Телефон'),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                decoration: InputDecoration.collapsed(
                                    hintText: 'Эл. почта'),
                                // The validator receives the text that the user has entered.
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter some text';
                                  }
                                  return null;
                                },
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Validate returns true if the form is valid, or false otherwise.
                                  if (_formKey.currentState!.validate()) {
                                    // If the form is valid, display a snackbar. In the real world,
                                    // you'd often call a server or save the information in a database.
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Принято!')),
                                    );
                                  }
                                },
                                child: const Text('Забронировать билет'),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
