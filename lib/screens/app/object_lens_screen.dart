import 'package:LinguifyAI/cubit/language_cubit.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:LinguifyAI/screens/app/no_object_detected.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

class ObjectLensScreen extends StatefulWidget {
  const ObjectLensScreen({super.key});

  @override
  State<ObjectLensScreen> createState() => _ObjectLensScreenState();
}

class _ObjectLensScreenState extends State<ObjectLensScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _imageFile;
  late ObjectDetector _objectDetector;
  bool _isImageDetected = false;
  String? _description;
  late OnDeviceTranslator _translator;
  String? _translatedText = '';
  String _fromLanguage = SharedPrefController.instance.getFromLanguage();
  String _toLanguage = SharedPrefController.instance.getToLanguage();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isListening = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<LanguageCubit>().getSavedLanguage();
    _initializeObjectDetector();
    _initializeTranslator();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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

  Future<void> _getImageFromSource(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
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

      //
      if(object.labels.isNotEmpty){
        setState(() {
          _description = object.labels.first.text;
          _isImageDetected = true;
        });
        await _translateDescription();
      }else {
        setState(() {
          _isImageDetected = false;
        });
        _navigateToNoObjectDetectedPage();
      }
    } else {
      setState(() {
        _isImageDetected = false;
      });
      _navigateToNoObjectDetectedPage();
    }
  }

  Future<void> _translateDescription() async {
    if (_description != null) {
      final translated = await _translator.translateText(_description!);
      setState(() {
        _translatedText = translated;
      });
    }
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

  Future<void> _speak(String text, String language) async {
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
    if (_description != null) {
      await _flutterTts.speak('Description: \n${_description!}');
    }
  }

  void _showImageSourceOptions() {
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

  void _navigateToNoObjectDetectedPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoObjectDetected(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 25, right: 20, left: 20, bottom: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 30, right: 20, left: 20, bottom: 5),
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
                    Text('Object Lens', style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF31363F),
                    ),),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.only(
                    right: 15, left: 15),
                child: Text(
                    'Discover the world around you! Snap a picture of any object, and our tool will instantly identify it and provide a translation, helping you understand your surroundings in any language',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Color(0xFF31363F),
                    ),
                    textAlign: TextAlign.start
                ),
              ),
              SizedBox(height: 20.h,),
              SizedBox(
                width: 230.w,
                height: 210.h,
                child: InkWell(
                  onTap: (){
                    _showImageSourceOptions();
                  },
                  child: Image.asset(
                    'images/icons/photo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // SizedBox(height: 5.h,),
              Visibility(
                visible: _isImageDetected && _description != null && _translatedText != null,
                replacement: Padding(
                  padding: const EdgeInsets.only(top: 55),
                  child: Text(
                    'Awaiting image input...',
                      style: GoogleFonts.roboto(
                        fontSize: 19.sp,

                        // color: Color(0xFF686D76),
                        color: Color(0xFF31363F),
                      ),
                      textAlign: TextAlign.center
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                    alignment: Alignment.center,
                    width: 303.w, // Set fixed width
                    height: 160.h, // Set fixed height
                      padding: EdgeInsets.only(top: 20.h, bottom: 20.h, left: 10.w, right: 10.w),
                    // ), // Adjust padding
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF898AA6),
                          Color(0xFF9A86A4),
                          // Color(0xFF6983AA),
                          // Color(0xFF5584AC),
                          // Color(0xFF5C7893),
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
                                'Description: $_description',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  // color: Colors.grey.shade900,
                                ),
                                softWrap: true,
                              )),
                          SizedBox(height: 8.h),
                          Flexible(
                              child: Text(
                                 '$_translatedText',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  // color: Colors.grey.shade900,
                                ),
                                softWrap: true,
                              )),
                        ]
                    ),
                  ),
                    Positioned(
                      top: 10.h,
                      right: 10.w,
                      child: IconButton(
                        icon: Icon(Icons.copy, size: 24, color: Color(0xFF686D76),),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: 'Description: $_description' ?? ''));
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 12.h,
                      left: 25.w,
                      child:
                      // Row(
                      //   children: [
                          InkWell(
                            onTap: (){
                              _speak('Description: \n$_description', 'English');
                            },
                            child: SizedBox(
                              width: 26.w,
                              height: 26.h,
                              child: Image.asset(
                                'images/icons/sound_1.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ),
                    // )
                  ]
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
