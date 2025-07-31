import 'package:flutter/material.dart';
import 'package:yoga_session_app/models/pose.dart';
import 'package:yoga_session_app/screens/session_screen.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  late Future<YogaSession> _sessionFuture;

  @override
  void initState() {
    super.initState();
    print('PreviewScreen initState called at ${DateTime.now()}');
    _sessionFuture = _loadSession();
  }

  Future<YogaSession> _loadSession() async {
    print('Starting _loadSession at ${DateTime.now()}');
    try {
      print('Attempting to load poses.json');
      final String jsonString = await DefaultAssetBundle.of(
        context,
      ).loadString('assets/poses.json');
      print(
        'JSON loaded successfully at ${DateTime.now()}: ${jsonString.substring(0, 100)}...',
      );
      final session = YogaSession.fromJson(jsonString);
      print(
        'Session parsed with ${session.sequence.length} sequences at ${DateTime.now()}',
      );
      return session;
    } catch (e, stackTrace) {
      print('Error loading JSON at ${DateTime.now()}: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building widget at ${DateTime.now()}');
    return Scaffold(
      appBar: AppBar(title: const Text('Yoga Session Preview')),
      body: FutureBuilder<YogaSession>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            print('Waiting for data at ${DateTime.now()}');
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(
              'Error in FutureBuilder at ${DateTime.now()}: ${snapshot.error}',
            );
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final session = snapshot.data!;
          print(
            'Data received with ${session.sequence.length} sequences at ${DateTime.now()}',
          );
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: session.sequence.length,
                  itemBuilder: (context, index) {
                    final sequence = session.sequence[index];
                    return ListTile(
                      leading: Image.asset(
                        'assets/images/${session.images[sequence.script.first.imageRef]}',
                        width: 50,
                        height: 50,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.error),
                      ),
                      title: Text(sequence.name),
                      subtitle: Text(
                        'Duration: ${sequence.durationSec} seconds',
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  onPressed: () {
                    print('Navigating to SessionScreen at ${DateTime.now()}');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SessionScreen(session: session),
                      ),
                    );
                  },
                  child: const Icon(Icons.play_arrow),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
