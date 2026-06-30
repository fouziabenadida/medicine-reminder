import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/medicine.dart';
import '../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  final Medicine? medicine;

  const AddMedicineScreen({super.key, this.medicine});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _noteController = TextEditingController();
  List<TimeOfDay> _selectedTimes = [];
  String _medicationType = 'longTerm';
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    if (widget.medicine != null) {
      _nameController.text = widget.medicine!.name;
      _dosageController.text = widget.medicine!.dosage;
      _noteController.text = widget.medicine!.note ?? '';
      _selectedTimes = widget.medicine!.reminderTimes
          .map((t) {
            final parts = t.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          })
          .toList();
      _medicationType = widget.medicine!.medicationType;
      _endDate = widget.medicine!.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Bildirim saati seç',
    );
    if (time != null && !_selectedTimes.contains(time)) {
      setState(() => _selectedTimes.add(time));
    }
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Bitiş tarihi seç',
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('En az bir bildirim saati ekleyin')),
      );
      return;
    }
    if (_medicationType == 'shortTerm' && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kısa süreli ilaçlar için bitiş tarihi gerekli')),
      );
      return;
    }

    final times = _selectedTimes
        .map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}')
        .toList();

    final medicine = Medicine(
      id: widget.medicine?.id,
      name: _nameController.text.trim(),
      dosage: _dosageController.text.trim(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      reminderTimes: times,
      isActive: widget.medicine?.isActive ?? true,
      createdAt: widget.medicine?.createdAt,
      medicationType: _medicationType,
      endDate: _medicationType == 'shortTerm' ? _endDate : null,
    );

    final provider = context.read<MedicineProvider>();
    try {
      if (widget.medicine != null) {
        await provider.updateMedicine(medicine);
      } else {
        await provider.addMedicine(medicine);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kaydedilirken hata: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine != null ? 'İlacı Düzenle' : 'İlaç Ekle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'İlaç Adı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medication),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'İlaç adı gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dozaj',
                  hintText: 'Örn: 1 tablet, 2 ölçek',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.science),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Dozaj gerekli' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Not (isteğe bağlı)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text(
                'İlaç Türü',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'shortTerm', label: Text('Kısa Süreli')),
                  ButtonSegment(value: 'longTerm', label: Text('Uzun Süreli')),
                ],
                selected: {_medicationType},
                onSelectionChanged: (v) => setState(() => _medicationType = v.first),
              ),
              if (_medicationType == 'shortTerm') ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _endDate != null
                            ? 'Bitiş: ${DateFormat('dd.MM.yyyy').format(_endDate!)}'
                            : 'Bitiş tarihi seçilmedi',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Seç'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Bildirim Saatleri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  FilledButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.add),
                    label: const Text('Saat Ekle'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedTimes.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Henüz bildirim saati eklenmedi',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ..._selectedTimes.map((time) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(_formatTime(time)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() => _selectedTimes.remove(time));
                      },
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(widget.medicine != null ? 'Güncelle' : 'Kaydet'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
