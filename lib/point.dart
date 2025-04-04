class Point {
  final int id;
  final String town;
  final String name;
  final String region;

  Point({
    required this.id,
    required this.town,
    required this.name,
    required this.region,
  });

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(
      id: json["id"],
      town: json["town"],
      name: json["name"],
      region: json["region"],
    );
  }

  static List<Point> fromJsonList(List list) {
    return list.map((item) => Point.fromJson(item)).toList();
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
  bool isEqual(Point model) {
    return id == model.id;
  }

  @override
  String toString() => name;
}
