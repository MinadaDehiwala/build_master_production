import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for image upload
import 'my_builds_screen.dart'; // Import the MyBuildsScreen

class CreateBuildScreen extends StatefulWidget {
  const CreateBuildScreen({super.key});

  @override
  _CreateBuildScreenState createState() => _CreateBuildScreenState();
}

class _CreateBuildScreenState extends State<CreateBuildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _buildNameController = TextEditingController();
  File? _buildImage;
  bool _isLoading = false;

  List<String> _cpus = [];
  List<String> _gpus = [];
  List<String> _ramSizes = [];
  List<String> _storageOptions = [];

  final List<String> _motherboards = [
    'ASUS ROG Strix Z590-E Gaming',
    'MSI MPG B550 Gaming Edge',
    'Gigabyte Aorus X570 Master',
    'ASRock B450M Steel Legend',
    'ASUS Prime B460M-A',
    'MSI Z490-A Pro',
    'Gigabyte Z490 Aorus Elite',
    'ASRock Z490 Taichi',
    'ASUS TUF Gaming B550-Plus',
    'MSI MEG Z490 Godlike',
    'ASRock B550M Steel Legend',
    'ASUS ROG Crosshair VIII Hero',
    'Gigabyte Z590 Vision G',
    'MSI MPG Z490 Gaming Carbon',
    'ASRock B450 Pro4',
    'Gigabyte B550 Aorus Master',
    'ASUS ROG Strix Z490-E Gaming',
    'MSI MAG B550 Tomahawk',
    'ASRock Z390 Phantom Gaming 9',
    'ASUS TUF Gaming B450-Plus',
    'MSI MPG Z390 Gaming Pro',
    'Gigabyte Z490 Gaming X',
    'ASRock B550 Pro4',
    'ASUS ROG Maximus XII Hero',
    'Gigabyte Z590 Aorus Elite'
  ];

  String? _selectedCpu;
  String? _selectedGpu;
  String? _selectedRam;
  String? _selectedStorage;
  String? _selectedMotherboard;

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    final cpuData = await _loadJson('assets/parts/cpu.json');
    final gpuData = await _loadJson('assets/parts/gpu.json');
    final ramData = await _loadJson('assets/parts/ram.json');
    final ssdData = await _loadJson('assets/parts/ssd.json');
    final hddData = await _loadJson('assets/parts/hdd.json');

    setState(() {
      _cpus = _extractNames(cpuData);
      _gpus = _extractNames(gpuData);
      _ramSizes = _extractNames(ramData);
      _storageOptions = _extractNames(ssdData) + _extractNames(hddData);
      _storageOptions = _storageOptions.toSet().toList();
    });
  }

  Future<List<dynamic>> _loadJson(String path) async {
    final String response = await rootBundle.loadString(path);
    return json.decode(response) as List;
  }

  List<String> _extractNames(List<dynamic> data) {
    return data.map<String>((item) {
      if (item.containsKey('Brand') && item.containsKey('Model') && item['Brand'] != null && item['Model'] != null) {
        return '${item['Brand']} ${item['Model']}';
      }
      return 'Unknown';
    }).toList();
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _buildImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Upload image to Firebase Storage
  Future<String?> _uploadImage(User user) async {
    if (_buildImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instanceFor(
bucket: "gs://build-master-69.appspot.com"
)
          .ref()
          .child('build_images')
          .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_buildImage!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  // Store build information in Firestore
  Future<void> _storeBuild() async {
    if (_formKey.currentState?.validate() ?? false) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          // Upload build image if available
          final imageUrl = await _uploadImage(user);

          final build = {
            'userId': user.uid,
            'buildName': _buildNameController.text,
            'cpu': _selectedCpu,
            'gpu': _selectedGpu,
            'ram': _selectedRam,
            'storage': _selectedStorage,
            'motherboard': _selectedMotherboard,
            'imageUrl': imageUrl,
          };

          // Save build to Firestore
          await FirebaseFirestore.instance.collection('builds').add(build);

          // Show success message and navigate to MyBuildsScreen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Build created successfully!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MyBuildsScreen()),
          );
        } catch (e) {
          print('Error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
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
                image: AssetImage('assets/images/home_background.png'),
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
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
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
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Create New Build',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Select Your Components',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _buildNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF20232D),
                        hintText: 'Build Name',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                      style: const TextStyle(color: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a build name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildDropdown('Select Processor', _cpus, (value) {
                      setState(() {
                        _selectedCpu = value;
                      });
                    }, _selectedCpu),
                    const SizedBox(height: 20),
                    _buildDropdown('Select RAM Size', _ramSizes, (value) {
                      setState(() {
                        _selectedRam = value;
                      });
                    }, _selectedRam),
                    const SizedBox(height: 20),
                    _buildDropdown('Select Graphics Card', _gpus, (value) {
                      setState(() {
                        _selectedGpu = value;
                      });
                    }, _selectedGpu),
                    const SizedBox(height: 20),
                    _buildDropdown('Select Storage', _storageOptions, (value) {
                      setState(() {
                        _selectedStorage = value;
                      });
                    }, _selectedStorage),
                    const SizedBox(height: 20),
                    _buildDropdown('Select Motherboard', _motherboards, (value) {
                      setState(() {
                        _selectedMotherboard = value;
                      });
                    }, _selectedMotherboard),
                    const SizedBox(height: 20),
                    // Image Picker
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: _buildImage == null
                            ? const Center(
                                child: Text(
                                  'Tap to upload an image',
                                  style: TextStyle(color: Colors.white),
                                ),
                              )
                            : Image.file(
                                _buildImage!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _storeBuild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Complete Build',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, ValueChanged<String?> onChanged, String? selectedItem) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF20232D),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      dropdownColor: const Color(0xFF20232D),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      onChanged: onChanged,
      value: selectedItem,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
    );
  }
}
