import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BMICalculatorPage extends StatefulWidget {
  const BMICalculatorPage({super.key});

  @override
  State<BMICalculatorPage> createState() => _BMICalculatorPageState();
}

class _BMICalculatorPageState extends State<BMICalculatorPage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _gender = 'male';
  double? _bmi;
  double? _bmiPrime;
  Map<String, dynamic>? _healthyRange;

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height == null || weight == null) return;

    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    final bmiPrime = bmi / 25;

    final minWeight = 18.5 * heightInMeters * heightInMeters;
    final maxWeight = 25 * heightInMeters * heightInMeters;

    setState(() {
      _bmi = bmi;
      _bmiPrime = bmiPrime;
      _healthyRange = {
        'minWeight': minWeight,
        'maxWeight': maxWeight,
      };
    });
  }

  Widget _buildInputField(String label, TextEditingController controller, String suffix) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 200,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffix: Text(suffix),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F3E8), Color(0xFFA3B18A)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFF3A5A40),
          title: Text(
            'BMI Calculator',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInputField('Height', _heightController, 'cm'),
                  _buildInputField('Weight', _weightController, 'kg'),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 'male',
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      const Text('Male'),
                      const SizedBox(width: 20),
                      Radio(
                        value: 'female',
                        groupValue: _gender,
                        onChanged: (value) => setState(() => _gender = value!),
                      ),
                      const Text('Female'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3A5A40),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: _calculateBMI,
                    child: const Text(
                      'Calculate BMI',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  if (_bmi != null) ...[
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Your BMI: ${_bmi!.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3A5A40),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Healthy BMI range: 18.5 kg/m² - 25 kg/m²',
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Healthy weight for your height: '
                            '${_healthyRange!['minWeight'].toStringAsFixed(1)} kg - '
                            '${_healthyRange!['maxWeight'].toStringAsFixed(1)} kg',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'BMI Prime: ${_bmiPrime!.toStringAsFixed(1)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 