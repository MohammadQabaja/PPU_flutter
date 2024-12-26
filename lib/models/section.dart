class Section {
  final int id;
  final String name;
  final String lecturer;

  Section({required this.id, required this.name, required this.lecturer});

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      lecturer: json['lecturer'],
    );
  }
}
