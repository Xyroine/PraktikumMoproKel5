import 'package:flutter/material.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  TimeOfDay? drinkTime;
  TimeOfDay? exerciseTime;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0FF05A);
    const bgLight = Color(0xFFF5F8F6);
    const bgDark = Color(0xFF102216);

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text("Reminder Sehat"),
        backgroundColor: bgDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Atur Waktu Reminder",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: bgDark,
              ),
            ),
            const SizedBox(height: 20),

            // === Kartu Reminder Minum Air ===
            _buildReminderCard(
              title: "Minum Air",
              subtitle: "Atur pengingat minum harian",
              time: drinkTime,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    drinkTime = picked;
                  });
                }
              },
              primaryColor: primaryColor,
            ),

            const SizedBox(height: 20),

            // === Kartu Reminder Olahraga ===
            _buildReminderCard(
              title: "Olahraga",
              subtitle: "Atur pengingat olahraga",
              time: exerciseTime,
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    exerciseTime = picked;
                  });
                }
              },
              primaryColor: primaryColor,
            ),

            const Spacer(),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  "Simpan Reminder",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard({
    required String title,
    required String subtitle,
    required TimeOfDay? time,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: primaryColor, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text (judul + subjudul)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          // Tombol Pilih Waktu
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.black,
            ),
            child: Text(
              time != null
                  ? "${time!.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}"
                  : "Pilih",
            ),
          ),
        ],
      ),
    );
  }
}
