import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:yoga_session_app/models/pose.dart';
import 'package:yoga_session_app/screens/preview_screen.dart';

class SessionScreen extends StatefulWidget {
  final YogaSession session;
  final int startSequenceIndex;

  const SessionScreen({
    super.key,
    required this.session,
    this.startSequenceIndex = 0,
  });

  @override
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late int currentSequenceIndex;
  int currentScriptIndex = 0;
  bool isPlaying = true;
  double progress = 0.0;
  double pausedProgress = 0.0;
  double opacity = 0.0;
  Timer? timer;
  int currentIteration = 0; // Track current iteration for breath_cycle
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer bgMusicPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    currentSequenceIndex = widget.startSequenceIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        opacity = 1.0;
      });
      _startSession();
    });
  }

  void _startSession() {
    if (currentSequenceIndex < widget.session.sequence.length) {
      _playSequence(widget.session.sequence[currentSequenceIndex]);
    }
  }

  Future<void> _playSequence(Sequence sequence) async {
    try {
      String audioPath = 'audio/${widget.session.audio[sequence.audioRef]}';

      int iterationCount =
          sequence.type == 'loop' ? (sequence.iterations ?? 1) : 1;

      for (int i = 0; i < iterationCount; i++) {
        currentIteration = i + 1; // Update iteration number (1-based)
        setState(() {
          // Force UI update with new iteration
          progress =
              (i == 0 && pausedProgress > 0 && pausedProgress < 1.0)
                  ? pausedProgress
                  : 0.0;
          currentScriptIndex = 0;
          opacity = 0.0;
        });

        await Future.delayed(const Duration(milliseconds: 100), () {
          setState(() {
            opacity = 1.0;
          });
        });

        await audioPlayer.setSource(AssetSource(audioPath));
        if (i == 0 && pausedProgress > 0 && pausedProgress < 1.0) {
          try {
            await audioPlayer.seek(
              Duration(
                seconds: (pausedProgress * sequence.durationSec).toInt(),
              ),
            );
          } catch (e) {
            print('Seek failed, starting from beginning: $e');
          }
        }
        if (isPlaying) {
          await audioPlayer.play(AssetSource(audioPath));
        }

        timer?.cancel(); // Cancel any existing timer
        timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
          if (isPlaying && mounted) {
            final totalDuration = sequence.durationSec;
            setState(() {
              progress += 0.1 / totalDuration;
              _updateScript(sequence);
            });
            if (progress >= 1.0 && isPlaying) {
              // Only move to next if playing
              timer.cancel();
            }
          }
        });

        while (progress < 1.0 && mounted) {
          if (isPlaying) {
            await Future.delayed(const Duration(milliseconds: 100));
          } else {
            await Future.doWhile(() async {
              await Future.delayed(const Duration(milliseconds: 100));
              return !isPlaying && progress < 1.0 && mounted;
            });
          }
        }
        timer?.cancel();
        if (isPlaying) {
          await audioPlayer.stop();
        }
      }

      await audioPlayer.stop();
      if (isPlaying) {
        _moveToNextSequence();
      }
    } catch (e) {
      if (isPlaying) {
        _moveToNextSequence();
      }
    }
  }

  void _updateScript(Sequence sequence) {
    if (!mounted) return;
    final currentTime = (progress * sequence.durationSec).toInt();

    for (int i = 0; i < sequence.script.length; i++) {
      final script = sequence.script[i];
      if (currentTime >= script.startSec && currentTime < script.endSec) {
        if (currentScriptIndex != i) {
          setState(() {
            currentScriptIndex = i;
            opacity = 0.0;
            Future.delayed(const Duration(milliseconds: 100), () {
              setState(() {
                opacity = 1.0;
              });
            });
          });
        }
        break;
      }
    }
  }

  void _moveToNextSequence() {
    if (currentSequenceIndex < widget.session.sequence.length - 1) {
      setState(() {
        currentSequenceIndex++;
        progress = 0.0;
        currentScriptIndex = 0;
        pausedProgress = 0.0;
        currentIteration = 0; // Reset iteration for new sequence
        _startSession();
      });
    } else {
      audioPlayer.stop();
      bgMusicPlayer.stop();
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
                'Session Complete',
                style: TextStyle(color: Color.fromARGB(255, 152, 171, 255)),
              ),
              content: const Text(
                'Great job! You completed the yoga session.',
                style: TextStyle(color: Colors.black87),
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreviewScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: const Text('OK', style: TextStyle(color: Colors.teal)),
                ),
              ],
            ),
      );
    }
  }

  void _skipSequence() {
    timer?.cancel();
    audioPlayer.stop();
    setState(() {
      progress = 0.0;
      currentScriptIndex = 0;
      opacity = 0.0;
      pausedProgress = 0.0;
      currentIteration = 0; // Reset iteration on skip
    });
    audioPlayer.release();
    Future.delayed(const Duration(milliseconds: 100), () {
      _moveToNextSequence();
    });
  }

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        if (pausedProgress > 0) {
          _startSession();
        } else {
          audioPlayer.resume();
        }
      } else {
        pausedProgress = progress;
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
    String iterationText = '';
    if (sequence.name == 'breath_cycle' && currentIteration > 0) {
      iterationText =
          '${currentIteration == 1
              ? '1st'
              : currentIteration == 2
              ? '2nd'
              : currentIteration == 3
              ? '3rd'
              : 'last'} iteration';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          sequence.name,
          style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromARGB(255, 161, 168, 248), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 161, 168, 248), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 300),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/${widget.session.images[script.imageRef]}',
                      height: 300,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        script.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (iterationText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            iterationText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.teal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Time: ${(progress * sequence.durationSec).toInt()}s',
                style: const TextStyle(fontSize: 16, color: Colors.teal),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Colors.purple,
                  ),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTapDown: (_) => setState(() {}),
                    onTapUp: (_) => setState(() {}),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform:
                          Matrix4.identity()..scale(isPlaying ? 1.0 : 1.1),
                      child: ElevatedButton(
                        onPressed: _togglePlayPause,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          elevation: isPlaying ? 4 : 8,
                        ),
                        child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTapDown: (_) => setState(() {}),
                    onTapUp: (_) => setState(() {}),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(1.0),
                      child: ElevatedButton(
                        onPressed: _skipSequence,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          elevation: 4,
                        ),
                        child: const Text(
                          'Skip',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
