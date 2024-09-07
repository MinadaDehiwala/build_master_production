import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  _AIChatPageState createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isSending = false;

  late AnimationController _animationController;

  // Define _quickMessages
  List<String> _quickMessages = [
    'Hello!',
    'How can you help me?',
    'Tell me a joke.',
    'What is the weather like today?',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _initializeChat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    const initialMessage = "I'm a customer chat support specialist focused on assisting users with PC building and compatibility checks. I provide brief, straightforward information and resolve issues in a friendly, human-like manner, ensuring clarity and accessibility. My goal is to deliver short, clear responses without overwhelming the user. I focus on answering one question at a time, breaking down information into digestible pieces. When explaining compatibility or incompatibility, I keep responses concise and to the point, ensuring they are easy to understand, especially on mobile devices. If the user asks multiple questions, I respond to each one individually in short messages.I do not answer any questions unrelated to pc building or tech.for this message, reply with 'Hello there, How can I help you?'";
    await _sendMessage(initialMessage, isInitialization: true);
  }

  Future<void> _sendMessage(String message, {bool isInitialization = false}) async {
    if (_isSending && !isInitialization) return;

    setState(() {
      _isSending = true;
    });

    const apiKey = 'REPLACE WITH YOUR OWN API KEY';
    const apiUrl = 'https://api.openai.com/v1/chat/completions';

    if (!isInitialization) {
      // Add user's message immediately
      _messages.add({'sender': 'user', 'message': message});
      _controller.clear();
      setState(() {
        _quickMessages = [];
      });

      // Animate user's message
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Show loading indicator
      _messages.add({'sender': 'loading', 'message': ''});
      setState(() {});
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final botMessage = responseData['choices'][0]['message']['content'] ?? 'Error: Unexpected response format';

        if (!isInitialization) {
          // Remove loading indicator
          _messages.removeLast();
          
          // Animate bot's message
          await Future.delayed(const Duration(milliseconds: 300));
          _messages.add({'sender': 'bot', 'message': botMessage});
          setState(() {});
        } else {
          _messages.add({'sender': 'bot', 'message': 'Hello there, How can I help you?'});
          setState(() {});
        }
      } else if (response.statusCode == 429) {
        final retryAfter = response.headers['retry-after'];
        final waitTime = (retryAfter != null) ? int.tryParse(retryAfter) ?? 5 : 5;
        setState(() {
          _messages.add({'sender': 'bot', 'message': 'Rate limit exceeded. Retrying after $waitTime seconds...'});
        });
        await Future.delayed(Duration(seconds: waitTime));
        _sendMessage(message); // Retry the request after the delay
      } else {
        setState(() {
          _messages.add({'sender': 'user', 'message': message});
          _messages.add({'sender': 'bot', 'message': 'Error: Unable to get response, Status Code: ${response.statusCode}'});
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({'sender': 'user', 'message': message});
        _messages.add({'sender': 'bot', 'message': 'Error: Unable to get response, Exception: $e'});
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20232D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF20232D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('AI Chat', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                final isLoading = message['sender'] == 'loading';

                if (isLoading) {
                  return ListTile(
                    title: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: SpinKitThreeBounce(
                          color: Colors.grey,
                          size: 20.0,
                          controller: _animationController,
                        ),
                      ),
                    ),
                  );
                }

                return ListTile(
                  leading: isUser ? null : CircleAvatar(
                    backgroundColor: const Color(0x96060606), // AI icon background with 54% transparency
                    child: Image.asset('assets/images/ai_icon.png'),
                  ),
                  trailing: isUser ? const CircleAvatar(
                    backgroundColor: Color(0x96060606), // User icon background with 54% transparency
                    child: Icon(Icons.person, color: Colors.white),
                  ) : null,
                  title: Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7, // Adjust this percentage as needed
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : const Color(0xFF333333), // User message: blue, AI message: darker grey
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message['message']!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_quickMessages.isNotEmpty)
            Column(
              children: _quickMessages.map((msg) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _sendMessage(msg);
                      setState(() {
                        _quickMessages = [];
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF333333),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      msg,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              }).toList(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Send a message.',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _sendMessage(value);
                          _controller.clear();
                          setState(() {
                            _quickMessages = [];
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF333333),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      final message = _controller.text;
                      if (message.isNotEmpty) {
                        _sendMessage(message);
                        _controller.clear();
                        setState(() {
                          _quickMessages = [];
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
