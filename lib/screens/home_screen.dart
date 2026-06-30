import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/medicine_provider.dart';
import 'add_medicine_screen.dart';
import 'medicine_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicineProvider>().loadMedicines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'İlaç Hatırlatıcı',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Consumer<MedicineProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.medicines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Henüz ilaç eklenmedi',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'İlaç eklemek için + butonuna tıklayın',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadMedicines(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.medicines.length,
              itemBuilder: (context, index) {
                final medicine = provider.medicines[index];
                final now = TimeOfDay.now();
                final currentMinute = now.hour * 60 + now.minute;

                TimeOfDay? nextTime;
                int? minDiff;
                for (final t in medicine.reminderTimes) {
                  final parts = t.split(':');
                  final time = TimeOfDay(
                    hour: int.parse(parts[0]),
                    minute: int.parse(parts[1]),
                  );
                  final diff = (time.hour * 60 + time.minute) - currentMinute;
                  if (diff >= 0 && (minDiff == null || diff < minDiff)) {
                    minDiff = diff;
                    nextTime = time;
                  }
                }

                final isShortTerm = medicine.medicationType == 'shortTerm';
                final isExpired = isShortTerm && medicine.endDate != null && medicine.endDate!.isBefore(DateTime.now());

                return Opacity(
                  opacity: medicine.isActive ? 1.0 : 0.5,
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MedicineDetailScreen(medicine: medicine),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isExpired
                                    ? Colors.red.shade50
                                    : medicine.isActive
                                        ? Colors.blue.shade50
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.medication,
                                size: 32,
                                color: isExpired
                                    ? Colors.red
                                    : medicine.isActive
                                        ? Colors.blue
                                        : Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          medicine.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isShortTerm ? Colors.orange.shade100 : Colors.green.shade100,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isShortTerm ? 'Kısa' : 'Uzun',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isShortTerm ? Colors.orange.shade800 : Colors.green.shade800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    medicine.dosage,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  if (nextTime != null && medicine.isActive) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Colors.blue[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Sonraki: ${_formatTime(nextTime)}',
                                          style: TextStyle(
                                            color: Colors.blue[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (isExpired) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber,
                                          size: 16,
                                          color: Colors.red[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Süresi doldu',
                                          style: TextStyle(
                                            color: Colors.red[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  medicine.reminderTimes.length.toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'bildirim',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Switch(
                                  value: medicine.isActive,
                                  onChanged: (v) {
                                    provider.toggleActive(medicine);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMedicineScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('İlaç Ekle'),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }
}
