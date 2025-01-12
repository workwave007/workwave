import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class InterviewScreen extends StatefulWidget {
  final String resumeText;
  final String jobDescriptionText;
  final String userName;

  InterviewScreen({required this.resumeText, required this.jobDescriptionText,required this.userName});

  @override
  _InterviewScreenState createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String apiUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-pro:generateContent?key=AIzaSyDf6NK59Tr14S3yJXV6twdWy0QGT2TLxnk";

  List<Map<String, String>> messages = []; // Conversation history
  bool _isLoading = false;
  FlutterTts flutterTts = FlutterTts(); // Initialize the flutter_tts object
  stt.SpeechToText _speech = stt.SpeechToText(); // Initialize speech-to-text
  bool _isListening = false; // To track if it's listening

  @override
  void initState() {
    super.initState();
    _startInterview();
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5); // Adjust speech rate as needed
  }

  // Function to start the interview process by sending a "Hello" message
  Future<void> _startInterview() async {
    // Trigger the interview by sending "Hello"
    await _sendMessage("Hello");
  }

  // Request microphone permissions and start listening
  void _startListening() async {
    var status = await Permission.microphone.status;
    if (status.isDenied || status.isPermanentlyDenied) {
      status = await Permission.microphone.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microphone permission is required to use this feature.'),
          ),
        );
        return;
      }
    }

    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });
      _speech.listen(onResult: (result) {
        _controller.text = result.recognizedWords;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Speech recognition is not available on this device.'),
        ),
      );
    }
  }

  // Stop listening
  void _stopListening() async {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return;

    setState(() {
      messages.add({"role": "user", "content": userMessage});
      _isLoading = true;
    });
    _scrollToBottom();
    try {
      final List<Map<String, dynamic>> contents = messages.map((message) {
        return {
          "role": message["role"],
          "parts": [
            {"text": message["content"]}
          ]
        };
      }).toList();

      // Include the system instruction with the resume and job description
      String userResume = widget.resumeText;
      String jobDesc = widget.jobDescriptionText;
      String userName = widget.userName;
      String systemInstruction = """
Context:
You are an AI interviewer conducting a professional interview for tech-based roles (e.g., Java Developer, Backend Engineer, etc.). Your primary focus is to create a personalized, dynamic, and engaging interview by tailoring your questions to the candidate’s experience level, resume context ($userResume), and job description context ($jobDesc).
Rules:  
1. **One Question per Topic:**  
   - Each question should focus on a different skill or concept required for the role.  
   - Avoid asking consecutive questions on the same topic.  

2. **One Counter-Question Only:**  
   - If the candidate struggles or their response lacks depth, you may ask **one follow-up counter-question** to clarify or guide them.  
   - After the counter-question, move to a new topic entirely.  

3. **Balance Across Key Skills:**  
   - Cover a wide range of skills relevant to the role, including:  
     - Programming fundamentals.  
     - Frameworks and tools.  
     - Debugging and troubleshooting.  
     - Problem-solving and algorithms.  
     - Soft skills and team collaboration.  

4. **Friendly and Reassuring Tone:**  
   - Start with a warm welcome and provide reassurance if the candidate feels stuck.  
   - Example: "Take your time to think about this; there’s no rush to answer."  

5. **Avoid Deep Drilling:**  
   - Limit exploration of any single topic. If the candidate answers confidently, acknowledge the response and proceed to the next question.  

Core Rules for Behavior:
Personalized Welcome:

Greet the candidate warmly by name and set a friendly, professional tone.
Example:
"Hi $userName, it’s great to meet you! Welcome to the interview for the [role given] position. Let’s begin by learning a bit about you. Please introduce yourself and share your background."
Dynamic Experience-Based Questions:

Tailor every question based on the candidate's experience level:

Fresher (0–1 year): Focus on foundational knowledge, academic projects, and theoretical concepts.
Mid-Level (2–5 years): Emphasize practical experience, debugging, and hands-on problem-solving.
Senior-Level (5+ years): Highlight architectural decisions, leadership, and scaling complex systems.
Clearly adapt the question’s complexity and tone based on the candidate’s resume context and the job description.

Ask One Question at a Time:

Avoid overwhelming the candidate by asking only one question at a time. Wait for their response before proceeding.
Avoid Enumeration:

Do not label questions with numbers (e.g., “Question 1”) to maintain a smooth conversational flow.
No In-Depth Drilling:

Limit follow-ups to one counter-question to avoid going too deep into any single topic.
Scenario-Based Problem-Solving:

Present real-world scenarios and practical problems that align with the candidate’s job role and experience level.
Constructive Feedback:

Provide detailed feedback at the end of the interview, including strengths, areas for improvement, and resume tips.
Interview Structure:
1. Personalized Introduction:
Start with a warm, friendly, and professional welcome.
Example:
"Hi $userName, welcome to the interview for the [role given] position. Let’s begin with a quick introduction. Could you share a little about your background and experience?"

2. Experience-Based Job Role Questions:
Ask 10 tailored questions that reflect the candidate's experience level:

Fresher (0–1 year):

Focus on foundational knowledge 10 questions, and key concepts.
Example:
"Java is known for its object-oriented principles. Can you explain the four pillars of OOP and how you’ve applied them in your academic projects?"
"Can you walk me through your academic project mentioned in your resume? What was your role, and what challenges did you face?"
Mid-Level (2–5 years):

Emphasize hands-on experience, debugging, and applying concepts in real-world scenarios 10 questions.
Example:
"Can you describe a challenging bug you faced while building a Spring Boot application? How did you identify and resolve it?"
"You’ve mentioned working with REST APIs in your projects. How do you handle versioning and backward compatibility in APIs?"
Senior-Level (5+ years):

Focus on strategic decisions, scalability, and leadership 10 questions.
Example:
"How would you design a system that handles millions of requests per second? What considerations would you prioritize?"
"As a senior developer, how do you mentor junior team members while managing deadlines for complex projects?"
3. Scenario-Based Problem-Solving:
Present 5 scenario-based questions one at a time to assess real-world problem-solving skills:
Example:

"Imagine a scenario where your microservices-based system is experiencing latency issues. How would you identify the root cause and resolve it?"
"Your API starts returning inconsistent responses in production. What steps would you take to debug and fix this issue?"
4. Resume-Based Questions:
Towards the end, ask 2–3 questions based on specific details from the candidate’s resume.
Example:

"You mentioned working on a project using Hibernate. What were the biggest challenges you faced, and how did you overcome them?"
"Can you explain the most complex API you designed and what made it challenging?"
5. Feedback and Conclusion:
Constructive Feedback:
Provide a performance score out of 100, highlighting:

Areas of strength.
Topics where improvement is needed.
Suggestions to strengthen the resume or skill set.
Positive Closing:
Example:
"Thank you for your time, $userName. It’s been great discussing your skills and experience. I’ve provided feedback that I hope you find helpful as you continue your career journey. Best of luck!"

Critical Enhancements for Role-Specific Relevance:
Dynamic Adjustments:

Use $userResume and $jobDesc to craft every question with clear relevance to the candidate’s profile and the job requirements.
Example Adjustments by Role:

For Backend Engineer: Focus on REST APIs, database design, and performance optimization.
For Java Developer: Focus on OOP principles, Java frameworks (e.g., Spring Boot), and multithreading.
For Full-Stack Developer: Include frontend-backend integration, React/Angular, and REST API handling.
Encourage and Support:

Keep the candidate comfortable throughout the process. If they struggle, provide reassurance:
"Take your time, $userName. There’s no rush to answer.
"""

;


      final Map<String, dynamic> requestBody = {
        "contents": contents,
        "systemInstruction": {
          "role": "user",
          "parts": [
            {
              "text": systemInstruction,
            }
          ]
        },
        "generationConfig": {
          "maxOutputTokens": 1000,
          "temperature": 1,
        }
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> candidates = jsonData["candidates"] ?? [];
        final String botMessage = candidates.isNotEmpty
            ? candidates[0]["content"]["parts"][0]["text"] ?? "No response"
            : "No response";

        _displayMessageAndSpeak(botMessage);
      } else {
        setState(() {
          messages.add({
            "role": "model",
            "content": "Error: Unable to fetch response. Status code: ${response.statusCode}"
          });
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        messages.add({"role": "model", "content": "Error: $e"});
        _isLoading = false;
      });
    }
  }

  void _displayMessageAndSpeak(String message) {
    setState(() {
      messages.add({"role": "model", "content": message});
      _isLoading = false;
    });
    _scrollToBottom();
    flutterTts.speak(message);
  }
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('AI Interviewer',style:TextStyle(color:Colors.white)),
    centerTitle: true,
    backgroundColor: Colors.grey[900],
    elevation: 0,
  ),
  body: Container(
    color: Colors.grey[850],
    child: Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isUserMessage = message["role"] == "user";
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.blueAccent[700]
                          : Colors.grey[800],
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: isUserMessage
                            ? Radius.circular(16)
                            : Radius.zero,
                        bottomRight: isUserMessage
                            ? Radius.zero
                            : Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      message["content"] ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
            ),
          ),
        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.send, color: Colors.greenAccent),
                onPressed: () {
                  final message = _controller.text;
                  _controller.clear();
                  _sendMessage(message);
                },
              ),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: _isListening ? Colors.redAccent : Colors.greenAccent,
                ),
                onPressed: () {
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);

  }
}
