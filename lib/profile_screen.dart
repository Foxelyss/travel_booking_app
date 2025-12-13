import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:secure_db/secure_db.dart';
import 'package:travel_booking_app/config.dart';
import 'package:travel_booking_app/login_page.dart';
import 'package:travel_booking_app/server.dart';
import 'package:travel_booking_app/model/ticket.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static List<Ticket> _offers = <Ticket>[];

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

  Widget createTransporting(
      BuildContext context, Ticket obj, StateSetter modalSetter) {
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
                Text(obj.startPoint.city),
                Expanded(child: Divider()),
                Text(obj.endPoint.city),
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
            Text(obj.mean.join(", ")),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("№ чека ${obj.id}"),
                Text(
                    "${obj.price.toStringAsFixed(2).replaceFirst(".", ",")} ₽"),
                TextButton(
                    onPressed: obj.status != "Cancelled"
                        ? () async {
                            returnBook(
                                context, obj.transporting, obj.id, modalSetter);

                            try {
                              _offers = await Server.getbookings();
                              modalSetter(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Обновление данных!')),
                              );
                            } on Exception {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Ошибка в обновлении данных!')),
                              );
                            }
                          }
                        : null,
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.pink,
                        side: BorderSide(style: BorderStyle.none)),
                    child: Text(
                        obj.status != "Cancelled" ? "Отказаться" : "Отменён"))
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
                              onPressed: () async {
                                try {
                                  await (() async {
                                    Server.returnbook(id);
                                  }).withRetries(3);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Успешно отменено!')),
                                  );
                                  try {
                                    await (() async {
                                      _offers = await Server.getbookings();
                                    }).withRetries(3);
                                    stateSetter(() {});
                                  } catch (a) {
                                    ();
                                  }
                                  try {
                                    _offers[_offers
                                            .indexWhere((a) => a.id == id)]
                                        .status = "Cancelled";
                                  } catch (a) {
                                    ();
                                  }
                                } on Exception {
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
            FutureBuilder<Map<String, dynamic>>(
              future: () async {
                while (true) {
                  try {
                    var about = await Server.about();
                    return about;
                  } on ErrorDescription catch (e) {
                    if (e.toString() == "Error") {
                      await SecureDB.remove('access_token');

                      // Reload app
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                LoginPage(title: 'Пассажирские перевозки')),
                      );
                    }
                  }

                  await Future.delayed(Duration(seconds: 15));
                }
              }(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data!.isNotEmpty) {
                  return Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Реквизиты аккаунта",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        "Id: " + snapshot.data!["id"],
                      ),
                      Text(
                        "E-mail: " + snapshot.data!["email"],
                      ),
                      Text(
                        "Телефон: " + snapshot.data!["phone"],
                      ),
                    ],
                  );
                }

                return Text("Нет соединения с сервером");
              },
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
                    if (true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Просмотр данных!')),
                      );

                      try {
                        await (() async {
                          _offers = await Server.getbookings();
                        }).withRetries(3);
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
                            const SnackBar(content: Text('Чеков нет')),
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
                    onPressed: () async {
                      await SecureDB.remove('access_token');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                LoginPage(title: 'Пассажирские перевозки')),
                      );
                    },
                    icon: Icon(Icons.logout_rounded),
                    style: ButtonStyle(
                      alignment: Alignment.centerLeft,
                      iconColor: WidgetStatePropertyAll(Colors.red),
                    ),
                    label: Text(
                      "Выход из аккаунта",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () async {
                      SystemChannels.platform
                          .invokeMethod('SystemNavigator.pop');
                    },
                    icon: Icon(Icons.exit_to_app),
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
