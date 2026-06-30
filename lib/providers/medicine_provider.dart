import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/medicine.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();

  List<Medicine> _medicines = [];
  bool _isLoading = false;

  List<Medicine> get medicines => _medicines;
  bool get isLoading => _isLoading;

  Future<void> loadMedicines() async {
    _isLoading = true;
    notifyListeners();

    try {
      _medicines = await _db.getMedicines();
    } catch (e) {
      _medicines = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMedicine(Medicine medicine) async {
    final id = await _db.insertMedicine(medicine);
    final newMedicine = medicine.copyWith(id: id);

    if (_shouldNotify(newMedicine)) {
      await _scheduleNotifications(newMedicine);
    }

    _medicines.insert(0, newMedicine);
    notifyListeners();
  }

  Future<void> updateMedicine(Medicine medicine) async {
    await _db.updateMedicine(medicine);

    await _cancelMedicineNotifications(medicine.id!);
    if (_shouldNotify(medicine)) {
      await _scheduleNotifications(medicine);
    }

    final index = _medicines.indexWhere((m) => m.id == medicine.id);
    if (index != -1) {
      _medicines[index] = medicine;
    }
    notifyListeners();
  }

  Future<void> deleteMedicine(int id) async {
    await _db.deleteMedicine(id);
    await _cancelMedicineNotifications(id);
    _medicines.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> toggleActive(Medicine medicine) async {
    final updated = medicine.copyWith(isActive: !medicine.isActive);
    await updateMedicine(updated);
  }

  bool _shouldNotify(Medicine medicine) {
    if (!medicine.isActive) return false;
    if (medicine.medicationType == 'shortTerm' &&
        medicine.endDate != null &&
        medicine.endDate!.isBefore(DateTime.now())) {
      return false;
    }
    return true;
  }

  Future<void> _scheduleNotifications(Medicine medicine) async {
    for (final timeStr in medicine.reminderTimes) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      try {
        await _notificationService.scheduleNotification(
          id: medicine.id! * 100 + medicine.reminderTimes.indexOf(timeStr),
          title: 'İlaç Zamanı!',
          body: '${medicine.name} - ${medicine.dosage}',
          hour: hour,
          minute: minute,
        );
      } catch (_) {
      }
    }
  }

  Future<void> _cancelMedicineNotifications(int medicineId) async {
    for (var i = 0; i < 10; i++) {
      try {
        await _notificationService.cancelNotification(medicineId * 100 + i);
      } catch (_) {
      }
    }
  }
}
