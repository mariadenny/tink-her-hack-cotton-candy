class Medicine {
  String name;
  DateTime time;
  bool isTaken;
  List<bool> selectedDays;

  Medicine({
    required this.name,
    required this.time,
    this.isTaken = false,
    List<bool>? selectedDays,
  }) : selectedDays = selectedDays ?? List.generate(7, (_) => false);
} 