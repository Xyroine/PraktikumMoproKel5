class Activity {
  int? id;
  String name; // misal: "Jalan Pagi", "Yoga"
  int duration; // dalam menit
  String status; // "Selesai", "Direncanakan", "Mulai"
  String date;

  Activity({
    this.id,
    required this.name,
    required this.duration,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'status': status,
      'date': date,
    };
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      duration: map['duration'],
      status: map['status'],
      date: map['date'],
    );
  }
}