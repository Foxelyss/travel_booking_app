import 'package:flutter/material.dart';
import 'package:travel_booking_app/home_page_screen.dart';
import 'package:travel_booking_app/login_page.dart';
import 'package:travel_booking_app/server.dart';

class TransportAggregator extends StatelessWidget {
  const TransportAggregator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пассажирские перевозки',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 105, 255, 205)),
          useMaterial3: true,
          appBarTheme: AppBarTheme(centerTitle: false),
          buttonTheme: ButtonThemeData(
              height: 50,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      color: const Color.fromARGB(255, 212, 212, 212)))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(Size(80, 50)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 212, 212, 212))))),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(Size(80, 50)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 212, 212, 212))))),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(Size(80, 50)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 212, 212, 212))))),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(Size(80, 50)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 212, 212, 212))))),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
              inputDecorationTheme:
                  InputDecorationTheme(border: UnderlineInputBorder())),
          inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(18))))),
      home: FutureBuilder<bool>(
        future: Server.isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return const MyHomePage(title: 'Пассажирские перевозки');
          }

          return LoginPage(title: "Пройдите вход!");
        },
      ),
    );
  }
}
