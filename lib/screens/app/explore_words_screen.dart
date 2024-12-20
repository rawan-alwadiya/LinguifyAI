import 'dart:async';
import 'package:LinguifyAI/cubit/language_cubit.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dictionaryx/dictentry.dart';
import 'package:dictionaryx/dictionary_msa_json_flutter.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:word_generator/word_generator.dart';
import 'dart:io' show Platform;

class ExploreWordsScreen extends StatefulWidget {
  const ExploreWordsScreen({super.key});

  @override
  State<ExploreWordsScreen> createState() => _ExploreWordsScreenState();
}

class _ExploreWordsScreenState extends State<ExploreWordsScreen> {
  late TextEditingController _inputController;
  late FlipCardController _flipCardController;
  late OnDeviceTranslator _translator;
  String? _translatedText = '';
  String _fromLanguage = SharedPrefController.instance.getFromLanguage();
  String _toLanguage = SharedPrefController.instance.getToLanguage();
  final FlutterTts _flutterTts = FlutterTts();
  String? displayedWord; //To display either submitted or random word
  String? submittedWord; // To store the submitted word
  WordGenerator wordGenerator = WordGenerator();
  bool isVerb = true;
  final dMSAJson = DictionaryMSAFlutter();
  DictEntry _entry = DictEntry('', [], [], []);
  String? _word_pos;
  String? _word_synonyms;
  String? _word_meaning;
  String? _word_example;
  String? _generatedWord;
  SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _isSpeechAvailable = false;
  bool isFrontTextPlaying = false;
  bool isBackTextPlaying = false;
  bool _isRecording = false;
  Timer? _debounce;
  double progressValue = 0.0;  // Value for progress (elapsed time)
  int totalDuration = 59;  // Duration of speech in seconds
  Timer? _timer;  // Timer for progress bar

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _flipCardController = FlipCardController();
    context.read<LanguageCubit>().getSavedLanguage(); // Get saved languages
    _initializeTranslator();
    generateRandomWord(); // Generate a word initially
    _initializeSpeech();
    _flutterTts.setCompletionHandler(() {
      setState(() {
        isFrontTextPlaying = false;
        isBackTextPlaying = false; // Reset to false when speech ends
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _inputController.dispose();
    _translator.close();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  // Toggle between generating a verb or noun
  void generateRandomWord() {
    setState(() {
      _generatedWord = isVerb ? wordGenerator.randomVerb() : wordGenerator.randomNoun();
      isVerb = !isVerb; // Alternate between verb and noun
      displayedWord = _generatedWord;
      submittedWord = _generatedWord;
      if(_flipCardController.state?.isFront == false){
        _flipCardController.toggleCard(); //flip to the front
      }
      _resetWordInfo(); // Reset details for the new word
      lookupWord();
      if(_generatedWord != null){
      _translateWithGoogleMLKit(_generatedWord!);
      }
    });
  }

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

  void _initializeTranslator() {
    _translator = OnDeviceTranslator(
      sourceLanguage: _getTranslateLanguage('English'),
      targetLanguage: _getTranslateLanguage(_toLanguage),
    );
    _downloadModels();
  }

  Future<void> _downloadModels() async {
    final modelManager = OnDeviceTranslatorModelManager();
    final sourceLang = _getTranslateLanguage('English').bcpCode;
    final targetLang = _getTranslateLanguage(_toLanguage).bcpCode;

    if (!(await modelManager.isModelDownloaded(sourceLang))) {
      await modelManager.downloadModel(sourceLang);
    }
    if (!(await modelManager.isModelDownloaded(targetLang))) {
      await modelManager.downloadModel(targetLang);
    }
  }

  Future<void> _translateWithGoogleMLKit(String text) async {
    try {
      final translatedText = await _translator.translateText(text);

      setState(() {
        _translatedText = translatedText;
      });
    } catch (error) {
      print('Google ML Kit Translation error: $error');
    }
  }


  String? getSubmittedWord() {
    return submittedWord;
  } // Function to return submitted word

  void lookupWord() async {
    DictEntry? tmp;

    if (displayedWord != null) {
      if (await dMSAJson.hasEntry(displayedWord!)) {
        tmp = await dMSAJson.getEntry(displayedWord!);
      }
    }

    setState(() {
      if (tmp != null) {
        _entry = tmp;
        _word_pos = _entry.meanings.first.pos != null
            ? _entry.meanings.first.pos.toString() : 'N/A';
        _word_meaning = _entry.meanings.first.meanings.first.isNotEmpty
            ? _entry.meanings.first.meanings.first
            : 'No meaning available';
        _word_example = _entry.meanings.first.examples.isNotEmpty
            ? _entry.meanings.first.examples.first
            : 'No example available';
        _word_synonyms = _entry.synonyms.isNotEmpty
            ? _entry.synonyms.join(', ')
            : 'No synonyms available';
      } else {
        _resetWordInfo(); // Reset if no entry found
      }
    });
  }

  // Reset word details when no info is found
  void _resetWordInfo() {
    _entry = DictEntry('', [], [], []);
    _word_pos = 'N/A';
    _word_meaning = 'No meaning available';
    _word_example = 'No example available';
    _word_synonyms = 'No synonyms available';
  }

  void _submitWord() {
    setState(() {
      submittedWord = _inputController.text.trim();
      displayedWord = submittedWord;
      if(_flipCardController.state?.isFront == false){
        _flipCardController.toggleCard(); //flip to the front
      }
      _resetWordInfo();
      lookupWord(); // Fetch word info
      if(submittedWord != null){
      _translateWithGoogleMLKit(submittedWord!);
      }
    });
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
        isFrontTextPlaying = true;
        isBackTextPlaying = false;  // Stop output if input is playing
      } else {
        isFrontTextPlaying = false;  // Stop input if output is playing
        isBackTextPlaying = true;
      }
    });
    // await _flutterTts.speak(text);
    await _flutterTts.speak(text).then((_) {
      setState(() {
        if (isInput) {
          isFrontTextPlaying = false;
        } else {
          isBackTextPlaying = false;
        }
      });
    });
  }

  // Method to handle speech for the English details
  Future<void> _speakDetails() async {
    if (!isBackTextPlaying) {
      String combinedDetails = '\n${_word_pos!}\n Meaning: ${_word_meaning!}\n Example: ${_word_example!}\n Synonyms: ${_word_synonyms!}';
      setState(() {
        isBackTextPlaying = true;
      });
      await _speak(combinedDetails, 'English', false);
    }
  }

  // Function to pause the speech
  Future<void> _pause() async {
    await _flutterTts.pause();
    setState(() {
      isFrontTextPlaying = false;
      isBackTextPlaying = false;
    });
  }

  // Function to stop the speech
  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      isFrontTextPlaying = false;
      isBackTextPlaying = false;
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
        SnackBar(content: Text('Speech recognition error: ${error.errorMsg}'))
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
            padding: const EdgeInsets.only(
            top: 15, right: 20, left: 20, bottom: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 40, right: 20, left: 20, bottom: 5),
                  // child:
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
                      SizedBox(width: 15.w,),
                      Text('Explore Words', style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF31363F),
                    ),),
                    ]
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 15, left: 15),
                  child: Text(
                    'Discover new words! Type or get a surprise. Flip for meanings, examples, and more—each flip holds a new discovery!',
                      style: GoogleFonts.roboto(
                        fontSize: 15.sp,
                        // color: const Color(0xFF686D76),
                        // color: const Color(0xFF50545A),
                        // color: const Color(0xFF4F5258),
                        color: const Color(0xFF31363F),
                      ),
                      textAlign: TextAlign.start
                  ),
                ),
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.only(right: 10.w),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => _toggleRecording(),
                          icon: Icon(
                              Icons.mic,
                            size: 24, // Adjust icon size
                            color: _isListening? Color(0xFFEF5A6F): Color(0xFF686D76),
                          )
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _inputController,
                          textInputAction: TextInputAction.search,
                          minLines: 1,
                          maxLines: 1,
                          cursorColor: Color(0xff2D2B4E),
                          decoration: InputDecoration(
                            hintText: 'Enter a word',
                            prefixIcon: Icon(Icons.search,
                              color: Color(0xFF686D76),
                              // color: Color(0xFF50545A),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 5.h,  // Adjust the vertical padding (top/bottom)
                              horizontal: 5.w, // Adjust the horizontal padding (left/right)
                            ),

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none
                            ),
                            focusColor: Color(0xff2D2B4E),
                            hintStyle: GoogleFonts.roboto(
                                // color: Color(0xFF686D76)
                                color: Color(0xFF50545A)
                            ),
                            constraints: BoxConstraints(
                                maxHeight: 50.h
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      InkWell(
                        onTap: (){
                          _submitWord();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFFE7475E),
                              Color(0xFFEB586F),
                            ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('Submit', style: TextStyle(fontSize: 14.sp, color: Colors.white),),
                        ),
                      ),
                  ]
                  ),
                ),
                SizedBox(height: 6.h),
                FlipCard(
                  flipOnTouch: true,
                  controller: _flipCardController,
                  fill: Fill.fillBack,
                    front: Stack(
                      children: [
                        Container(
                        alignment: Alignment.center,
                        width: 303.w, // Set fixed width
                        height: 335.h, // Set fixed height
                          padding: EdgeInsets.symmetric(
                              horizontal: 10,
                          ), // Adjust padding
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                // Color(0xFFC9BBCF),
                                Color(0xFF898AA6),
                                Color(0xFF9A86A4),
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          child: Center(
                            child: Text(
                              displayedWord ?? '', // Display the submitted or generated word
                                style: GoogleFonts.roboto(fontSize: 24.sp,
                                ),
                                textAlign: TextAlign.center,
                              softWrap: true, // Allow text to wrap within the container
                              ),
                          ),
                          ),
                        // Copy icon on the front side
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: IconButton(
                            icon: Icon(Icons.copy, size: 24, color: Color(0xFF686D76),),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: displayedWord ?? ''));
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 20.h,
                          left: 30.w,
                          child:  SizedBox(
                            width: 45.w,
                            height: 45.h,
                            child: InkWell(
                              onTap: () {
                                   _speak(displayedWord!, 'English', true);
                              },
                              child: Image.asset(
                                'images/icons/sound_1.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                      ]
                    ),
                        // Text('Front'),
                    back: Stack(
                      children: [
                        Container(
                        alignment: Alignment.center,
                        width: 303.w, // Set fixed width
                        height: 325.h, // Set fixed height
                          padding: EdgeInsets.symmetric(
                              horizontal: 10,
                          ), // Adjust padding
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF898AA6),
                                Color(0xFF9A86A4),
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                                12), // Rounded corners
                          ),
                          child: Column(
                                mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
                                crossAxisAlignment: CrossAxisAlignment.center, // Center the content horizontally
                                  children: [
                                    Flexible(
                                        child: Text(
                                          _translatedText ?? 'No translation available',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                          ),
                                          softWrap: true,
                                        )),
                                    SizedBox(height: 8.h),
                                    Flexible(
                                      child: Text(
                                        '$_word_pos',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                            fontSize: 16.sp,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    SizedBox(height: 8.h),
                                    Flexible(
                                        child: Text(
                                        'Meaning: $_word_meaning',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                          ),
                                          softWrap: true,
                                        )),
                                    SizedBox(height: 8.h),
                                    Flexible(
                                        child: Text(
                                          'Example: $_word_example',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                          ),
                                          softWrap: true,
                                        )),
                                    SizedBox(height: 8.h),
                                    Flexible(
                                        child: Text(
                                              'Synonyms: $_word_synonyms',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.roboto(
                                                fontSize: 16.sp,
                                            ),
                                            softWrap: true,
                                          ),
                                        ),
                                  ]
                          ),
                          ),
                        Positioned(
                          top: 10.h,
                          right: 10.w,
                          child: IconButton(
                            icon: Icon(Icons.copy, size: 24, color: Color(0xFF686D76),),
                            onPressed: () {
                              String combinedDetails = '\n${_word_pos!}\n Meaning: ${_word_meaning!}\n Example: ${_word_example!}\n Synonyms: ${_word_synonyms!}';
                              Clipboard.setData(ClipboardData(text: combinedDetails ?? ''));
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 20.h,
                          left: 30.w,
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: (){
                                      if (!isFrontTextPlaying && !isBackTextPlaying) {
                                         _speakDetails();
                                      }
                                  },
                                  child: SizedBox(
                                    width: 22.w,
                                    height: 22.h,
                                    child: Image.asset(
                                      'images/icons/sound_1.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 17.w,),
                                InkWell(
                                  onTap: () {
                                    _pause();
                                  },
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 16.h,
                                    child: Image.asset(
                                      'images/icons/pause_5.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 17.w,),
                                SizedBox(
                                  width: 24.w,
                                  height: 24.h,
                                  child: InkWell(
                                    onTap: () {
                                      // Stop speech
                                      _stop();
                                    },
                                    child: Image.asset(
                                      'images/icons/stop_2.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        )
                      ]
                    )
                ),
                SizedBox(height: 11.h,),
                InkWell(
                  onTap: (){
                    generateRandomWord();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xFF1B9C85),
                        Color(0xFF116D6E),
                      ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('Generate Random Word', style: GoogleFonts.roboto(fontSize: 16.sp, color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
