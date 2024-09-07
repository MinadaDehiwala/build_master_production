import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:tflite_v2/tflite_v2.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<dynamic>? _recognitions;
  ui.Image? _annotatedImage;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      String? res = await Tflite.loadModel(
        model: "assets/model_unquant.tflite",
        labels: "assets/labels.txt",
        numThreads: 1,
        isAsset: true,
        useGpuDelegate: false,
      );
      print("Model loaded: $res");
    } catch (e) {
      print('Error loading model: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imageFile = File(image.path);
        });
        classifyImage(_imageFile!.path);
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> classifyImage(String path) async {
    try {
      var recognitions = await Tflite.runModelOnImage(
        path: path,
        numResults: 6,
        threshold: 0.05,
        imageMean: 127.5,
        imageStd: 127.5,
      );

      setState(() {
        _recognitions = recognitions;
      });

      if (_recognitions != null && _recognitions!.isNotEmpty) {
        _annotatedImage = await annotateImage(File(path), _recognitions!);
      }

      print('Classification Results: $_recognitions');
    } catch (e) {
      print('Error classifying image: $e');
    }
  }

  Future<ui.Image> annotateImage(File imageFile, List<dynamic> recognitions) async {
    final rawImageData = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(rawImageData);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));
    canvas.drawImage(image, Offset.zero, Paint());

    double textTop = 20.0;
    for (var recognition in recognitions) {
      final label = recognition['label'];
      final confidence = recognition['confidence'];

      final textPainter = TextPainter(
        text: TextSpan(
          text: '$label (${(confidence * 100).toStringAsFixed(1)}%)',
          style: const TextStyle(color: Colors.red, fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(20, textTop),
      );

      textTop += 40.0;
    }

    return await recorder.endRecording().toImage(image.width, image.height);
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/forum_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Content
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Back Button
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF20232D),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context); // Navigate back when the button is pressed
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Title
                  const Text(
                    'Gallery Classification',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Pick Image from Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_annotatedImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: SizedBox(
                          width: _annotatedImage!.width.toDouble(),
                          height: _annotatedImage!.height.toDouble(),
                          child: CustomPaint(
                            painter: ImagePainter(_annotatedImage!),
                          ),
                        ),
                      ),
                    )
                  else if (_imageFile != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.file(_imageFile!),
                    ),
                  const SizedBox(height: 20),
                  if (_recognitions != null && _recognitions!.isNotEmpty)
                    Column(
                      children: [
                        const Text(
                          'Classification Results',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true, // Ensures the ListView takes only the space needed
                          physics: const NeverScrollableScrollPhysics(), // Prevent scrolling inside the list
                          itemCount: _recognitions!.length,
                          itemBuilder: (context, index) {
                            var recognition = _recognitions![index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                              tileColor: Colors.white.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.3),
                                child: Text(
                                  '${(recognition['confidence'] * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              title: Text(
                                recognition['label'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
