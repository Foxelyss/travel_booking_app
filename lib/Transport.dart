class Transport {
  final int id;
  final String start_point;
  final String end_point;
  final String name;
  final DateTime start;
  final DateTime end;
  final double price;
  final String mean;
  final String company;
  final int spacecount;
  final int freespacecount;

  Transport({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.start_point,
    required this.end_point,
    required this.price,
    required this.mean,
    required this.company,
    required this.spacecount,
    required this.freespacecount,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
        id: json["id"],
        name: json["name"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        start_point: json["start_point"].replaceAll("|", "\n"),
        end_point: json["end_point"].replaceAll("|", "\n"),
        price: json["price"],
        mean: json["mean"],
        company: json["company"],
        spacecount: json["places"],
        freespacecount: json["free_place_quantity"]);
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
