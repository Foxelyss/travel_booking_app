import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
          child: IntrinsicWidth(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            spacing: 12,
            children: <Widget>[
              Card(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 320,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    Image(image: AssetImage('assets/ad1.png'))),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text("Дешёвые туры в честь открытия в сезона!"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text.rich(
                                textAlign: TextAlign.end,
                                TextSpan(
                                  text: "",
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "На все поездки в ",
                                    ),
                                    TextSpan(
                                        text: "Горный Алтай!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ])),
              ),
              Card(
                child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 320,
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child:
                                    Image(image: AssetImage('assets/ad2.png'))),
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text("Почему бы и не побывать в Великом Ханстве!"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text.rich(
                                textAlign: TextAlign.end,
                                TextSpan(
                                  text: "",
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "Поедьте в ",
                                    ),
                                    TextSpan(
                                        text: "Казань!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ])),
              ),
            ]),
      )),
    );
  }
}
