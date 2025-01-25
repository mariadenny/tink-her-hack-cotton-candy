import 'package:flutter/material.dart';
import 'medicine_model.dart';

class MedicineDialog extends StatefulWidget {
  final DateTime selectedDay;
  final List<Medicine> medicines;
  final Function(List<Medicine>) onSave;

  const MedicineDialog({
    super.key,
    required this.selectedDay,
    required this.medicines,
    required this.onSave,
  });

  @override
  State<MedicineDialog> createState() => _MedicineDialogState();
}

class _MedicineDialogState extends State<MedicineDialog> {
  late List<Medicine> _medicines;
  final _nameController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  bool _allDays = false;

  @override
  void initState() {
    super.initState();
    _medicines = List.from(widget.medicines);
  }

  void _toggleAllDays(bool? value) {
    setState(() {
      _allDays = value ?? false;
      for (int i = 0; i < _selectedDays.length; i++) {
        _selectedDays[i] = _allDays;
      }
    });
  }

  void _toggleDay(int index, bool? value) {
    setState(() {
      _selectedDays[index] = value ?? false;
      _allDays = _selectedDays.every((day) => day);
    });
  }

  Widget _buildDaySelector() {
    const days = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: _allDays,
              onChanged: _toggleAllDays,
            ),
            const Text('All Days'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            return Column(
              children: [
                Text(
                  days[index],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Checkbox(
                  value: _selectedDays[index],
                  onChanged: (value) => _toggleDay(index, value),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  void _addMedicine() {
    if (_nameController.text.isEmpty) return;

    setState(() {
      _medicines.add(Medicine(
        name: _nameController.text,
        time: DateTime(
          widget.selectedDay.year,
          widget.selectedDay.month,
          widget.selectedDay.day,
          _selectedTime.hour,
          _selectedTime.minute,
        ),
        selectedDays: List.from(_selectedDays),
      ));
      _nameController.clear();
      _selectedDays.fillRange(0, _selectedDays.length, false);
      _allDays = false;
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Medicines for ${widget.selectedDay.day}/${widget.selectedDay.month}/${widget.selectedDay.year}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _selectTime,
                child: Text(
                  _selectedTime.format(context),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _addMedicine,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDaySelector(),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _medicines.length,
              itemBuilder: (context, index) {
                final medicine = _medicines[index];
                return ListTile(
                  title: Text(medicine.name),
                  subtitle: Text(TimeOfDay.fromDateTime(medicine.time).format(context)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        value: medicine.isTaken,
                        onChanged: (value) {
                          setState(() {
                            medicine.isTaken = value ?? false;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _medicines.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onSave(_medicines);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
} 