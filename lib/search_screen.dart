import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:travel_booking_app/point.dart';
import 'package:travel_booking_app/search_result_screen.dart';
import 'package:travel_booking_app/server_api.dart';
import 'package:travel_booking_app/transport.dart';
import 'package:travel_booking_app/transporting_means.dart';
import 'package:travel_booking_app/config.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.title});
  final String title;

  @override
  State<SearchScreen> createState() => Searchscreen();
}

class Searchscreen extends State<SearchScreen> {
  List<Transport> offers = <Transport>[];

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
    points = await ServerAPI.getPoints();
  }

  Future<void> getMeans() async {
    means = await ServerAPI.getMeans();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
          padding: EdgeInsets.all(6),
          child: Column(children: [
            InkWell(
              child: searchHint(),
              onTap: () {
                openSearchMenu(context);
              },
            ),
            Expanded(
              child: ListViewScreen(),
            )
          ])),
    );
  }

  Widget searchHint() {
    return Container(
      padding: EdgeInsets.only(bottom: 22),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("От"), Text("До")],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(pointAStr,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(pointBStr,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
          Divider(),
          Text(
            selectedDate == null || nextGoing
                ? (pointA == -1
                    ? "Нажмите чтобы изменить критерии поиска"
                    : "За всё время")
                : DateFormat('Ближайшие к dd.MM.yyyy HH:mm')
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
                              showSearchBox: true, fit: FlexFit.loose),
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
                                showSearchBox: true, fit: FlexFit.loose),
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
}
