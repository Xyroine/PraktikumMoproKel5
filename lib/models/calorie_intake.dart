class CalorieIntake {
  int? id;
  String type; // 'masuk' atau 'keluar'
  double amount; // dalam kkal
  String date;
  String time;
  String? description; // opsional, misal: "Nasi Goreng"

  CalorieIntake({
    this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.time,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'date': date,
      'time': time,
      'description': description,
    };
  }

  factory CalorieIntake.fromMap(Map<String, dynamic> map) {
    return CalorieIntake(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      date: map['date'],
      time: map['time'],
      description: map['description'],
    );
  }
}