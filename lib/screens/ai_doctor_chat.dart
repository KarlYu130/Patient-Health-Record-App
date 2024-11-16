import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart'; // Add this import
import 'package:flutter_markdown/flutter_markdown.dart'; // Add this import
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Add this import
import '../models/patient.dart';
import '../helpers/database_helper.dart'; // Import DatabaseHelper
import '../models/health_record.dart'; // Add this import
import '../models/chat_message.dart'; // Add this import

class AiDoctorChat extends StatefulWidget {
  final Patient patient; // Add patient data

  const AiDoctorChat({super.key, required this.patient});

  @override
  _AiDoctorChatState createState() => _AiDoctorChatState();
}

class _AiDoctorChatState extends State<AiDoctorChat> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late GenerativeModel _model; // Initialize GenerativeModel
  late String apiKey;

  @override
  void initState() {
    super.initState();
    apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      _showError('API key is missing. Please set GEMINI_API_KEY in .env file.');
      return;
    }
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    _sendPatientData();
  }

  void _showError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    });
  }

  Future<void> _sendPatientData() async {
    try {
      // Prepare patient data
      String patientData = '''
      Patient Name: ${widget.patient.name}
      Age: ${widget.patient.age}
      Sex: ${widget.patient.sex ?? 'N/A'}
      Condition: ${widget.patient.condition}
      ''';

      // Fetch health records
      List<HealthRecord> records =
          await DatabaseHelper.instance.getHealthRecords(widget.patient.id!);
      String healthData = records.isNotEmpty ? records.map((r) => '''
      Recorded on ${r.timestamp.toLocal().toString().split(' ')[0]}:
        Body Temperature: ${r.bodyTemperature ?? 'N/A'} °C
        Blood Pressure: ${r.systolic ?? 'N/A'}/${r.diastolic ?? 'N/A'} mm Hg
        Blood Glucose Level: ${r.bloodGlucoseLevel ?? 'N/A'} mg/dL
        Blood Oxygen Level: ${r.bloodOxygenLevel ?? 'N/A'} %
        Heart Rate: ${r.heartRate ?? 'N/A'} bpm
        Condition: ${r.condition ?? 'N/A'}
      ''').join('\n') : 'No health records available.';

      patientData += '''
      \nHealth Records:
      $healthData
      ''';

      var response = await _model.startChat(history: [
        Content.text(
            'Imagine you are a Doctor. You are going to analyze the health condition of a patient from Sri Lanka rural area.')
      ]).sendMessage(Content.text(patientData));
      setState(() {
        _messages.add(ChatMessage(
            text: response.text ?? 'No response received.',
            isUser: false)); // Fixed line
      });
    } catch (e) {
      setState(() {
        _messages
            .add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
      });
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true));
    });

    _controller.clear();

    try {
      var chat = _model.startChat();
      var response = await chat.sendMessage(Content.text(message));

      setState(() {
        _messages.add(ChatMessage(
            text: response.text ?? 'No response received.',
            isUser: false)); // Fixed line
      });
    } catch (e) {
      setState(() {
        _messages
            .add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
      });
    }
  }

  Future<void> _sendImage(String imagePath) async {
    Future<DataPart> fileToPart(String mimeType, String path) async {
      return DataPart(mimeType, await File(path).readAsBytes());
    }

    // Example prompt for image analysis
    String prompt = 'Please analyze this image.';
    DataPart image = await fileToPart('image/jpeg', imagePath);

    setState(() {
      _messages.add(ChatMessage(
          imagePath: imagePath, isUser: true)); // Show the sent image
    });

    try {
      var chat = _model.startChat();
      var responses =
          chat.sendMessageStream(Content.multi([TextPart(prompt), image]));

      await for (final response in responses) {
        setState(() {
          _messages.add(ChatMessage(
              text: response.text ?? 'No response received.', isUser: false));
        });
      }
    } catch (e) {
      setState(() {
        _messages
            .add(ChatMessage(text: 'Error: ${e.toString()}', isUser: false));
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick from gallery'),
                onTap: () async {
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    await _sendImage(pickedFile.path);
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () async {
                  final XFile? pickedFile =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    await _sendImage(pickedFile.path);
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.chatWithDoctor ?? 'Chat with Doctor'), // Updated
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.teal[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: msg.isUser
                        ? msg.imagePath != null
                            ? Image.file(
                                File(msg.imagePath!)) // Display the sent image
                            : Text(msg.text ?? '')
                        : msg.text != null
                            ? MarkdownBody(data: msg.text ?? '')
                            : Container(),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, color: Colors.teal),
                  onPressed: _pickImage, // Add button to pick and send image
                  tooltip: AppLocalizations.of(context)?.addImage ?? 'Add Image', // Updated
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)?.typeYourMessage ?? 'Type your message...', // Updated
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: () => _sendMessage(_controller.text),
                  tooltip: AppLocalizations.of(context)?.send ?? 'Send', // Updated
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ...existing methods...
}
