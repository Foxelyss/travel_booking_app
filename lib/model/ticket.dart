import 'package:travel_booking_app/model/point.dart';
import 'package:travel_booking_app/model/transporting_means.dart';

class Ticket {
  final int id;
  final int transporting;
  final Point startPoint;
  final Point endPoint;
  final String name;
  final DateTime start;
  final DateTime end;
  final double price;
  final List<TransportingMeans> mean;
  final String company;
  String status;
  int statusId;

  Ticket({
    required this.id,
    required this.transporting,
    required this.name,
    required this.start,
    required this.end,
    required this.startPoint,
    required this.endPoint,
    required this.price,
    required this.mean,
    required this.company,
    required this.status,
    required this.statusId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json["id"],
      transporting: json["transportation"]["id"],
      name: json["transportation"]["name"],
      start: DateTime.parse(json["transportation"]["departure"]),
      end: DateTime.parse(json["transportation"]["arrival"]),
      startPoint: Point.fromJson(json["transportation"]["departurePoint"]),
      endPoint: Point.fromJson(json["transportation"]["arrivalPoint"]),
      price: json["price"],
      mean: TransportingMeans.fromJsonList(
          json["transportation"]["transportingMeans"]),
      company: json["transportation"]["companyName"],
      status: json["status"],
      statusId: json["statusId"],
    );
  }

  static List<Ticket> fromJsonList(List list) {
    return list.map((item) => Ticket.fromJson(item)).toList();
  }

  String userAsString() {
    return '#$id $name';
  }

  bool userFilterByCreationDate(String filter) {
    return name.toString().contains(filter);
  }

  bool isEqual(Ticket model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
