import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/water_intake.dart';
import '../models/calorie_intake.dart';
import '../models/activity.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;

  // Data untuk ditampilkan
  double waterToday = 0.0;
  double waterTarget = 2.0; // 2 Liter
  double calorieIn = 0.0;
  double calorieOut = 0.0;
  double calorieTarget = 2000.0;
  List<Activity> todayActivities = [];

  String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String displayDate = DateFormat(
    'EEEE, dd MMMM',
    'id_ID',
  ).format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _loadTodayData();
  }

  // LOAD DATA DARI DATABASE
  Future<void> _loadTodayData() async {
    // Ambil data air hari ini
    final water = await dbHelper.getTodayWaterIntake(todayDate);

    // Ambil data kalori hari ini
    final calories = await dbHelper.getTodayCalories(todayDate);

    // Ambil aktivitas hari ini
    final activities = await dbHelper.getActivitiesByDate(todayDate);

    setState(() {
      waterToday = water;
      calorieIn = calories['keluar'] ?? 0; // Sisa kalori
      calorieOut = calories['masuk'] ?? 0; // Kalori masuk
      todayActivities = activities;
    });
  }

  // TAMBAH ASUPAN AIR
  Future<void> _addWater(double amount) async {
    final water = WaterIntake(
      amount: amount,
      date: todayDate,
      time: DateFormat('HH:mm').format(DateTime.now()),
    );

    await dbHelper.insertWaterIntake(water);
    _loadTodayData(); // Refresh data

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${amount}L air ditambahkan')));
  }

  // TAMBAH KALORI (MASUK/KELUAR)
  Future<void> _addCalorie(
    String type,
    double amount,
    String description,
  ) async {
    final calorie = CalorieIntake(
      type: type,
      amount: amount,
      date: todayDate,
      time: DateFormat('HH:mm').format(DateTime.now()),
      description: description,
    );

    await dbHelper.insertCalorieIntake(calorie);
    _loadTodayData(); // Refresh data
  }

  // UPDATE STATUS AKTIVITAS
  Future<void> _updateActivityStatus(
    Activity activity,
    String newStatus,
  ) async {
    activity.status = newStatus;
    await dbHelper.updateActivity(activity);
    _loadTodayData(); // Refresh data
  }

  // DIALOG TAMBAH AIR
  void _showAddWaterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Asupan Air'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addWater(0.25);
              },
              child: const Text('+ 250ml (Gelas)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addWater(0.5);
              },
              child: const Text('+ 500ml (Botol)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _addWater(1.0);
              },
              child: const Text('+ 1L'),
            ),
          ],
        ),
      ),
    );
  }

  // DIALOG TAMBAH KALORI
  void _showAddCalorieDialog(String type) {
    final controller = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah Kalori ${type == 'masuk' ? 'Masuk' : 'Keluar'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah (kkal)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi (opsional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                _addCalorie(
                  type,
                  double.parse(controller.text),
                  descController.text,
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A2E),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadTodayData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFF2D5F4E),
                      child: Icon(Icons.person, size: 35, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selamat Pagi,',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const Text(
                            'Budi!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Text(
                  displayDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 25),

                // CARD ASUPAN AIR
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5F4E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A3A2E),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.water_drop,
                                  color: Colors.lightBlueAccent,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Text(
                                'Asupan Air',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.lightBlueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: Colors.white),
                            ),
                            onPressed: _showAddWaterDialog,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${waterToday.toStringAsFixed(1)}L',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Target: ${waterTarget.toStringAsFixed(0)}L',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: waterToday / waterTarget,
                        backgroundColor: const Color(0xFF1A3A2E),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.lightBlueAccent,
                        ),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // CARD KALORI HARI INI
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D5F4E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3A2E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Colors.orangeAccent,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          const Text(
                            'Kalori Hari Ini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Sisa Kalori
                          Column(
                            children: [
                              const Text(
                                'Sisa',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                calorieIn.toStringAsFixed(0),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          // Divider
                          Container(
                            height: 60,
                            width: 1,
                            color: Colors.white30,
                          ),

                          // Kalori Masuk
                          Column(
                            children: [
                              const Text(
                                'Masuk',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showAddCalorieDialog('masuk'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A3A2E),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${calorieOut.toStringAsFixed(0)} kkal',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Target: ${calorieTarget.toStringAsFixed(0)} kkal',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // AKTIVITAS FISIK
                const Text(
                  'Aktivitas Fisik',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                // LIST AKTIVITAS
                ...todayActivities
                    .map(
                      (activity) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5F4E),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A3A2E),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                activity.name.toLowerCase().contains('jalan')
                                    ? Icons.directions_walk
                                    : activity.name.toLowerCase().contains(
                                        'yoga',
                                      )
                                    ? Icons.self_improvement
                                    : Icons.fitness_center,
                                color: Colors.greenAccent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    activity.status == 'Selesai'
                                        ? '${activity.duration} menit'
                                        : 'Direncanakan: ${activity.duration} menit',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (activity.status == 'Direncanakan') {
                                  _updateActivityStatus(activity, 'Mulai');
                                } else if (activity.status == 'Mulai') {
                                  _updateActivityStatus(activity, 'Selesai');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: activity.status == 'Selesai'
                                    ? Colors.grey
                                    : Colors.greenAccent,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                activity.status == 'Selesai'
                                    ? 'Selesai'
                                    : 'Mulai',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                // Tombol tambah aktivitas (opsional)
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: () {
                      // Navigasi ke halaman tambah aktivitas atau show dialog
                    },
                    icon: const Icon(Icons.add, color: Colors.greenAccent),
                    label: const Text(
                      'Tambah Aktivitas',
                      style: TextStyle(color: Colors.greenAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // FLOATING ACTION BUTTON (untuk menu makanan)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman rekomendasi makanan
        },
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(Icons.restaurant_menu, color: Colors.white),
      ),
    );
  }
}
