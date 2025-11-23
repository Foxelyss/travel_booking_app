import 'package:flutter/material.dart';
import 'package:secure_db/secure_db.dart';
import 'package:travel_booking_app/home_page_screen.dart';
import 'package:travel_booking_app/home_screen.dart';
import 'package:travel_booking_app/transport_aggregator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  static var myEmailController = TextEditingController();
  static var myPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text("Сначала пройдите авторизацию"),
      ),
      body: Column(
        children: [
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'E-mail',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
            ),
            controller: myEmailController,
            // The validator receives the text that the user has entered.
            validator: (value) {
              var re = RegExp(
                  r'^([A-Za-z0-9.]{1,50})@([A-Za-z0-9.]{1,50})\.([A-Za-z0-9.]{1,5})$');

              if (value == null || value.isEmpty || !re.hasMatch(value)) {
                return 'Введите правильный эл. адрес';
              }
              return null;
            },
          ),
          TextFormField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Пароль',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18))),
            ),
            controller: myPasswordController,
            validator: (value) {
              var re = RegExp(r'^([A-Za-z0-9.]{1,50})$');

              if (value == null || value.isEmpty || !re.hasMatch(value)) {
                return 'Введите правильный пароль';
              }
              return null;
            },
          ),
          Spacer(),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () {}, child: Text("Регистрация"))),
          ]),
          Row(children: [
            Expanded(
                child: ElevatedButton(
                    onPressed: () async {
                      await SecureDB.setString('access_token', 'abc123');

                      // Reload app
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => new MyHomePage(
                                title: 'Пассажирские перевозки')),
                      );
                    },
                    child: Text("Вход!")))
          ])
        ],
      ),
    );
  }
}
