import 'package:hive/hive.dart';
import '../models/medicine.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _boxName = 'medicines';

  Future<Box> get _box async => await Hive.openBox(_boxName);

  Future<int> insertMedicine(Medicine medicine) async {
    final box = await _box;
    final map = medicine.toMap();
    map.remove('id');
    final key = await box.add(map);
    map['id'] = key;
    await box.put(key, map);
    return key;
  }

  Future<List<Medicine>> getMedicines() async {
    final box = await _box;
    return box.toMap().entries.map((entry) {
      final map = Map<String, dynamic>.from(entry.value as Map);
      map['id'] = entry.key;
      return Medicine.fromMap(map);
    }).toList();
  }

  Future<Medicine?> getMedicine(int id) async {
    final box = await _box;
    final data = box.get(id);
    if (data == null) return null;
    final map = Map<String, dynamic>.from(data as Map);
    map['id'] = id;
    return Medicine.fromMap(map);
  }

  Future<void> updateMedicine(Medicine medicine) async {
    final box = await _box;
    await box.put(medicine.id, medicine.toMap());
  }

  Future<void> deleteMedicine(int id) async {
    final box = await _box;
    await box.delete(id);
  }
}
