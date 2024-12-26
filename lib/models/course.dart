class Course {
  final int id;
  final String name;
  final String college;

  Course({required this.id, required this.name, required this.college});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
      college: json['college'],
    );
  }
}
