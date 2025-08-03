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
    _sessionFuture = _loadSession();
  }

  Future<YogaSession> _loadSession() async {
    final String jsonString = await DefaultAssetBundle.of(
      context,
    ).loadString('assets/poses.json');
    return YogaSession.fromJson(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yoga Session Preview',
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
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
        child: FutureBuilder<YogaSession>(
          future: _sessionFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.teal),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            final session = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: session.sequence.length,
                    itemBuilder: (context, index) {
                      final sequence = session.sequence[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SessionScreen(
                                    session: session,
                                    startSequenceIndex: index,
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Image.asset(
                              'assets/images/${session.images[sequence.script.first.imageRef]}',
                              width: 50,
                              height: 50,
                              errorBuilder:
                                  (context, error, stackTrace) => const Icon(
                                    Icons.error,
                                    color: Colors.red,
                                  ),
                            ),
                            title: Text(
                              sequence.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                            subtitle: Text(
                              'Duration: ${sequence.durationSec} seconds${sequence.type == 'loop' ? ' (x${sequence.iterations} iterations)' : ''}',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTapDown: (_) => setState(() {}),
                    onTapUp: (_) => setState(() {}),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.identity()..scale(1.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SessionScreen(session: session),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: const Color.fromARGB(
                            255,
                            176,
                            165,
                            255,
                          ),
                          foregroundColor: Colors.white,
                          elevation: 4,
                        ),
                        child: const Text(
                          'Start Full Session',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
