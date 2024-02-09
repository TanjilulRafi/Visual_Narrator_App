import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'functions/modal.bottom.sheet.menu.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  EasyLoading.instance
    ..dismissOnTap = false
    ..userInteractions = false
    ..maskType = EasyLoadingMaskType.black
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visual Narrator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      builder: EasyLoading.init(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  String? _caption;
  late FlutterTts flutterTts;
  
  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts(); // Initialize flutterTts in initState
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:const Text(
          'Visual Narrator',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Set font weight to bold
            fontSize: 25.0, // Adjust font size as needed
          ),
        ),
        centerTitle: true,
        
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(
                    _image!,
                    width: 300,
                    height: 300,
                  )
                : const Text('No image selected.'),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _image != null
                  ? ElevatedButton(
                      onPressed: () async => await _generateCaptionApi(_image!)
                          .then((value) => setState(() => _caption = value)),
                      child: const Text('Generate Caption'),
                    )
                  : const SizedBox(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _caption != null
                  ? Column(
                      children: [
                        Text(
                          _caption!,
                          style: const TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                        ),
                        ElevatedButton(
                          onPressed: () => speakCaption(_caption!),
                          child: const Text('Speak Again'),
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_a_photo),
        onPressed: () async =>
            await modalBottomSheetMenu(context).then((pk) => setState(() {
                  _image = pk;
                  _caption = null;
                })),
      ),
    );
  }
  Future<void> speakCaption(String caption) async {
    if (caption.isNotEmpty) {
      await flutterTts.speak(caption);
    }
  }
}

Future<String?> _generateCaptionApi(File image) async {
  EasyLoading.show(status: 'Please Wait...');
  debugPrint('Getting image Rafi: $image');
  List<int> imageBytes = image.readAsBytesSync();
  String base64Image = base64Encode(imageBytes);
  debugPrint('Getting base64Image Rafi: $base64Image');
  var headers = {'Content-Type': 'application/json'};
  var request =
      http.Request('POST', Uri.parse('http://10.0.2.2:8000/caption_generate'));
  request.body = json.encode({"image": base64Image});
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  final body = await response.stream.bytesToString();
  final decoded = json.decode(body);
  debugPrint('Getting Response Rafi: $decoded');
  if (decoded['success'] == true) {
    debugPrint('Getting Response Rafi: ${decoded['caption']}');
    final caption = decoded['caption'];
    EasyLoading.dismiss();
    await speakCaption(caption);
    return caption;
  } else {
    debugPrint('Getting Response Rafi: ${decoded['message']}');
    EasyLoading.showError(decoded['message']);
    return null;
  }
}
Future<void> speakCaption(String caption) async {
  if (caption.isNotEmpty) {
    var flutterTts = FlutterTts();
    await flutterTts.speak(caption);
  }
}

