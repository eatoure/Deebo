import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_spinkit/flutter_spinkit.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lyrics Censorship Tool',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.black87)),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedFile;
  String _keywords = '';
  String _mode = 'Mute';
  bool _isProcessing = false;
  Future<void> _selectFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _processFile() async {
    if (_selectedFile == null) {
      _showSnackBar('Please select an MP3 file first.');
      return;
    }
    setState(() {
      _isProcessing = true;
    });
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://127.0.0.1:5000/process'),
      );
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        await _selectedFile!.readAsBytes(),
        filename: _selectedFile!.path.split('/').last,
      ));
      request.fields['keywords'] = _keywords;
      request.fields['mode'] = _mode;
      var response = await request.send();
      if (response.statusCode == 200) {
        _showSnackBar('File processed successfully!');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SuccessScreen()),
        );
      } else {
        _showSnackBar('Processing failed. Try again.');
      }
    } catch (e) {
      _showSnackBar('An error occurred: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lyrics Censorship Tool'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _selectFile,
              icon: Icon(Icons.upload_file),
              label: Text('Select MP3 File'),
            ),
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Selected: ${_selectedFile!.path.split('/').last}'),
              ),
            TextField(
              decoration:
                  InputDecoration(labelText: 'Keywords (comma-separated)'),
              onChanged: (value) => _keywords = value,
            ),
            DropdownButton<String>(
              value: _mode,
              onChanged: (value) => setState(() => _mode = value!),
              items: ['Mute', 'Beep', 'Remove', 'Replace']
                  .map((mode) =>
                      DropdownMenuItem(value: mode, child: Text(mode)))
                  .toList(),
            ),
            SizedBox(height: 20),
            _isProcessing
                ? SpinKitWave(color: Colors.blue, size: 50.0)
                : ElevatedButton.icon(
                    onPressed: _processFile,
                    icon: Icon(Icons.send),
                    label: Text('Process File'),
                  ),
          ],
        ),
      ),
    );
  }
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Success')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 100),
            SizedBox(height: 20),
            Text(
              'File processed successfully!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}