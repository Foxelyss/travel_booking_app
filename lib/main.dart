import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:travel_booking_app/home_screen.dart';
import 'package:travel_booking_app/profile_screen.dart';
import 'package:travel_booking_app/search_screen.dart';

void main() {
  runApp(const MyApp());
  initializeDateFormatting("Ru");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: const MyHomePage(title: 'Пассажирские перевозки'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final key = new GlobalKey<Searchscreen>();
  void toFindA() {
    setState(() {
      _selectedIndex = 1;
    });

    key.currentState!.selectDestination(8, "г. Горно-Алтайск");
  }

  void toFindB() {
    setState(() {
      _selectedIndex = 1;
    });

    key.currentState!.selectDestination(3, "Казань");
  }

  late Function a;
  late Function b;
  _MyHomePageState() {
    a = toFindA;
    b = toFindB;
  }

  late final List<Widget> _pages = <Widget>[
    HomeScreen(
      onA: a,
      onB: b,
    ),
    SearchScreen(key: key, title: "Поиск"),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text([
          "Специальные предложения",
          "Поиск",
          "Личный кабинет"
        ][_selectedIndex]),
      ),
      body: Center(
          child: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      )),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              CupertinoIcons.search,
            ),
            activeIcon: Icon(
              CupertinoIcons.search,
              weight: 600,
            ),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(
              CupertinoIcons.person_fill,
              weight: 600,
            ),
            label: 'Кабинет',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
