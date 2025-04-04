import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:travel_booking_app/point.dart';
import 'package:travel_booking_app/search_result_screen.dart';
import 'package:travel_booking_app/server_api.dart';
import 'package:travel_booking_app/transport.dart';
import 'package:travel_booking_app/transporting_means.dart';

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

  DateTime? selectedDate;

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
        child: Column(
          children: [
            InkWell(
              child: searchHint(),
              onTap: () {
                openSearchMenu(context);
              },
            ),
            Expanded(
                child: ListViewScreen(
              pointA: pointA,
              pointB: pointB,
              mean: mean,
              wantedTime: 0,
            ))
          ],
        ),
      ),
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
            selectedDate == null
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

  static final dropStyle = DropDownDecoratorProps(
    decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(12, 12, 0, 0),
        border: OutlineInputBorder(),
        constraints: BoxConstraints(maxHeight: 40)),
  );

  int mean = -1;
  static Point none =
      Point(id: -1, town: "", name: "Выберете город", region: "region");
  static TransportingMeans allTransportingMeans =
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
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 500,
                  minHeight: MediaQuery.of(context).size.height * 0.33),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true,
                                  minTime: DateTime.now(),
                                  maxTime: DateTime(2030, 6, 7),
                                  onChanged: (date) {}, onConfirm: (date) {
                                var pickedDate = date;
                                pickedDate = date;
                                setModalState(() {
                                  selectedDate = pickedDate;
                                });
                                setState(() {
                                  selectedDate = pickedDate;
                                });
                              },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.ru);
                            },
                            label: Text(
                              "Выберете время",
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(date == null
                            ? "Предстоящие"
                            : DateFormat('dd MMMM yyyy HH:mm', "RU")
                                .format(date)),
                        TextButton.icon(
                            icon: Icon(Icons.clear_rounded),
                            onPressed: () {
                              setModalState(() {
                                date = null;
                                setState(() {
                                  selectedDate = null;
                                });
                              });
                            },
                            label: Text("Очистить")),
                      ],
                    ),
                    Row(
                      spacing: 30,
                      children: [
                        Text("От: "),
                        Expanded(
                          child: DropdownSearch<Point>(
                            decoratorProps: dropStyle,
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
                              setModalState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                    Row(
                      spacing: 30,
                      children: [
                        Text("В: "),
                        Expanded(
                          child: DropdownSearch<Point>(
                              items: (f, cs) => points,
                              decoratorProps: dropStyle,
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
                                setModalState(() {});
                              }),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownSearch<TransportingMeans>(
                              items: (f, cs) => means,
                              decoratorProps: dropStyle,
                              compareFn: (i, s) => i.isEqual(s),
                              selectedItem: means.firstWhere(
                                  (el) => el.id == mean,
                                  orElse: () => allTransportingMeans),
                              popupProps: PopupProps.menu(fit: FlexFit.loose),
                              onChanged: (newValue) {
                                setState(() {
                                  mean = newValue?.id ?? -1;
                                });
                              }),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                              onPressed: pointA == -1 || pointB == -1
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                    },
                              child: Text("Искать!")),
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        });
  }
}
