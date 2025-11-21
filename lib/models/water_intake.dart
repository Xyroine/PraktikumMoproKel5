class WaterIntake {
  int? id;
  double amount; // dalam liter
  String date; // format: yyyy-MM-dd
  String time; // format: HH:mm

  WaterIntake({
    this.id,
    required this.amount,
    required this.date,
    required this.time,
  });

  // Convert ke Map untuk SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date,
      'time': time,
    };
  }

  // Convert dari Map (saat ambil dari database)
  factory WaterIntake.fromMap(Map<String, dynamic> map) {
    return WaterIntake(
      id: map['id'],
      amount: map['amount'],
      date: map['date'],
      time: map['time'],
    );
  }
}