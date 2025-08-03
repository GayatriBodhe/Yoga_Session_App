import 'dart:convert';

class Script {
  final String text;
  final int startSec;
  final int endSec;
  final String imageRef;

  Script({
    required this.text,
    required this.startSec,
    required this.endSec,
    required this.imageRef,
  });

  factory Script.fromJson(Map<String, dynamic> json) {
    return Script(
      text: json['text'],
      startSec: json['startSec'],
      endSec: json['endSec'],
      imageRef: json['imageRef'],
    );
  }
}

class Sequence {
  final String type;
  final String name;
  final String audioRef;
  final int durationSec;
  final int? iterations;
  final bool? loopable;
  final List<Script> script;

  Sequence({
    required this.type,
    required this.name,
    required this.audioRef,
    required this.durationSec,
    this.iterations,
    this.loopable,
    required this.script,
  });

  factory Sequence.fromJson(Map<String, dynamic> json) {
    return Sequence(
      type: json['type'],
      name: json['name'],
      audioRef: json['audioRef'],
      durationSec: json['durationSec'],
      iterations: json['iterations'],
      loopable: json['loopable'],
      script:
          (json['script'] as List)
              .map((item) => Script.fromJson(item))
              .toList(),
    );
  }
}

class YogaSession {
  final Map<String, String> images;
  final Map<String, String> audio;
  final List<Sequence> sequence;

  YogaSession({
    required this.images,
    required this.audio,
    required this.sequence,
  });

  factory YogaSession.fromJson(String jsonString) {
    final data = jsonDecode(jsonString);
    return YogaSession(
      images: {'base': 'Base.png', 'cat': 'Cat.png', 'cow': 'Cow.png'},
      audio: {
        'intro': 'CatCowIntro.mp3',
        'loop': 'CatCowLoop.mp3',
        'outro': 'CatCowOutro_fixed.mp3', // Updated
      },
      sequence:
          (data['sequence'] as List)
              .map((item) => Sequence.fromJson(item))
              .toList(),
    );
  }
}
