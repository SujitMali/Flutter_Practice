import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({Key? key}) : super(key: key);

  @override
  State<SpeechScreen> createState() => SpeechScreenState();
}

class SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;

  bool _micActive = false;

  String _fullText = '';
  String _currentSegment = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  //! ---------------- MIC CONTROL ----------------

  Future<void> _startMic() async {
    if (_micActive) return;

    final available = await _speech.initialize(onStatus: _onSpeechStatus);
    if (!available) return;

    setState(() {
      _micActive = true;
    });

    _startListening();
  }

  void _startListening() {
    _speech.listen(
      listenFor: const Duration(minutes: 30),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        listenMode: stt.ListenMode.dictation,
      ),
      onResult: (result) {
        setState(() {
          _currentSegment = result.recognizedWords;
        });

        if (result.finalResult && _currentSegment.isNotEmpty) {
          setState(() {
            _fullText += (_fullText.isEmpty ? '' : ' ') + _currentSegment;
            _currentSegment = '';
          });
        }
      },
    );
  }

  void _onSpeechStatus(String status) {
    if (status == 'notListening' && _micActive) {
      _startListening(); // keep mic alive
    }
  }

  Future<void> _stopMic() async {
    if (!_micActive) return;

    await _speech.stop();

    setState(() {
      _micActive = false;
      _currentSegment = '';
    });
  }

  void _clearText() {
    setState(() {
      _fullText = '';
      _currentSegment = '';
    });
  }

  //todo -------------------------- UI -------------------------------
  @override
  Widget build(BuildContext context) {
    final displayText = (_fullText + ' ' + _currentSegment).trim();
    final sentences =
        _fullText
            .split(RegExp(r'[.!?]'))
            .where((s) => s.trim().isNotEmpty)
            .toList();

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white60,
        title: const Text("Speech To Text Converter"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(icon: const Icon(Icons.clear), onPressed: _clearText),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _micActive,
        glowColor: Colors.blueAccent,
        duration: const Duration(milliseconds: 600),
        repeat: true,
        child: GestureDetector(
          onLongPressStart: (_) => _startMic(),
          onLongPressEnd: (_) => _stopMic(),
          child: FloatingActionButton(
            shape: CircleBorder(),
            onPressed: () {},
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white60,
            child: Icon(_micActive ? Icons.mic : Icons.mic_none),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount:
                    sentences.length + (_currentSegment.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  // Finalized sentences
                  if (index < sentences.length) {
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          sentences[index].trim(),
                          style: const TextStyle(fontSize: 16, height: 1.4),
                        ),
                      ),
                    );
                  }

                  // Live speaking text
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    child: Text(
                      _currentSegment,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                  );
                },
              ),
            ),

            if (sentences.isEmpty && _currentSegment.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Text(
                  'Hold the button and speak',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


//!================================================================================================
// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:flutter/material.dart';
// import 'package:highlight_text/highlight_text.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// void main() {
//   runApp(MyApp());
// }
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Speech Converter',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: SpeechScreen(),
//     );
//   }
// }
// class SpeechScreen extends StatefulWidget {
//   //! State<T> here the T is simply the placeholder for Type T
//   @override
//   State<SpeechScreen> createState() => SpeechScreenState();
// }
// class SpeechScreenState extends State<SpeechScreen> {
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _text = 'Press the Button and start Speaking !';
//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//   }
//   @override
//   Widget build(Object context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Speech To Text Converter",
//           style: TextStyle(color: Colors.white60),
//         ),
//         backgroundColor: Colors.blueAccent,
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: AvatarGlow(
//         animate: _isListening,
//         glowColor: Colors.blueAccent,
//         glowRadiusFactor: 0.7,
//         duration: const Duration(milliseconds: 600),
//         repeat: true,
//         child: FloatingActionButton(
//           shape: CircleBorder(),
//           onPressed: _listen,
//           backgroundColor: Colors.lightBlueAccent,
//           child: Icon(_isListening ? Icons.mic : Icons.mic_none),
//         ),
//       ),
//       body: SingleChildScrollView(
//         reverse: true,
//         child: TextHighlight(text: _text, words: {}),
//       ),
//     );
//   }
//   void _listen() async {
//     if (!_isListening) {
//       //!Just becuase I wanted to wait for the mic to get initialize
//       bool available = await _speech.initialize();
//       if (available) {
//         setState(() {
//           _isListening = true;
//         });
//         await _speech.listen(
//           onResult: (val) {
//             setState(() {
//               _text = val.recognizedWords;
//             });
//             if (val.finalResult) {
//               setState(() {
//                 _isListening = false;
//               });
//             }
//           },
//         );
//       } else {
//         setState(() {
//           _isListening = false;
//           _speech.stop();
//         });
//       }
//     }
//   }
// }