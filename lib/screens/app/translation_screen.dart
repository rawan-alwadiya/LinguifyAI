import 'dart:async';
import 'package:LinguifyAI/cubit/language_cubit.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:LinguifyAI/screens/app/no_result_screen.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dictionaryx/dictionary_msa_json_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:io' show Platform;
import 'dart:async';  // For Timer usage


class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String? _translatedText = '';
  Timer? _debounce;
  String _fromLanguage = SharedPrefController.instance.getFromLanguage();
  String _toLanguage = SharedPrefController.instance.getToLanguage();
  late TextEditingController _inputController;
  late TextEditingController _outputController;
  final FlutterTts _flutterTts = FlutterTts();
  bool isInputPlaying = false;
  bool isOutputPlaying = false;
  final _picker = ImagePicker();
  late OnDeviceTranslator _translator;
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isSpeechAvailable = false;
  double progressValue = 0.0;  // Value for progress (elapsed time)
  int totalDuration = 59;  // Duration of speech in seconds
  Timer? _timer;  // Timer for progress bar
  bool _isRecording = false;

  final List<Map<String, String>> languages = [
    {'name': 'English', 'flag': 'images/flags/usa.png'},
    {'name': 'Arabic', 'flag': 'images/flags/arabic.png'},
    {'name': 'Spanish', 'flag': 'images/flags/spanish.png'},
    {'name': 'Chinese', 'flag': 'images/flags/china.png'},
    {'name': 'French', 'flag': 'images/flags/french.png'},
    {'name': 'German', 'flag': 'images/flags/german.png'},
    {'name': 'Hindi', 'flag': 'images/flags/hindi.png'},
    {'name': 'Portuguese', 'flag': 'images/flags/portuguese.png'},
    {'name': 'Russian', 'flag': 'images/flags/russian.png'},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _inputController = TextEditingController();
    _outputController = TextEditingController();
    context.read<LanguageCubit>().getSavedLanguage(); // Get saved languages
    _inputController.addListener(() {
      _onTextChanged();
    });
    _initializeTranslator();
    _initializeSpeech();
    _flutterTts.setCompletionHandler(() {
      setState(() {
        isInputPlaying = false;
        isOutputPlaying = false; // Reset to false when speech ends
      });
    });
  }

  void _initializeTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: _getTranslateLanguage(_fromLanguage),
      targetLanguage: _getTranslateLanguage(_toLanguage),
    );
    _downloadModels();
  }

  Future<void> _downloadModels() async {
    final modelManager = OnDeviceTranslatorModelManager();
    final sourceLang = _getTranslateLanguage(_fromLanguage).bcpCode;
    final targetLang = _getTranslateLanguage(_toLanguage).bcpCode;

    if (!(await modelManager.isModelDownloaded(sourceLang))) {
      await modelManager.downloadModel(sourceLang);
    }
    if (!(await modelManager.isModelDownloaded(targetLang))) {
      await modelManager.downloadModel(targetLang);
    }
  }


  void _onTextChanged() {
    final inputText = _inputController.text.trim();
    _translateWithGoogleMLKit(inputText);
  }


  // Translate longer text using google_mlkit_translation
  Future<void> _translateWithGoogleMLKit(String text) async {

    try {

      final translatedText = await _translator.translateText(text);

      setState(() {
        _translatedText = translatedText;
        _outputController.text = _translatedText!;
      });

      // _translator.close();
    } catch (error) {
      print('Google ML Kit Translation error: $error');
    }
  }

  // Utility function to convert string language to TranslateLanguage enum
  TranslateLanguage _getTranslateLanguage(String language) {
    switch (language) {
      case 'English':
        return TranslateLanguage.english;
      case 'Arabic':
        return TranslateLanguage.arabic;
      case 'Spanish':
        return TranslateLanguage.spanish;
      case 'Chinese':
        return TranslateLanguage.chinese;
      case 'French':
        return TranslateLanguage.french;
      case 'German':
        return TranslateLanguage.german;
      case 'Hindi':
        return TranslateLanguage.hindi;
      case 'Portuguese':
        return TranslateLanguage.portuguese;
      case 'Russian':
        return TranslateLanguage.russian;
      default:
        return TranslateLanguage.english; // Default to English if no match
    }
  }

  Future<void> _speak(String text, String language, bool isInput) async {
    String languageCode;

    switch (language) {
      case 'English':
        languageCode = 'en-US'; // or 'en-GB' for UK English
        break;
      case 'Arabic':
        languageCode = 'ar';
        break;
      case 'Spanish':
        languageCode = 'es-ES'; // or 'es-US' for US Spanish
        break;
      case 'Chinese':
        languageCode = 'zh-CN'; // Simplified Chinese (Mandarin)
        break;
      case 'French':
        languageCode = 'fr-FR';
        break;
      case 'German':
        languageCode = 'de-DE';
        break;
      case 'Hindi':
        languageCode = 'hi-IN';
        break;
      case 'Portuguese':
        languageCode = 'pt-PT'; // or 'pt-BR' for Brazilian Portuguese
        break;
      case 'Russian':
        languageCode = 'ru-RU';
        break;
      default:
        languageCode = 'en-US'; // fallback to English
    }

    await _flutterTts.setLanguage(languageCode);
    setState(() {
      if (isInput) {
        // Cancel recording if the user is trying to listen to text while recording
        if (_isRecording) {
          _stopListening();
          _isRecording = false; // Ensure recording is canceled
        }
        isInputPlaying = true;
        isOutputPlaying = false;  // Stop output if input is playing
      } else {
        isInputPlaying = false;  // Stop input if output is playing
        isOutputPlaying = true;
      }
    });
    await _flutterTts.speak(text);
  }

  // Function to pause the speech
  Future<void> _pause() async {
    await _flutterTts.pause();
    setState(() {
      isInputPlaying = false;
      isOutputPlaying = false;
    });
  }

  // Function to stop the speech
  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      isInputPlaying = false;
      isOutputPlaying = false;
    });
  }

  Future<void> _initializeSpeech() async {
    var status = await Permission.microphone.request();
    if(status.isGranted){
      bool available = await _speechToText.initialize(
          onStatus: _onSpeechStatus,
          onError: _onSpeechError
      );
      if(available){
      setState(() {
        _isSpeechAvailable = true;
      });
      } else{
        print("Speech recognition not available");
      }
      } else {
        print('Microphone permission denied');
      }
  }

  // Helper to get the locale for the selected language
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
        listenFor: const Duration(seconds: 59),
        onResult: _onSpeechResult,
        localeId: _getLocaleFromLanguage(_fromLanguage), // Set language for recognition
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
        // Trigger the translation function after speech recognition
        _translateWithGoogleMLKit(result.recognizedWords);
      });
      // Reset progress bar after speech recognition finishes
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

  // Handle speech recognition errors, such as timeouts
  void _onSpeechError(SpeechRecognitionError error) {
    print('Speech recognition error: ${error.errorMsg}');
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition error: ${error.errorMsg}'))
    );
    setState(() {
      _isListening = false;
      stopTimer();
    });
  }

  // Track the current status of speech recognition
  void _onSpeechStatus(String status) {
    print('Speech recognition status: $status');
    setState(() {
      _isListening = status == "listening";
    });
  }

  // Toggle recording when the mic button is tapped
  Future<void> _toggleRecording() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  // Sound feedback when starting speech recognition (for iOS)
  void playStartSound() {
    if (Platform.isIOS) {
      // Play the iOS-specific start sound
      final player = AudioPlayer();
      player.play(AssetSource('assets/sounds/speech_to_text_listening.m4r'));
    }
    // No need to play sound on Android since it already has system sounds
  }

  // Sound feedback when stopping speech recognition (for iOS)
  void playStopSound() {
    if (Platform.isIOS) {
      final player = AudioPlayer();
      player.play(AssetSource('assets/sounds/speech_to_text_stop.m4r'));
    }
  }

  // Start the progress timer
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

  // Handle Send button press (submit speech-to-text)
  void _onSendPressed() {
    if (_isRecording) {
      _stopListening(); // Stop listening and stop timer
      _translatedText = _inputController.text; // Store the recognized text
      // Perform any additional actions with the recognized text
    }
  }

