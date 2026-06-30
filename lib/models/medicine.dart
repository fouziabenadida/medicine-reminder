class Medicine {
  final int? id;
  final String name;
  final String dosage;
  final String? note;
  final List<String> reminderTimes;
  final bool isActive;
  final DateTime createdAt;
  final String medicationType; // 'shortTerm' or 'longTerm'
  final DateTime? endDate;

  Medicine({
    this.id,
    required this.name,
    required this.dosage,
    this.note,
    required this.reminderTimes,
    this.isActive = true,
    DateTime? createdAt,
    this.medicationType = 'longTerm',
    this.endDate,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'note': note,
      'reminderTimes': reminderTimes.join(','),
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'medicationType': medicationType,
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<String, dynamic> map) {
    return Medicine(
      id: map['id'] as int?,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      note: map['note'] as String?,
      reminderTimes: (map['reminderTimes'] as String).split(','),
      isActive: (map['isActive'] as int) == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      medicationType: (map['medicationType'] as String?) ?? 'longTerm',
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
    );
  }

  Medicine copyWith({
    int? id,
    String? name,
    String? dosage,
    String? note,
    List<String>? reminderTimes,
    bool? isActive,
    DateTime? createdAt,
    String? medicationType,
    DateTime? endDate,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      note: note ?? this.note,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      medicationType: medicationType ?? this.medicationType,
      endDate: endDate ?? this.endDate,
    );
  }
}
