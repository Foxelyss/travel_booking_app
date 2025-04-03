import 'package:http/http.dart' as http;

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
}
