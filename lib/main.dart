import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  Process? _process;
  Uint8List? _imageData;
  String _label = "";

  void _runPOC() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _process = await Process.start('py', ['POC.py']);
      _process?.stdout.transform(utf8.decoder).listen((data) {
        final parts = data.trim().split(',');
        if (parts.length == 2) {
          final frameBytes = base64.decode(parts[0]);
          setState(() {
            _imageData = frameBytes;
            _label = parts[1];
          });
        }
      });
      _process?.stderr.transform(utf8.decoder).listen((data) {
        print(data); // Print POC.py errors to console
      });
    } catch (e) {
      print(e.toString()); // Print exception
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _stopPOC() {
    _process?.kill();
    setState(() {
      _process = null;
      _imageData = null;
      _label = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POC App'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_imageData != null)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Image.memory(
                        _imageData!,
                        gaplessPlayback: true,
                        fit: BoxFit.contain,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 16),
                  Text(_label),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _runPOC,
                    child: const Text('Run POC'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _stopPOC,
                    child: const Text('Stop POC'),
                  ),
                ],
              ),
      ),
    );
  }
}
