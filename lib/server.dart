import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:secure_db/secure_db.dart';
import 'package:travel_booking_app/config.dart';
import 'package:travel_booking_app/model/point.dart';
import 'package:travel_booking_app/model/ticket.dart';
import 'package:travel_booking_app/model/transport.dart';
import 'package:travel_booking_app/model/transporting_means.dart';

class Server {
  static final noConnectionError = "Невозможно подключиться к серверу";
  static TransportingMeans everythingTransportingMean =
      TransportingMeans(id: -1, name: "Все виды транспорта");

  static String? token;

  static Future<void> LoadAccessToken() async {
    token = await SecureDB.getString('access_token');
  }

  static Future<bool> isLoggedIn() async {
    await LoadAccessToken();

    return token != null;
  }

  static Future<http.Response> postCommand(
      String path, Map<String, String> params) async {
    try {
      http.Response response = await http.post(
        Uri.http(serverURI, path),
        body: params,
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );

      return response;
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

  static Future<http.Response> getCommand(String path,
      {Map<String, String>? params}) async {
    try {
      http.Response response = await http.get(
        Uri.http(serverURI, path, params),
        headers: {HttpHeaders.authorizationHeader: "Bearer $token"},
      );

      return response;
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

  static Future<bool> login(String email, String password) async {
    http.Response response = await postCommand(
        '/api/auth/login', {"email": email, "password": password});

    if (response.statusCode == 200) {
      await SecureDB.setString(
          "access_token", jsonDecode(response.body)["access_token"]);
      token = jsonDecode(response.body)["access_token"];
      return true;
    } else {
      throw Exception("Error ${response.statusCode}");
    }
  }

  static Future<bool> register(
      String email, String phone, String password) async {
    http.Response response = await postCommand('/api/auth/register',
        {"email": email, "phone": phone, "password": password});

    if (response.statusCode == 200) {
      return true;
    } else {
      print(response.body);
      throw Exception("Error ${response.statusCode}");
    }
  }

  static Future<void> book(int transporting, String name, String surname,
      String middleName, String passport) async {
    http.Response response = await postCommand('/api/booking/book', {
      "transporting": "$transporting",
      "name": name,
      "surname": surname,
      "middleName": middleName,
      "passport": passport,
    });

    print(transporting);
    print(response.request!);
    print(response.statusCode);
    print(response.headers);
    print(response.body);
    if (response.statusCode == 200) {
    } else {
      throw Exception(response.body);
    }
  }

  static Future<List<Transport>> searchTransport(
      int pointA, int pointB, DateTime wantedTime, int mean, int page) async {
    http.Response response = await getCommand('/api/search/search', params: {
      'point_a': '$pointA',
      'point_b': '$pointB',
      'wanted_time': wantedTime.toIso8601String(),
      'mean': '$mean',
      'page': '$page'
    });

    if (response.statusCode == 200) {
      print("${response.body}\n$pointA $pointB $mean $page");

      var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));
      return Transport.fromJsonList(pointsJson);
    } else {
      throw Exception("Ошибка сервера");
    }
  }

  static Future<List<Point>> getPoints() async {
    http.Response response = await getCommand('/api/point/all');

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    var pointsJson = jsonDecode(utf8.decode(response.bodyBytes));
    return Point.fromJsonList(pointsJson);
  }

  static Future<List<TransportingMeans>> getMeans() async {
    http.Response response = await getCommand('/api/mean/all');

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }
    var meansJson = jsonDecode(utf8.decode(response.bodyBytes));

    var means = TransportingMeans.fromJsonList(meansJson);
    means.add(everythingTransportingMean);
    return means;
  }

  static Future<List<Ticket>> getbookings() async {
    http.Response response = await getCommand('/api/booking/bookings');

    if (response.statusCode == 200) {
    } else {
      throw Exception('Error');
    }

    return Ticket.fromJsonList(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  static Future<void> returnbook(int id) async {
    http.Response response =
        await postCommand('/api/booking/return', {'id': '$id'});

    if (response.statusCode == 200) {
    } else {
      throw Exception(response.statusCode);
    }
  }

  static Future<Map<String, dynamic>> about() async {
    http.Response response = await getCommand('/api/auth/about');

    print(response.request!.url);
    print(response.statusCode);
    if (response.statusCode == 200) {
    } else {
      throw ErrorDescription('Error');
    }
    var meansJson = jsonDecode(utf8.decode(response.bodyBytes));
    return meansJson;
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