// Handle Cancel button press (stop listening without submitting)
  void _onCancelPressed() {
    _stopListening(); // Stop listening and stop timer
    _inputController.clear(); // Clear any recognized text
  }

  // Remaining time logic
  String _getRemainingTime() {
    int remainingSeconds = totalDuration - (totalDuration * progressValue).round();
    return "${remainingSeconds}s";
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
              _inputController.text = recognizedText.text;
              _translateWithGoogleMLKit(recognizedText.text);
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

  void _showImageSourceSelection() {
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
  void dispose() {
    // TODO: implement dispose
    _inputController.removeListener(_onTextChanged);
    _inputController.dispose();
    _outputController.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    _debounce?.cancel();
    _translator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          alignment: AlignmentDirectional.center,
          child:
          Padding(
            padding: const EdgeInsets.only(
                top: 20, right: 25, left: 25, bottom: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 30, right: 25, left: 25, bottom: 5),
                    // child:
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 35.w,
                          height: 35.h,
                          child: Image.asset(
                            // 'images/icons/dictionary.png',
                            // 'images/icons/magic-book.png',
                            'images/icons/magic.png',
                            // 'images/icons/book7.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 15.w,),
                        Text('Translation Hub', style: GoogleFonts.roboto(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF31363F),
                      ),),
                      ]
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      // From Language Dropdown
                      Expanded(
                        child: _buildDropdownButton(
                          _fromLanguage,
                              (newValue) {
                            if (newValue != null) {
                              setState(() {
                                context.read<LanguageCubit>().changeFromLanguage(newValue);
                                _initializeTranslator(); // Reinitialize translator with new language
                              });
                            }
                          },
                          'From',
                        ),
                      ),
                      SizedBox(width: 25.w),
                      const Icon(Icons.arrow_right_alt, size: 24,
                          color: Color(0xFF31363F)), // Spacer between dropdowns
                      SizedBox(width: 25.w), // Spacer between dropdowns
                      // To Language Dropdown
                      Expanded(
                        child: _buildDropdownButton(
                          _toLanguage,
                              (newValue) {
                            if (newValue != null) {
                              setState(() {
                                context.read<LanguageCubit>().changeToLanguage(newValue);
                                _initializeTranslator(); // Reinitialize translator with new language
                              });
                            }
                          },
                          'To',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h,),
                  Container(
                    child: TextFormField(
                      controller: _inputController,
                      textInputAction: TextInputAction.search,
                      minLines: 6,
                      maxLines: 6,
                      cursorColor: Color(0xff2D2B4E),
                      decoration: InputDecoration(
                        hintText: 'Enter or paste your text for instant translation magic!',
                        // ),
                        prefixIcon: Icon(Icons.search,
                          color: Color(0xFF686D76),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 5.h,  // Adjust the vertical padding (top/bottom)
                          horizontal: 5.w, // Adjust the horizontal padding (left/right)
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey.shade800,
                            // color: Color(0xFF67729D),
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
                        // focusColor: Color(0xFF40A798),
                        focusColor: Color(0xff2D2B4E),
                        hintStyle: GoogleFonts.poppins(
                          // color: const Color(0xFF686D76),
                          color: const Color(0xFF50545A),
                        ),
                        constraints: BoxConstraints(
                            maxHeight: 110.h
                        ),
                      ),
                      onChanged: (String value) {
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Align(
                      alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if(isInputPlaying){
                              _stop().then((_){
                                _speak(_inputController.text, _fromLanguage, true);
                                _pause();
                              });
                            } else {
                              _speak(_inputController.text, _fromLanguage, true);
                            }
                          },
                          icon: Icon(
                            Icons.volume_down_outlined,
                            size: 30,
                            color: isInputPlaying? const Color(0xFFEF5A6F): const Color(0xFF686D76),
                            // color: isInputPlaying? const Color(0xFF537188): const Color(0xFF686D76),
                          ),),
                        // SizedBox(width: 1.w,),
                        IconButton(
                          onPressed: (){
                            if(isInputPlaying){
                              _pause();
                            }
                          },
                          icon: const Icon(
                            Icons.pause,
                            size: 28,
                            // color: Color(0xFF686D76),
                            color: Color(0xFF686D76),
                          ),),
                        // SizedBox(width: 1.w,),
                        IconButton(
                            onPressed: (){
                              if(isInputPlaying){
                                _stop();
                              }
                            },
                            icon: const Icon(
                            Icons.stop_rounded,
                            // size: 28, color: Color(0xFF686D76)
                            size: 28, color: Color(0xFF686D76)
                        ))

                      ]
                    ),
                  ),
                  // SizedBox(height: 2.h),
                  Visibility(
                    visible: _isRecording,
                    replacement: SizedBox(height: 30.h,),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            onPressed: (){
                              _onCancelPressed();
                            },
                            icon: Icon(
                                Icons.cancel,
                              color: Color(0xFFD14D72),
                              size: 24,
                            ),
                        ),
                        Expanded(
                          child: Stack(
                              children: [
                                // Full progress bar (Background for remaining time)
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                      color: Color(0xFF898AA6) // Background color for remaining time
                                  ),
                                ),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Container(
                                      height: 10,
                                      width: constraints.maxWidth * progressValue,  // Dynamically update width
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color(0xFF537188),  // Elapsed time color
                                      ),
                                    );
                                  },
                                ),
                                ],
                          ),),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        _getRemainingTime(),
                                        style: TextStyle(
                                          color: Color(0xFF537188), // Color for remaining time
                                          // color: Color(0xFF3B577D), // Color for remaining time
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ),
                        IconButton(
                            onPressed: (){
                              _onSendPressed();
                            },
                            icon: Icon(
                                Icons.send,
                              color: Color(0xFF537188),
                            ))
                              ],
                          ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          _toggleRecording();
                          },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 38.w, vertical: 12.h), // Adjust padding
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFE7475E),
                                Color(0xFFEB586F),
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                12), // Rounded corners
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mic,
                                size: 24, // Adjust icon size
                                color: _isListening? const Color(0xFF537188): Colors.white, // Icon color
                              ),
                              SizedBox(height: 4.h),
                              // Space between icon and text
                              Text(
                                'Speak',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.white, // Text color
                                ),
                              ),
                              SizedBox(height: 4.h),
                              // Space between "Speak" and hint
                              Text(
                                'Tap to speak',
                                style: TextStyle(
                                  fontSize: 12.sp, // Hint text size
                                  color: Colors.white70, // Hint text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20.w),
                      InkWell(
                        onTap: () => _showImageSourceSelection(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF248888),
                                Color(0xFF1B6E6A)
                              ], // Gradient colors for the second button

                              begin: AlignmentDirectional.topStart,
                              end: AlignmentDirectional.bottomEnd,
                            ),
                            borderRadius: BorderRadius.circular(
                                12), // Rounded corners
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.document_scanner_outlined,
                                size: 24, // Adjust icon size
                                color: Colors.white, // Icon color
                              ),
                              SizedBox(height: 4.h),
                              // Space between icon and text
                              Text(
                                'Scan Image',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.white, // Text color
                                ),
                              ),
                              SizedBox(height: 4.h),
                              // Space between "Speak" and hint
                              Text(
                                'Text Image',
                                style: TextStyle(
                                  fontSize: 12.sp, // Hint text size
                                  color: Colors.white70, // Hint text color
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    child: TextFormField(
                      controller: _outputController,
                      readOnly: true,
                      textInputAction: TextInputAction.search,
                      minLines: 6,
                      maxLines: 6,
                      cursorColor: Color(0xff2D2B4E),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10.h, left: 10.w),
                        hintText: 'Your translated text awaits!',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey.shade800,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Color(0xff2D2B4E),
                            width: 1,
                          ),
                        ),
                        focusColor: Color(0xff2D2B4E),
                        hintStyle: GoogleFonts.poppins(
                            // color: const Color(0xFF686D76),
                            color: const Color(0xFF50545A),
                        ),
                        constraints: BoxConstraints(
                            maxHeight: 110.h
                        ),
                      ),
                      onChanged: (String value) {
                        setState(() {
                          // _translateText;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          IconButton(
                          onPressed: () {
                            if(isOutputPlaying){
                              _stop().then((_){
                            _speak(_outputController.text, _toLanguage, false);
                              });
                            } else {
                              _speak(_outputController.text, _toLanguage, false);
                            }
                            },
                          icon: Icon(
                            Icons.volume_down_outlined,
                            size: 32,
                              color: isOutputPlaying? const Color(0xFFEF5A6F): const Color(0xFF686D76)
                          ),),
                          // SizedBox(width: 1.w,),
                          IconButton(
                            onPressed: (){
                              if(isOutputPlaying){
                                _pause();
                              }
                            },
                            icon: const Icon(
                              Icons.pause,
                              size: 28,
                               color: Color(0xFF686D76)
                            ),),
                          // SizedBox(width: 1.w,),
                          IconButton(
                              onPressed: (){
                                if(isOutputPlaying){
                                  _stop();
                                }
                              },
                              icon: const Icon(
                              Icons.stop_rounded,
                            size: 28, color: Color(0xFF686D76)
                          ))
                        ]
                      ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }

  Widget _buildDropdownButton(String? selectedLanguage,
      Function(String?) onChanged, String hint) {
    return DropdownButton<String>(
      value: selectedLanguage,
      hint: Text(hint),
      icon: const Icon(Icons.arrow_drop_down),
      isExpanded: true,
      items: languages.map<DropdownMenuItem<String>>((language) {
        return DropdownMenuItem<String>(
          value: language['name'],
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  language['flag']!,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Text(language['name']!),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

