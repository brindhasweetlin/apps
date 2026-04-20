import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:translator/translator.dart';

void main() {
  runApp( MaterialApp(home:TranslationScreen()));
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _text = "";
  String _translatedText = "";
  final translator = GoogleTranslator();
  // New variables for language selection
  String _selectedLocale = 'hi_IN'; // Default speech locale
  String _selectedLangCode = 'hi';   // Default translation code

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('onStatus: $val'),
        onError: (val) => print('onError: $val'),
        debugLogging: true
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          // Set language to Hindi or Telugu
          onDevice:false,
          listenMode: stt.ListenMode.dictation ,
          partialResults: true,
          localeId: _selectedLocale,
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            if (val.finalResult) {
              _translateText(_text);
            }
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _translateText(String text) async {
    // Translate from Hindi/Telugu to English
    Translation translation = await translator.translate(text, from: _selectedLangCode, to: 'en');
    setState(() {
      _translatedText = translation.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Center(child: Text("Hindi/Telugu/Tamil to English"),),
        backgroundColor: Colors.blue),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Text("Select Language: "),
              DropdownButton<String>(
                value: _selectedLocale,
                items: [
                  DropdownMenuItem(child: Text("Hindi"), value: "hi_IN"),
                  DropdownMenuItem(child: Text("Telugu"), value: "te_IN"),
                  DropdownMenuItem(child: Text("Tamil"), value:"ta_IN")
                ],
                onChanged: (String? value) {
                  setState(() {
                    _selectedLocale = value!;
                    _selectedLangCode = value.substring(0, 2); // Extract 'hi' or 'te'
                    _text = "Press button and speak";
                    _translatedText = "";
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
              Expanded(child: Text("Original: \n\n$_text"),flex:2),
              Expanded(child: Text("Translated: \n\n$_translatedText"),flex:2),
              Center(
                child: Flexible(
                  flex:1,
                  child: FloatingActionButton.extended(
                    label:Text(_isListening ? "Listening..." : "Press button and speak"),
                    onPressed: _listen,
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    backgroundColor: _isListening ? Colors.red : Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
