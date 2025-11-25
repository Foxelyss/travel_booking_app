import 'package:travel_booking_app/model/point.dart';
import 'package:travel_booking_app/model/transporting_means.dart';

class Transport {
  final int id;
  final Point startPoint;
  final Point endPoint;
  final String name;
  final DateTime start;
  final DateTime end;
  final double price;
  final List<TransportingMeans> mean;
  final String company;
  final int spaceCount;
  final int freeSpaceCount;

  Transport({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.startPoint,
    required this.endPoint,
    required this.price,
    required this.mean,
    required this.company,
    required this.spaceCount,
    required this.freeSpaceCount,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
        id: json["id"],
        name: json["name"],
        start: DateTime.parse(json["departure"]),
        end: DateTime.parse(json["arrival"]),
        startPoint: Point.fromJson(json["departurePoint"]),
        endPoint: Point.fromJson(json["arrivalPoint"]),
        price: json["price"],
        mean: TransportingMeans.fromJsonList(json["transportingMeans"]),
        company: json["companyName"],
        spaceCount: json["placeCount"],
        freeSpaceCount: json["freePlaceCount"]);
  }

  static List<Transport> fromJsonList(List list) {
    return list.map((item) => Transport.fromJson(item)).toList();
  }

  String userAsString() {
    return '#$id $name';
  }

  bool userFilterByCreationDate(String filter) {
    return name.toString().contains(filter);
  }

  bool isEqual(Transport model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
