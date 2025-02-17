import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:travel_booking_app/Point.dart';

class SearchScreen extends StatelessWidget {
  // static const Widget meow = ListView();
  static const List<Widget> _offers = <Widget>[];
  static const List<Widget> _query = <Widget>[];

  static List<Point> points = [];
  static int _a = 0;
  static int _b = 0;

  Future<void> getPoints() async {
    http.Response asdsd = await http
        .get(Uri.http('foxelyss-ms7c95.lan:8080', '/api/search/points'));

    var points_json = jsonDecode(utf8.decode(asdsd.bodyBytes));
    points = Point.fromJsonList(points_json);
  }

  Future<void> getTransport() async {
    http.Response asdsd = await http.get(Uri.http('foxelyss-ms7c95.lan:8080',
        '/api/search/search', {'point_a': '$_a', 'point_b': '$_b'}));
    print(_a);
    print(_b);
    print(jsonDecode(utf8.decode(asdsd.bodyBytes)));
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
        child: ListView(children: _offers),
      )
    ]));
  }

  Widget createTransporting() {
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
                      Text("12 часов"),
                      Row(
                        children: [
                          Text("02:20"),
                          Expanded(
                            child: Row(children: <Widget>[
                              Expanded(child: Divider()),
                              Text("Ж/Д"),
                              Expanded(child: Divider()),
                            ]),
                          ),
                          Text(
                            "14:20",
                            textAlign: TextAlign.right,
                          )
                        ],
                      ),
                      Text("ОАО РЖД"),
                    ],
                  ),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(
                    onPressed: () => {},
                    child: Text("13.000₽"),
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.blueAccent),
                      foregroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 255, 255, 255)),
                    ),
                  )
                ])
              ]))),
    );
  }

  Widget searchHint() {
    return Container(
      padding: EdgeInsets.only(bottom: 30),
      child: Column(
        children: [
          Row(
            children: [Text("От"), Text("До")],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          Row(
            children: [
              Text("Томск"),
              Expanded(child: Divider()),
              Text(
                "Владивосток",
                textAlign: TextAlign.right,
              )
            ],
          ),
        ],
      ),
    );
  }

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  void openSearchMenu(context) {
    getPoints();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            var date = selectedDate;
            var time = selectedTime;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(children: [
                        Text(
                          date == null
                              ? "You haven't picked a date yet."
                              : DateFormat('MM-dd-yyyy').format(date),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            var pickedDate = await showDatePicker(
                              context: context,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2019),
                              lastDate: DateTime(2050),
                            );

                            setModalState(() {
                              selectedDate = pickedDate;
                            });
                          },
                          label: const Text('Pick a date'),
                        )
                      ]),
                      Column(children: [
                        Text(
                          time == null
                              ? "You haven't picked a time yet."
                              : time.format(context),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            var pickedTime = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.dial,
                              initialTime: TimeOfDay.now(),
                            );

                            setModalState(() {
                              selectedTime = pickedTime;
                            });
                          },
                          label: const Text('Pick a date'),
                        )
                      ])
                    ],
                  ),
                  Row(
                    children: [
                      Text("От: "),
                      Expanded(
                        child: DropdownSearch<Point>(
                          items: (f, cs) => points,
                          compareFn: (i, s) => i.isEqual(s),
                          popupProps: PopupProps.menu(
                              showSearchBox: true,
                              disabledItemFn: (item) => item == 'Item 3',
                              fit: FlexFit.loose),
                          onChanged: (newValue) => {_a = newValue?.id ?? 0},
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
                            popupProps: PopupProps.menu(
                                showSearchBox: true,
                                disabledItemFn: (item) => item == 'Item 3',
                                fit: FlexFit.loose),
                            onChanged: (newValue) => {_b = newValue?.id ?? 0}),
                      )
                    ],
                  ),
                  TextButton(
                      onPressed: () => {getTransport()}, child: Text("Искать!"))
                ],
              ),
            );
          });
        });
  }

  void openTransport(context) {
    getPoints();
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            var date = selectedDate;
            var time = selectedTime;
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  Row(
                    children: [
                      Column(children: [
                        Text(
                          date == null
                              ? "You haven't picked a date yet."
                              : DateFormat('MM-dd-yyyy').format(date),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            var pickedDate = await showDatePicker(
                              context: context,
                              initialEntryMode:
                                  DatePickerEntryMode.calendarOnly,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2019),
                              lastDate: DateTime(2050),
                            );

                            setModalState(() {
                              selectedDate = pickedDate;
                            });
                          },
                          label: const Text('Pick a date'),
                        )
                      ]),
                      Column(children: [
                        Text(
                          time == null
                              ? "You haven't picked a time yet."
                              : time.format(context),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            var pickedTime = await showTimePicker(
                              context: context,
                              initialEntryMode: TimePickerEntryMode.dial,
                              initialTime: TimeOfDay.now(),
                            );

                            setModalState(() {
                              selectedTime = pickedTime;
                            });
                          },
                          label: const Text('Pick a date'),
                        )
                      ])
                    ],
                  ),
                  Row(
                    children: [
                      Text("От: "),
                      Expanded(
                        child: DropdownSearch<Point>(
                          items: (f, cs) => points,
                          compareFn: (i, s) => i.isEqual(s),
                          popupProps: PopupProps.menu(
                              showSearchBox: true,
                              disabledItemFn: (item) => item == 'Item 3',
                              fit: FlexFit.loose),
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
                          popupProps: PopupProps.menu(
                              showSearchBox: true,
                              disabledItemFn: (item) => item == 'Item 3',
                              fit: FlexFit.loose),
                        ),
                      )
                    ],
                  ),
                  TextButton(onPressed: () => {}, child: Text("Искать!"))
                ],
              ),
            );
          });
        });
  }
}
