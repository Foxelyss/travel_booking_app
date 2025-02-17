class Transport {
  final int id;
  final String town;
  final String name;
  final String region;
  final DateTime start;
  final DateTime end;

  Transport({
    required this.id,
    required this.town,
    required this.name,
    required this.region,
    required this.start,
  });

  factory Transport.fromJson(Map<String, dynamic> json) {
    return Transport(
      id: json["id"],
      name: json["name"],
      start: json["start"],
    );
  }

  static List<Transport> fromJsonList(List list) {
    return list.map((item) => Transport.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String userAsString() {
    return '#$id $name';
  }

  ///this method will prevent the override of toString
  bool userFilterByCreationDate(String filter) {
    return town.toString().contains(filter);
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(Transport model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
