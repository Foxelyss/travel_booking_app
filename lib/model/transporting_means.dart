class TransportingMeans {
  final int id;
  final String name;

  TransportingMeans({
    required this.id,
    required this.name,
  });

  factory TransportingMeans.fromJson(Map<String, dynamic> json) {
    return TransportingMeans(id: json["id"], name: json["name"]);
  }

  static List<TransportingMeans> fromJsonList(List list) {
    return list.map((item) => TransportingMeans.fromJson(item)).toList();
  }

  String userAsString() {
    return '#$id $name';
  }

  bool userFilterByCreationDate(String filter) {
    return name.toString().contains(filter);
  }

  bool isEqual(TransportingMeans model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
