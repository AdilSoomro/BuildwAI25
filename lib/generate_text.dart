import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GenerateTextPage extends StatefulWidget {
  const GenerateTextPage({super.key});

  @override
  _GenerateTextPageState createState() => _GenerateTextPageState();
}

class _GenerateTextPageState extends State<GenerateTextPage> {
  final TextEditingController _inputController = TextEditingController();
  String _outputText = '';

  void _generateOutput() async {
    final response = await _model.generateContent([
      Content.text(_inputController.text)
    ]);

    print(response.text);

    setState(() {
      _outputText = response.text;
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart App Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _inputController,
              decoration: InputDecoration(
                labelText: 'Enter something',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateOutput,
              child: Text('Generate'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _outputText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final apiKey = "your_own_key";
  var _model;

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
      model: "gemini-2.5-pro-preview-05-06",
      apiKey: apiKey,
    );
  }

}