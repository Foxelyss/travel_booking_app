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
      padding: const EdgeInsets.all(0.0),
      child: Column(
        children: [
          InkWell(
            child: searchHint(),
            onTap: () {
              openSearchMenu(context);
            },
          ),
          SizedBox(
            height: 16,
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
    );
  }

  Widget searchHint() {
    return Container(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
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
        constraints: BoxConstraints(minHeight: 50)),
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
        showDragHandle: true,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            var date = selectedDate;
            return ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: 400,
                  minHeight: MediaQuery.of(context).size.height * 0.23),
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      "Выберите место отправления и прибытия",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
                    ),
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

                                selectedDate = null;
                              });
                            },
                            label: Text("Очистить")),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownSearch<Point>(
                            decoratorProps: DropDownDecoratorProps(
                              decoration: InputDecoration(
                                  labelText: "Место отправления",
                                  contentPadding:
                                      EdgeInsets.fromLTRB(12, 12, 0, 0),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(18))),
                                  constraints: BoxConstraints(minHeight: 50)),
                            ),
                            items: (f, cs) => points,
                            compareFn: (i, s) => i.isEqual(s),
                            selectedItem: selectedDeparture(),
                            popupProps: PopupProps.menu(
                                showSearchBox: true, fit: FlexFit.loose),
                            onChanged: (newValue) {
                              pointA = newValue?.id ?? -1;
                              pointAStr = newValue?.name ?? "Нет";

                              setModalState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownSearch<Point>(
                              items: (f, cs) => points,
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                    labelText: "Место прибытия",
                                    contentPadding:
                                        EdgeInsets.fromLTRB(12, 12, 0, 0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18))),
                                    constraints: BoxConstraints(minHeight: 50)),
                              ),
                              compareFn: (i, s) => i.isEqual(s),
                              selectedItem: selectedArrival(),
                              popupProps: PopupProps.menu(
                                  showSearchBox: true, fit: FlexFit.loose),
                              onChanged: (newValue) {
                                pointB = newValue?.id ?? -1;
                                pointBStr = newValue?.name ?? "Нет";

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
                              decoratorProps: DropDownDecoratorProps(
                                decoration: InputDecoration(
                                    labelText: "Транспорт",
                                    contentPadding:
                                        EdgeInsets.fromLTRB(12, 12, 0, 0),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(18))),
                                    constraints: BoxConstraints(minHeight: 50)),
                              ),
                              compareFn: (i, s) => i.isEqual(s),
                              selectedItem: selectedMean(),
                              popupProps: PopupProps.menu(fit: FlexFit.loose),
                              onChanged: (newValue) {
                                setModalState(() {
                                  mean = newValue?.id ?? -1;
                                });
                              }),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        }).whenComplete(() {
      setState(() {});
    });
  }

  Point? selectedDeparture() {
    Point a = points.firstWhere((el) => el.id == pointA, orElse: () => none);

    if (a == none) {
      return null;
    }

    return a;
  }

  Point? selectedArrival() {
    Point a = points.firstWhere((el) => el.id == pointB, orElse: () => none);

    if (a == none) {
      return null;
    }

    return a;
  }

  static final TransportingMeans noneMean =
      TransportingMeans(id: -2, name: "asd");

  TransportingMeans? selectedMean() {
    TransportingMeans a =
        means.firstWhere((el) => el.id == mean, orElse: () => noneMean);

    if (a == noneMean) {
      return null;
    }

    return a;
  }

  void selectDestination(int id, String name) {
    pointA = id;
    pointAStr = name;
    openSearchMenu(context);
  }
}
