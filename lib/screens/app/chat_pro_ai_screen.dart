import 'dart:async';
import 'package:LinguifyAI/api/api_models/chat_response_model.dart';
import 'package:LinguifyAI/api/chat_api_controller.dart';
import 'package:LinguifyAI/bloc/chat_bloc.dart';
import 'package:LinguifyAI/bloc/chat_events.dart';
import 'package:LinguifyAI/bloc/chat_states.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:LinguifyAI/screens/app/no_object_detected.dart';
import 'package:LinguifyAI/screens/app/no_result_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io' show File, Platform;
import 'dart:convert';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, rootBundle;
import 'package:http/http.dart' as http;
// import 'package:flutter_sound/flutter_sound.dart'; // For recording audio

class ChatProAiScreen extends StatefulWidget {
  const ChatProAiScreen({super.key});

  @override
  State<ChatProAiScreen> createState() => _ChatProAiScreenState();
}

class _ChatProAiScreenState extends State<ChatProAiScreen> {
  final List<Map<String, dynamic>> _messages = [];

  late TextEditingController _inputController;
  String _fromLanguage = SharedPrefController.instance.getFromLanguage();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;
  SpeechToText _speechToText = SpeechToText();
  bool _isSpeechAvailable = false;
  double progressValue = 0.0; // Value for progress (elapsed time)
  int totalDuration = 59; // Duration of speech in seconds
  Timer? _timer; // Timer for progress bar
  bool _isRecording = false;
  // File? _image;
  String? _comment;
  final ImagePicker _picker = ImagePicker();

  final ImagePicker _imagePickerDetector = ImagePicker();
  XFile? _imageFile;
  late ObjectDetector _objectDetector;
  // bool _isImageDetected = false;
  String? _description;
  final ChatApiController _chatApiController = ChatApiController();
  late Future<ChatResponse>? _futureResponse;
  bool _isRequestInProgress = false; // Manage request progress
  bool _isTyping = false;
  bool _iconsExpanded = false;
  bool _isChatActive = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inputController = TextEditingController();
    _initializeSpeech();
    _initializeObjectDetector();
    BlocProvider.of<ChatBloc>(context).add(LoadMessagesEvent());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _inputController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _sendMessage(String inputText) async {
    if (_isRequestInProgress) return;

    // Add the user's message immediately
    setState(() {
      _isRequestInProgress = true;
    });

    BlocProvider.of<ChatBloc>(context).add(SendMessageEvent(message: inputText, isUser: true));
    setState(() {
      _isRequestInProgress = false;
    });
  }

