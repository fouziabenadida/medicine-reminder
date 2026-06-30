import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';
import 'add_medicine_screen.dart';

class MedicineDetailScreen extends StatelessWidget {
  final Medicine medicine;

  const MedicineDetailScreen({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medicine.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMedicineScreen(medicine: medicine),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.medication, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _infoRow(Icons.science, 'Dozaj', medicine.dosage),
                    if (medicine.note != null)
                      _infoRow(Icons.note, 'Not', medicine.note!),
                    _infoRow(
                      Icons.category,
                      'Tür',
                      medicine.medicationType == 'shortTerm' ? 'Kısa Süreli' : 'Uzun Süreli',
                    ),
                    if (medicine.endDate != null)
                      _infoRow(
                        Icons.event,
                        'Bitiş Tarihi',
                        DateFormat('dd.MM.yyyy').format(medicine.endDate!),
                      ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bildirim Saatleri',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...medicine.reminderTimes.map((t) {
                      final parts = t.split(':');
                      final time = TimeOfDay(
                        hour: int.parse(parts[0]),
                        minute: int.parse(parts[1]),
                      );
                      final now = DateTime.now();
                      final dt = DateTime(
                        now.year, now.month, now.day, time.hour, time.minute,
                      );
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, size: 18),
                            const SizedBox(width: 8),
                            Text(DateFormat('HH:mm').format(dt)),
                          ],
                        ),
                      );
                    }),
                    const Divider(),
                    _infoRow(
                      Icons.info_outline,
                      'Durum',
                      medicine.isActive ? 'Aktif' : 'Pasif',
                    ),
                    _infoRow(
                      Icons.calendar_today,
                      'Oluşturulma',
                      DateFormat('dd.MM.yyyy').format(medicine.createdAt),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () {
                final provider = context.read<MedicineProvider>();
                provider.toggleActive(medicine);
                Navigator.pop(context);
              },
              icon: Icon(medicine.isActive ? Icons.pause : Icons.play_arrow),
              label: Text(medicine.isActive ? 'Pasif Yap' : 'Aktif Yap'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: Colors.grey)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _delete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('İlacı Sil'),
        content: Text('${medicine.name} silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              context.read<MedicineProvider>().deleteMedicine(medicine.id!);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
