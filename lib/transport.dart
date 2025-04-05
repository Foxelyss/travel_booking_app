class Transport {
  final int id;
  final String startPoint;
  final String endPoint;
  final String name;
  final DateTime start;
  final DateTime end;
  final double price;
  final String mean;
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
    String a = "";
    a.split("|");
    return Transport(
        id: json["id"],
        name: json["name"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        startPoint: json["startPoint"].replaceAll("|", "\n"),
        endPoint: json["endPoint"].replaceAll("|", "\n"),
        price: json["price"],
        mean: json["mean"],
        company: json["company"],
        spaceCount: json["places"],
        freeSpaceCount: json["freePlaceQuantity"]);
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
