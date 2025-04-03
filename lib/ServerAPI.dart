import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:travel_booking_app/Transport.dart';

import 'Config.dart';

class Serverapi {
  static Future<void> book(int transporting, String name, String surname,
      String middleName, String email, int passport, int phone) async {
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
    } else {
      throw Exception('Error');
    }
  }

  static Future<List<Transport>> searchTransport(
      int pointA, int pointB, int wantedTime, int mean, int page) async {
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
    } else {
      throw Exception('Error');
    }

    var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));

    return Transport.fromJsonList(pointsJson);
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
