import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'splash_screen.dart';
import 'medicine_model.dart';
import 'medicine_dialog.dart';
import 'support_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3A5A40)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final Map<DateTime, List<Medicine>> _medicineEvents = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
  }

  List<Medicine> _getEventsForDay(DateTime day) {
    return _medicineEvents[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _showMedicineDialog(selectedDay);
    }
  }

  Color _getDateColor(DateTime day) {
    final events = _getEventsForDay(day);
    if (events.isEmpty) return Colors.transparent;
    
    bool allTaken = events.every((medicine) => medicine.isTaken);
    return allTaken ? Colors.green : Colors.red;
  }

  void _showMedicineDialog(DateTime selectedDay) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MedicineDialog(
        selectedDay: selectedDay,
        medicines: _getEventsForDay(selectedDay),
        onSave: (List<Medicine> medicines) {
          setState(() {
            _medicineEvents[DateTime(
              selectedDay.year,
              selectedDay.month,
              selectedDay.day,
            )] = medicines;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A5A40),
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Pulse',
              style: GoogleFonts.damion(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF3A5A40),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final color = _getDateColor(day);
                if (color == Colors.transparent) return null;
                
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMedicineDialog(_selectedDay ?? DateTime.now()),
        backgroundColor: const Color(0xFF3A5A40),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      persistentFooterButtons: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A5A40),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SupportPage()),
            );
          },
          child: const Text(
            'Go to Support Page',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
