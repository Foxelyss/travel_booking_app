import 'package:flutter/material.dart';
import 'package:travel_booking_app/home_screen.dart';
import 'package:travel_booking_app/profile_screen.dart';

import 'search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Пассажирские перевозки',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 226, 223, 24)),
          useMaterial3: true,
          appBarTheme: AppBarTheme(centerTitle: false),
          buttonTheme: ButtonThemeData(
              height: 40,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(
                      color: const Color.fromARGB(255, 212, 212, 212)))),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(Size(80, 40)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 212, 212, 212))))),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
                minimumSize: WidgetStateProperty.all<Size>(Size(80, 40)),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        side: BorderSide(
                            color: const Color.fromARGB(255, 212, 212, 212))))),
          ),
          dropdownMenuTheme: DropdownMenuThemeData(
              inputDecorationTheme:
                  InputDecorationTheme(border: UnderlineInputBorder()))),
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

  final List<Widget> _pages = <Widget>[
    HomeScreen(),
    SearchScreen(title: "Поиск"),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
          child: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      )),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Главная',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Поиск',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
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