  void _initializeObjectDetector() {
    _objectDetector = ObjectDetector(
      options: ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true,
      ),
    );
  }

  void _showObjectImageSourceSelection() {

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromSource(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _getImageFromSource(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                onTap: (){
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  Future<void> _getImageFromSource(ImageSource source) async {
    final pickedFile = await _imagePickerDetector.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
      _detectObject(pickedFile);
    }
  }

  Future<void> _detectObject(XFile imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final objects = await _objectDetector.processImage(inputImage);

    if (objects.isNotEmpty) {
      final object = objects.first;

      if (object.labels.isNotEmpty) {
        setState(() {
          _inputController.text += object.labels.first.text;
        });
      } else {
        _navigateToNoObjectDetectedPage();
      }

    } else {
      _navigateToNoObjectDetectedPage();
    }
  }

  void _navigateToNoObjectDetectedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoObjectDetected(),
      ),
    );
  }

  Future<void> _initializeSpeech() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speechToText.initialize(
          onStatus: _onSpeechStatus, onError: _onSpeechError);
      if (available) {
        setState(() {
          _isSpeechAvailable = true;
        });
      } else {
        // Handle case where speech recognition is not available
        print("Speech recognition not available");
      }
    } else {
      print('Microphone permission denied');
    }
  }

  String _getLocaleFromLanguage(String language) {
    switch (language) {
      case 'English':
        return 'en-US';
      case 'Arabic':
        return 'ar-SA';
      case 'Spanish':
        return 'es-ES';
      case 'Chinese':
        return 'zh-CN'; // Simplified Chinese (China)
      case 'French':
        return 'fr-FR';
      case 'German':
        return 'de-DE';
      case 'Hindi':
        return 'hi-IN';
      case 'Portuguese':
        return 'pt-PT'; // Portugal Portuguese
      case 'Russian':
        return 'ru-RU';
      default:
        return 'en-US'; // Default to English if no match
    }
  }

  // Start listening to speech
  Future<void> _startListening() async {
    if (_isSpeechAvailable && !_isListening) {
      playStartSound();
      await _speechToText.listen(
        listenFor: Duration(seconds: 59),
        onResult: _onSpeechResult,
        localeId: _getLocaleFromLanguage(
            _fromLanguage), // Set language for recognition
      );
      setState(() {
        _isListening = true;
        _isRecording = true;
        startTimer();
      });
    }
  }

  // Process the result of speech recognition
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      setState(() {
        _inputController.text = result.recognizedWords; // Update the input text
      });
      stopTimer();
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      playStopSound();
      await _speechToText.stop();
      setState(() {
        _isListening = false;
        _isRecording = false;
        stopTimer();
      });
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    print('Speech recognition error: ${error.errorMsg}');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition error: ${error.errorMsg}')));
    setState(() {
      _isListening = false;
      stopTimer();
    });
  }

  void _onSpeechStatus(String status) {
    print('Speech recognition status: $status');
    setState(() {
      _isListening = status == "listening";
    });
  }

  Future<void> _toggleRecording() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  //playing the sound when starting speech recognition
  void playStartSound() {
    if (Platform.isIOS) {
      // Play the iOS-specific start sound
      final player = AudioPlayer();
      player.play(AssetSource('assets/sounds/speech_to_text_listening.m4r'));
    }
    // No need to play sound on Android since it already has system sounds
  }

  void playStopSound() {
    if (Platform.isIOS) {
      final player = AudioPlayer();
      player.play(AssetSource('assets/sounds/speech_to_text_stop.m4r'));
    }
  }

  void startTimer() {
    setState(() {
      progressValue = 0.0;
      _isRecording = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        progressValue += 1 / totalDuration;
      });

      if (progressValue >= 1.0) {
        _timer?.cancel();
        _isRecording = false;
        _stopListening();
      }
    });
  }

  // Stop the timer and reset the progress bar
  void stopTimer() {
    _timer?.cancel();
    setState(() {
      progressValue = 0.0;
      _isRecording = false;
      _isListening = false;
    });
  }

  Future<void> _pickImageAndRecognizeText(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);

    if (image != null) {
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();

      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      // Set the recognized text to the first TextFormField
      if (recognizedText.text.isNotEmpty) {
        setState(() {
          _inputController.text += recognizedText.text;
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const NoResultScreen(), // Navigate to "No Result Found" page
          ),
        );
      }

      textRecognizer.close();
    }
  }

  void _showScannedImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndRecognizeText(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageAndRecognizeText(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancel'),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
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
      body:
          Padding(
        padding:
            const EdgeInsets.only(top: 15, right: 20, left: 20, bottom: 10),
        child: Column(children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 40, right: 20, left: 70, bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 35.w,
                  height: 35.h,
                  child: Image.asset(
                    // 'images/icons/dictionary.png',
                    'images/icons/magic.png',
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 15.w,
                ),
                Text(
                  'ChatPro AI',
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF31363F),
                  ),
                ),
                SizedBox(width: 30.w,),
                PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Color(0xFF686D76)),
                      offset: Offset(0, 40),
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem<String>(
                          value: 'Delete Chat History',
                            padding: EdgeInsets.all(7),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Image.asset(
                                    'images/icons/remove.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Padding(
                                  padding: const EdgeInsets.only(right: 0),
                                    child: Text('Delete Chat History')),
                              ],
                            ),
                        )
                      ],
                    onSelected: (String value) {
                      if(value == 'Delete Chat History') {
                        BlocProvider.of<ChatBloc>(context).add(DeleteChatHistoryEvent());
                      }
                    },
                  ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                  builder: (context, state){
                    if(state is ChatLoaded && _isChatActive){
                    final messages = state.messages;
                    return ListView.builder(
                      reverse: true,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        itemCount: messages.length,
                        itemBuilder: (context, index){
                          final message = messages[messages.length -1 - index];
                          return ChatBubble(
                              clipper: ChatBubbleClipper5(
                                type: message.isUser ? BubbleType.sendBubble : BubbleType.receiverBubble
                              ),
                            alignment: message.isUser ? Alignment.topRight : Alignment.topLeft,
                            backGroundColor: message.isUser ? Color(0xFF69779B) : Color(0xFF9692AF),
                            margin: EdgeInsets.only(top: 15.h),
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(top: 35.h, bottom: 10.h, left: 10.w, right: 10.w),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                                    minWidth: MediaQuery.of(context).size.width * 0.4,
                                  ),
                                  child: Text(
                                    message.message,
                                    style: GoogleFonts.roboto(
                                      color: Colors.black,
                                      fontSize: 16.sp,
                                  ),
                                ),
                                ),
                                Positioned(
                                    child: IconButton(
                                       icon: Icon(
                                        Icons.copy,
                                        size: 24,
                                         color: message.isUser ? Color(0xFF5F6769) : Color(0xFF686D76),
                                        ),
                                      onPressed: (){
                                        Clipboard.setData(ClipboardData(text: message.message));
                                      },
                                ),
                                ),
                              ],
                            ),
                              );
                        }
                    );
                    } else {
                      return Center(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 250.w,
                                        height: 250.h,
                                        child: Image.asset(
                                          'images/icons/bot_3.png',
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      SizedBox(height: 40.h),
                                      Text(
                                        'Talk, type, scan! Ask the AI anything—practice English, solve tricky questions, or grab text from a photo. Your smart conversation starts here!',
                                        style: GoogleFonts.roboto(
                                          fontSize: 18,
                                          // color: const Color(0xFF686D76),
                                          // color: const Color(0xFF50545A),
                                          color: const Color(0xFF31363F),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                    }
                  })
          ),

          SizedBox(
            height: 1.h,
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Row(
              children: [
                // Conditionally render the icons or the "plus" icon
                // _isTyping || !_iconsExpanded
                !_iconsExpanded
                    ?
                        IconButton(
                          onPressed: () {
                            setState(() {
                          _iconsExpanded = true; // Toggle the icons
                             });
                           }, icon: Icon(
                          Icons.add, // Plus icon
                          color: Color(0xFF686D76),
                          size: 24,
                          ),
                        )
                    :
                Row(children: [
                  IconButton(
                    onPressed: () => _showScannedImageSourceSelection(),
                    icon: Icon(
                      Icons.document_scanner_outlined,
                      color: Color(0xFF686D76),
                      size: 24,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showObjectImageSourceSelection(),
                    icon: Icon(
                      Icons.camera_alt,
                      color: Color(0xFF686D76),
                      size: 24,
                    ),
                  ),
                ],),
                IconButton(
                    onPressed: () => _toggleRecording(),
                    icon: Icon(
                      Icons.mic,
                      size: 24, // Adjust icon size
                      color:
                      _isListening ? Color(0xFFEF5A6F) : Color(0xFF686D76),
                    )),
                Expanded(
                  child: Container(
                    child: TextFormField(
                      controller: _inputController,
                      textInputAction: TextInputAction.search,
                      minLines: 1,
                      maxLines: 6,
                      cursorColor: Color(0xff2D2B4E),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Color(0xFF686D76),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5.h, // Adjust the vertical padding (top/bottom)
                          horizontal: 5.w
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey.shade800,
                            width: 1.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Color(0xff2D2B4E),
                            width: 1.w,
                          ),
                        ),
                        focusColor: Color(0xff2D2B4E),
                        hintStyle: GoogleFonts.poppins(
                          // color: const Color(0xFF686D76),
                          color: const Color(0xFF50545A),
                        ),
                        constraints: BoxConstraints(maxHeight: 110.h),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          _isTyping = true;
                          // _isTyping = value.isNotEmpty;
                          _iconsExpanded = false; // Shrink the icons when typing
                        });
                      },
                      onTap: () {
                        setState(() {
                          _isChatActive = true;
                          _isTyping = true;
                          // _iconsExpanded = false; // Shrink icons when field is tapped
                        });
                        BlocProvider.of<ChatBloc>(context).add(LoadMessagesEvent());
                      },
                      onFieldSubmitted: (value){
                        _isTyping = false;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 5.w),
                IconButton(
                  onPressed: (){
                    if(!_isRequestInProgress && _inputController.text != ''){
                      _sendMessage(_inputController.text);
                      _inputController.clear();
                    }
                    },
                  icon: Icon(Icons.send),
                  color: !_isRequestInProgress ? Color(0xFF116D6E) : Color(0xFF686D76),
                )
              ],
            ),
          ),
        ]
            ),
      ),
    );
  }
}
