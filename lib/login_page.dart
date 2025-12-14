import 'package:extended_masked_text/extended_masked_text.dart';
import 'package:flutter/material.dart';
import 'package:travel_booking_app/home_page_screen.dart';
import 'package:travel_booking_app/server.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, required this.title});

  final String title;

  static final _loginFormKey = GlobalKey<FormState>();
  static final _registrationFormKey2 = GlobalKey<FormState>();

  static var myEmailController = TextEditingController();
  static var myPasswordController = TextEditingController();

  static var emailRegistrationController = TextEditingController();
  static var passwordRegistrationController = TextEditingController();
  static var passwordRegistrationCheckController = TextEditingController();
  static var phoneRegistrationController =
      MaskedTextController(mask: '+7 (000) 000 00 00');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white70,
          title: Text("Сначала пройдите авторизацию"),
        ),
        body: Form(
          key: _loginFormKey,
          child: Column(
            spacing: 16,
            children: [
              TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                ),
                controller: myEmailController,
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
                    child: TextButton(
                        onPressed: () {
                          openRegistrationMenu(context);
                        },
                        child: Text("Регистрация"))),
              ]),
              Row(children: [
                Expanded(
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_loginFormKey.currentState!.validate()) {
                            if (await Server.login(myEmailController.text,
                                myPasswordController.text)) {
                              myEmailController.clear();
                              myPasswordController.clear();

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => MyHomePage(
                                          title: 'Пассажирские перевозки')),
                                );
                              }
                            }
                          }
                        },
                        child: Text("Вход!")))
              ])
            ],
          ),
        ));
  }

  void openRegistrationMenu(BuildContext context1) {
    Navigator.push(
      context1,
      MaterialPageRoute(builder: (BuildContext bc) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
          return Scaffold(
            appBar: AppBar(title: const Text('Регистрация')),
            body: Container(
              padding: EdgeInsets.all(0),
              child: Container(
                padding: EdgeInsets.all(15),
                child: Form(
                  key: _registrationFormKey2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    spacing: 16,
                    children: <Widget>[
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18))),
                        ),
                        controller: emailRegistrationController,
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
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Пароль',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18))),
                        ),
                        controller: passwordRegistrationController,
                        validator: (value) {
                          var re = RegExp(r'^([A-Za-z0-9.]{1,50})$');

                          if (value == null ||
                              value.isEmpty ||
                              !re.hasMatch(value)) {
                            return 'Введите правильный пароль';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Повтор пароля',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18))),
                        ),
                        controller: passwordRegistrationCheckController,
                        validator: (value) {
                          var re = RegExp(r'^([A-Za-z0-9.]{1,50})$');

                          if (value == null ||
                              value.isEmpty ||
                              !re.hasMatch(value)) {
                            return 'Введите правильный пароль';
                          }

                          if (passwordRegistrationController.text != value) {
                            return 'Пароль не совпадает';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Телефон',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(18))),
                        ),
                        controller: phoneRegistrationController,
                      ),
                      Spacer(),
                      Row(children: [
                        Expanded(
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_registrationFormKey2.currentState!
                                      .validate()) {
                                    if (await Server.register(
                                        emailRegistrationController.text,
                                        phoneRegistrationController.text,
                                        passwordRegistrationController.text)) {
                                      emailRegistrationController.clear();
                                      passwordRegistrationController.clear();

                                      setModalState(() {
                                        Navigator.of(context1).pop();
                                      });

                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Подтвердите почту и войдите в аккаунт!')),
                                        );
                                      }
                                    }
                                  }
                                },
                                child: Text("Регистрация!")))
                      ])
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
