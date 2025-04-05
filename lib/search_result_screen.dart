import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:travel_booking_app/server_api.dart';
import 'package:travel_booking_app/transport.dart';
import 'package:travel_booking_app/pagination_errors.dart';
import 'package:travel_booking_app/pagination_messages.dart';

class ListViewScreen extends StatefulWidget {
  final int pointA;
  final int pointB;
  final int wantedTime;
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
      int next = (state.keys?.last ?? 0) + 1;
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
      builder: (context, state, fetchNextPage) => PagedListView<int, Transport>(
        state: state,
        fetchNextPage: fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate(
          itemBuilder: (context, item, index) => createTransporting(item),
          firstPageErrorIndicatorBuilder: (context) =>
              CustomFirstPageError(pagingController: _pagingController),
          newPageErrorIndicatorBuilder: (context) =>
              CustomNewPageError(pagingController: _pagingController),
          noItemsFoundIndicatorBuilder: (context) => NoItemsFoundIndicator(),
          noMoreItemsIndicatorBuilder: (context) => Divider(),
        ),
      ),
    );
  }

  Future<List<Transport>> searchTransport(int page) async {
    var list = await ServerAPI.searchTransport(
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
      time += "${diff.inDays} ${ServerAPI.russianDays(diff.inDays)}";
    }
    if (hours != 0) {
      time += "$hours ${ServerAPI.russianHours(hours)}";
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
              Text(obj.mean),
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
                  Text("${obj.price}₽",
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
      time += "${diff.inDays} ${ServerAPI.russianDays(diff.inDays)}";
    }
    if (hours != 0) {
      time += "$hours ${ServerAPI.russianHours(hours)}";
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          // DateFormat('dd.MM.yyyy HH:mm').format(transport.start)
          return Scaffold(
            appBar: AppBar(title: const Text('О транспорте')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text('Маршрут: ${transport.name}'),
                    ),
                    SizedBox(
                      height: 36,
                    ),
                    Row(
                      children: [
                        Text(transport.startPoint),
                        Spacer(),
                        Text(
                          transport.endPoint,
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 32),
                      child: Divider(),
                    ),
                    Row(
                      children: [
                        Text(DateFormat('dd.MM.yyyy HH:mm')
                            .format(transport.start)),
                        Expanded(
                          child: Divider(),
                        ),
                        Text(
                          DateFormat('dd.MM.yyyy HH:mm').format(transport.end),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 32,
                    ),
                    Text('Время поездки: $time'),
                    Text('Исполняется ${transport.company}'),
                    Text("Тип перевозки: ${transport.mean}"),
                    Text(
                        "Наличие мест: свободно ${transport.freeSpaceCount}/${transport.spaceCount}"),
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
          );
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
                              decoration:
                                  InputDecoration.collapsed(hintText: 'Имя'),
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
                            decoration:
                                InputDecoration.collapsed(hintText: 'Паспорт'),
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
                            decoration:
                                InputDecoration.collapsed(hintText: 'Телефон'),
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
                              ServerAPI.book(
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
          );
        });
      }),
    );
  }
}
