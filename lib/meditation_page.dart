import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _timer;
  final _minutesController = TextEditingController(text: '5');
  bool _isActive = false;
  int _remainingSeconds = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _initAudio();
  }

  Future<void> _initAudio() async {
    await _audioPlayer.setAsset('assets/meditation_music.mp3');
    await _audioPlayer.setLoopMode(LoopMode.one);
  }

  void _toggleMusic() {
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
      if (_isMusicPlaying) {
        _audioPlayer.play();
      } else {
        _audioPlayer.pause();
      }
    });
  }

  void _startMeditation() {
    final minutes = int.tryParse(_minutesController.text) ?? 5;
    setState(() {
      _isActive = true;
      _remainingSeconds = minutes * 60;
    });
    _controller.forward();
    _startTimer();
    if (_isMusicPlaying) {
      _audioPlayer.play();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _stopMeditation();
      }
    });
  }

  void _stopMeditation() {
    _timer?.cancel();
    _controller.stop();
    _audioPlayer.pause();
    setState(() {
      _isActive = false;
      _isMusicPlaying = false;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
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
            'Guided Meditation',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          actions: [
            if (_isActive)
              IconButton(
                icon: Icon(
                  _isMusicPlaying ? Icons.music_note : Icons.music_off,
                  color: Colors.white,
                ),
                onPressed: _toggleMusic,
              ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isActive) ...[
                const Text(
                  'Set Duration (minutes)',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A5A40),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A5A40),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _startMeditation,
                  child: const Text(
                    'Start Meditation',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ] else ...[
                Text(
                  _formatTime(_remainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A5A40),
                  ),
                ),
                const SizedBox(height: 40),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _animation.value,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF3A5A40).withOpacity(0.3),
                              const Color(0xFFA3B18A).withOpacity(0.3),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3A5A40).withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.spa,
                            size: 100,
                            color: Color(0xFF3A5A40),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _stopMeditation,
                  child: const Text(
                    'Stop',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
} 