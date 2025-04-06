class Ticket {
  final int id;
  final int transporting;
  final String startPoint;
  final String endPoint;
  final String name;
  final DateTime start;
  final DateTime end;
  final double price;
  final String mean;
  final String company;

// int id, String name, int transporting,
//                          Timestamp start, Timestamp end, String startPoint,
//                          String endPoint, float price,
//                          String mean, String company,
//                          String payment
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
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json["id"],
      transporting: json["transporting"],
      name: json["name"],
      start: DateTime.parse(json["start"]),
      end: DateTime.parse(json["end"]),
      startPoint: json["startPoint"],
      endPoint: json["endPoint"],
      price: json["price"],
      mean: json["mean"],
      company: json["company"],
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
