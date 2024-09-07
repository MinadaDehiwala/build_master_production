import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class CompatibilityPage extends StatefulWidget {
  const CompatibilityPage({super.key});

  @override
  _CompatibilityPageState createState() => _CompatibilityPageState();
}

class _CompatibilityPageState extends State<CompatibilityPage> {
  String? _selectedCpu;
  String? _selectedGpu;
  String? _selectedRam;
  String? _selectedStorage;
  String? _selectedMotherboard;
  String _response = '';
  bool _isLoading = false;

  List<String> _cpus = [];
  List<String> _gpus = [];
  List<String> _ramSizes = [];
  List<String> _storageOptions = [];
  final List<String> _motherboards = [
    'ASUS ROG Strix Z590-E Gaming',
    'MSI MPG B550',
    'Gigabyte Z490 Elite',
    // Add more motherboard options
  ];

  final String apiKey = 'REPLACE WITH YOUR OWN API KEY'; // Your API key

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
    try {
      final String response = await rootBundle.loadString(path);
      return json.decode(response) as List;
    } catch (e) {
      print("Error loading JSON from $path: $e");
      return [];
    }
  }

  List<String> _extractNames(List<dynamic> data) {
    return data.map<String>((item) {
      if (item.containsKey('Brand') && item.containsKey('Model') && item['Brand'] != null && item['Model'] != null) {
        return '${item['Brand']} ${item['Model']}';
      }
      return 'Unknown';
    }).toList();
  }

  Future<void> checkCompatibility() async {
    setState(() {
      _isLoading = true;
    });

    final String prompt = '''
You are an expert in computer hardware compatibility. I will provide a list of selected computer parts including CPU, GPU, RAM, motherboard, and SSD. Your task is to check if these parts are compatible with each other.

CPU: $_selectedCpu
GPU: $_selectedGpu
RAM: $_selectedRam
Motherboard: $_selectedMotherboard
SSD: $_selectedStorage

Output format:
1. Start with "Compatibility: Compatible" or "Compatibility: Not Compatible".
2. If not compatible, provide reasons underneath in the format: "Reason: [specific reason]".
Keep the response concise, with no extra descriptions or explanations.
''';

    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini', // Using GPT-4o-mini as per the requirement
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _response = data['choices'][0]['message']['content'].trim();
        });
      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _response = 'Error: ${errorData['error']['message']}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Compatibility'),
        backgroundColor: const Color(0xFF20232D),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), // Set the title text to white
        iconTheme: const IconThemeData(color: Colors.white), // Set the back icon color to white
      ),
      backgroundColor: const Color(0xFF20232D),
      body: Stack(
        children: [
          if (_isLoading) ...[
            const Center(
              child: CircularProgressIndicator(),
            )
          ] else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDropdown('Select Processor', _cpus, (value) {
                    setState(() {
                      _selectedCpu = value;
                    });
                  }, _selectedCpu),
                  const SizedBox(height: 20),
                  _buildDropdown('Select Graphics Card', _gpus, (value) {
                    setState(() {
                      _selectedGpu = value;
                    });
                  }, _selectedGpu),
                  const SizedBox(height: 20),
                  _buildDropdown('Select RAM Size', _ramSizes, (value) {
                    setState(() {
                      _selectedRam = value;
                    });
                  }, _selectedRam),
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
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      checkCompatibility();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: const Color(0xFF20232D), // Set button background to dark
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Check Compatibility',
                      style: TextStyle(
                        color: Colors.white, // Set the text color of the button to white
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_response.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _response,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ]
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
        labelStyle: const TextStyle(color: Colors.white), // Set the dropdown label to white
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
          child: Text(value, style: const TextStyle(color: Colors.white)), // Set dropdown items to white
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
