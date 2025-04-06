import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:travel_booking_app/config.dart';
import 'package:travel_booking_app/point.dart';
import 'package:travel_booking_app/transport.dart';
import 'package:travel_booking_app/transporting_means.dart';

class ServerAPI {
  static final noConnectionError = "Невозможно подключиться к серверу";
  static TransportingMeans everythingTransportingMean =
      TransportingMeans(id: -1, name: "Все виды транспорта");

  static Future<void> book(int transporting, String name, String surname,
      String middleName, String email, int passport, int phone) async {
    try {
      http.Response response =
          await http.post(Uri.http(serverURI, '/api/booking/book', {
        "transporting": "$transporting",
        "name": name,
        "surname": surname,
        "middle_name": middleName,
        "email": email,
        "passport": "$passport",
        "phone": "$phone"
      }));

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        throw Exception(response.body);
      }
    } on SocketException {
      throw Exception(noConnectionError);
    } on HttpException {
      rethrow;
    } on http.ClientException {
      throw Exception(noConnectionError);
    } on Exception {
      rethrow;
    }
  }

  static Future<List<Transport>> searchTransport(
      int pointA, int pointB, int wantedTime, int mean, int page) async {
    try {
      http.Response response =
          await http.get(Uri.http(serverURI, '/api/search/search', {
        'point_a': '$pointA',
        'point_b': '$pointB',
        'quantity': '12',
        'wanted_time': '$wantedTime',
        'mean': '$mean',
        'page': '$page'
      }));

      if (response.statusCode == 200) {
        var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));
        return Transport.fromJsonList(pointsJson);
      } else {
        throw Exception("Ошибка сервера");
      }
    } on SocketException {
      throw Exception(noConnectionError);
    } on HttpException {
      rethrow;
    } on http.ClientException {
      throw Exception(noConnectionError);
    } on Exception {
      rethrow;
    }
  }

  static Future<List<Point>> getPoints() async {
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/search/points'));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));
    return Point.fromJsonList(pointsJson);
  }

  static Future<List<TransportingMeans>> getMeans() async {
    http.Response response =
        await http.get(Uri.http(serverURI, '/api/search/means'));

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
    var meansJson = jsonDecode(utf8.decode(response.bodyBytes));

    var means = TransportingMeans.fromJsonList(meansJson);
    means.add(everythingTransportingMean);
    return means;
  }

  static String russianDays(int n) {
    int k = ((n ~/ 10 % 10 != 1) ? 1 : 0) * n % 10;

    return [
      'дней',
      'дня',
      'день'
    ][((1 <= k && k <= 4) ? 1 : 0) + ((k == 1) ? 1 : 0)];
  }

  static String russianHours(int n) {
    int k = ((n ~/ 10 % 10 != 1) ? 1 : 0) * n % 10;

    return [
      'часов',
      'часа',
      'час'
    ][((1 <= k && k <= 4) ? 1 : 0) + ((k == 1) ? 1 : 0)];
  }
}
