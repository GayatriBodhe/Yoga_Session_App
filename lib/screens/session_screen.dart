import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:yoga_session_app/models/pose.dart';

class SessionScreen extends StatefulWidget {
  final YogaSession session;

  const SessionScreen({super.key, required this.session});

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  int currentSequenceIndex = 0;
  int currentScriptIndex = 0;
  bool isPlaying = true;
  double progress = 0.0;
  Timer? timer;
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer bgMusicPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  void _startSession() {
    if (currentSequenceIndex < widget.session.sequence.length) {
      _playSequence(widget.session.sequence[currentSequenceIndex]);
    }
  }

  Future<void> _playSequence(Sequence sequence) async {
    await audioPlayer.play(
      AssetSource('assets/audio/${widget.session.audio[sequence.audioRef]}'),
    );
    setState(() {
      progress = 0.0;
      currentScriptIndex = 0;
    });
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final totalDuration = sequence.durationSec;
      setState(() {
        progress += 0.1 / totalDuration;
        if (progress >= 1.0) {
          timer.cancel();
          audioPlayer.stop();
          _moveToNextSequence();
        } else {
          _updateScript(sequence);
        }
      });
    });
  }

  void _updateScript(Sequence sequence) {
    final currentTime = (progress * sequence.durationSec).toInt();
    final script = sequence.script[currentScriptIndex];
    if (currentTime >= script.endSec &&
        currentScriptIndex < sequence.script.length - 1) {
      setState(() {
        currentScriptIndex++;
      });
    }
  }

  void _moveToNextSequence() {
    if (currentSequenceIndex < widget.session.sequence.length - 1) {
      setState(() {
        currentSequenceIndex++;
        _startSession();
      });
    } else {
      audioPlayer.stop();
      bgMusicPlayer.stop();
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Session Complete'),
              content: const Text('Great job! You completed the yoga session.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        audioPlayer.resume();
        _startSession();
      } else {
        audioPlayer.pause();
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    audioPlayer.dispose();
    bgMusicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sequence = widget.session.sequence[currentSequenceIndex];
    final script = sequence.script[currentScriptIndex];
    return Scaffold(
      appBar: AppBar(title: Text(sequence.name)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/${widget.session.images[script.imageRef]}',
              height: 300,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => const Icon(Icons.error),
            ),
            const SizedBox(height: 20),
            Text(script.text, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Time: ${(progress * sequence.durationSec).toInt()}s'),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 40,
                  onPressed: _togglePlayPause,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
