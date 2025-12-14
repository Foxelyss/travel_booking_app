import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:travel_booking_app/server.dart';
import 'package:travel_booking_app/model/transport.dart';
import 'package:travel_booking_app/paginator/pagination_errors.dart';
import 'package:travel_booking_app/paginator/pagination_messages.dart';

class ListViewScreen extends StatefulWidget {
  final int pointA;
  final int pointB;
  final DateTime wantedTime;
  final int mean;

  const ListViewScreen({
    super.key,
    required this.pointA,
    required this.pointB,
    required this.wantedTime,
    required this.mean,
  });

  @override
  State<ListViewScreen> createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  bool nextPage = true;

  late final _pagingController = PagingController<int, Transport>(
    getNextPageKey: (state) {
      int next = (state.keys?.last ?? -1) + 1;
      return nextPage ? next : null;
    },
    fetchPage: (pageKey) => searchTransport(pageKey),
  );

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ListViewScreen oldWidget) {
    nextPage = true;
    _pagingController.refresh();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return PagingListener(
      controller: _pagingController,
      builder: (context, state, fetchNextPage) => RefreshIndicator(
          onRefresh: () => Future.sync(
                () {
                  nextPage = true;
                  _pagingController.refresh();
                },
              ),
          child: PagedListView<int, Transport>(
            padding: EdgeInsets.symmetric(horizontal: 16),
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) => createTransporting(item),
              firstPageErrorIndicatorBuilder: (context) =>
                  CustomFirstPageError(pagingController: _pagingController),
              newPageErrorIndicatorBuilder: (context) =>
                  CustomNewPageError(pagingController: _pagingController),
              noItemsFoundIndicatorBuilder: (context) =>
                  NoItemsFoundIndicator(),
              noMoreItemsIndicatorBuilder: (context) => Divider(),
            ),
          )),
    );
  }

  Future<List<Transport>> searchTransport(int page) async {
    var list = await Server.searchTransport(
        widget.pointA, widget.pointB, widget.wantedTime, widget.mean, page);

    if (list.isEmpty) {
      nextPage = false;
    }

    return list;
  }

  Widget createTransporting(Transport obj) {
    var time = "";
    var diff = obj.end.difference(obj.start);
    var hours = diff.inHours - diff.inDays * 24;

    if (diff.inDays != 0) {
      time += "${diff.inDays} ${Server.russianDays(diff.inDays)}";
    }
    if (hours != 0) {
      time += "$hours ${Server.russianHours(hours)}";
    }

    return Card(
      child: InkWell(
        onTap: obj.freeSpaceCount == 0
            ? null
            : () => {openAboutTransportMenu(context, obj)},
        child: Container(
          padding: EdgeInsets.all(9),
          child: Column(
            spacing: 10,
            children: [
              Text(obj.mean.join(", ")),
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
              Text(obj.company),
              Divider(
                height: 6,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 6,
                children: [
                  Text("${obj.freeSpaceCount}/${obj.spaceCount}",
                      style: const TextStyle(fontWeight: FontWeight.w300)),
                  Text(
                      "${obj.price.toStringAsFixed(2).replaceFirst(".", ",")} ₽",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void openAboutTransportMenu(context, Transport transport) {
    var time = "";
    var diff = transport.end.difference(transport.start);
    var hours = diff.inHours - diff.inDays * 24;

    if (diff.inDays != 0) {
      time += "${diff.inDays} ${Server.russianDays(diff.inDays)}";
    }
    if (hours != 0) {
      time += "$hours ${Server.russianHours(hours)}";
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Scaffold(
            appBar: AppBar(title: const Text('О транспорте')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 450),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text.rich(
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 20),
                          TextSpan(
                            text: "",
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Маршрут: ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: transport.name,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Row(
                        children: [
                          Text.rich(
                            textAlign: TextAlign.start,
                            TextSpan(
                              text: "",
                              children: <TextSpan>[
                                TextSpan(
                                    text: "${transport.startPoint.name}\n",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: transport.startPoint.region,
                                ),
                              ],
                            ),
                          ),
                          Spacer(),
                          Text.rich(
                            textAlign: TextAlign.end,
                            TextSpan(
                              text: "",
                              children: <TextSpan>[
                                TextSpan(
                                    text: "${transport.endPoint.name}\n",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: transport.endPoint.region,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 32),
                        child: Divider(),
                      ),
                      Row(
                        children: [
                          Text.rich(
                            textAlign: TextAlign.start,
                            TextSpan(
                              text: "",
                              children: <TextSpan>[
                                TextSpan(
                                    text: DateFormat('dd.MM.yyyy\n')
                                        .format(transport.start),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text: DateFormat('HH:mm')
                                      .format(transport.start),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Divider(),
                          ),
                          Text.rich(
                            textAlign: TextAlign.end,
                            TextSpan(
                              text: "",
                              children: <TextSpan>[
                                TextSpan(
                                    text: DateFormat('dd.MM.yyyy\n')
                                        .format(transport.end),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                TextSpan(
                                  text:
                                      DateFormat('HH:mm').format(transport.end),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 32,
                      ),
                      Text.rich(
                        textAlign: TextAlign.start,
                        TextSpan(
                          text: "",
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Время поездки: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '$time\n'),
                            TextSpan(
                                text: 'Исполнитель: ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: '${transport.company}\n'),
                            TextSpan(
                                text: "Тип перевозки: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: "${transport.mean.join(", ")}\n"),
                            TextSpan(
                                text: "Наличие мест: ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(
                                text:
                                    "свободно ${transport.freeSpaceCount}/${transport.spaceCount}"),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                openBookingMenu(context, transport.id);
                              },
                              child: const Text('Забронировать'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }),
    );
  }

  final _formKey = GlobalKey<FormState>();
  final mysurnameController = TextEditingController();
  final mypassController = MaskedTextController(mask: '0000 000000');
  final myphoneController = MaskedTextController(mask: '8 (000) 000 00-00');
  final myMailController = TextEditingController();

  String? nameTest(String? value) {
    var reg = RegExp(r'^ *[а-яА-Я]+ +[а-яА-Я]+(?: +[а-яА-Я]+)?$');

    if (value == null ||
        value.isEmpty ||
        value.length >= 120 ||
        !reg.hasMatch(value)) {
      return 'Введите настоящие данные';
    }

    List<String> strings = value.replaceAll(RegExp(r"\s+"), " ").split(" ");
    if (strings.length >= 2) {
      if (strings[0] == strings[1]) {
        return "Фамилия и Имя не могут быть одинаковыми";
      }
    }
    return null;
  }

  static final border =
      OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(18)));
  void openBookingMenu(context1, int idx) {
    Navigator.push(
      context1,
      MaterialPageRoute(builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Бронирование')),
            body: Container(
              padding: EdgeInsets.all(0),
              child: Container(
                padding: EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    spacing: 16,
                    children: <Widget>[
                      TextFormField(
                          decoration:
                              InputDecoration(labelText: 'ФИО', border: border),
                          controller: mysurnameController,
                          validator: nameTest),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'Серия и номер паспорта',
                            border: border),
                        controller: mypassController,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 11) {
                            return 'Введите полные данные паспорта';
                          }
                          return null;
                        },
                      ),
                      Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    String name = "";
                                    String surname = "";
                                    String middleName = " ";

                                    var strings = mysurnameController.text
                                        .replaceAll(RegExp(r"\s+"), " ")
                                        .split(" ");

                                    surname = strings[0];
                                    name = strings[1];
                                    try {
                                      middleName = strings[2];
                                    } catch (e) {}

                                    await Server.book(idx, name, surname,
                                        middleName, mypassController.text);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Принято!')),
                                    );

                                    Navigator.of(context).pop();
                                  } on Exception catch (asd) {
                                    var msg = asd.toString();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(msg)),
                                    );
                                  }
                                }
                              },
                              child: const Text('Забронировать билет'),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      }),
    );
  }
}
