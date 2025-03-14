import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_booking_app/Point.dart';

final serverURI = 'foxelyss-ms7c95.lan:8080';

extension Retry<T> on Future<T> Function() {
  Future<T> withRetries(int count) async {
    while (true) {
      try {
        final future = this();
        return await future;
      } catch (e) {
        if (count > 0) {
          count--;
        } else {
          rethrow;
        }
      }
    }
  }
}

void MakeTransaction(context, func) {
  try {
    func();
  } catch (ca) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Обновление данных!')),
    );
  }
}
