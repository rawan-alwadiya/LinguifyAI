import 'package:LinguifyAI/bloc/chat_bloc.dart';
import 'package:LinguifyAI/bloc/chat_states.dart';
import 'package:LinguifyAI/bloc_correct_grammar/correct_grammar_bloc.dart';
import 'package:LinguifyAI/bloc_correct_grammar/correct_grammar_states.dart';
import 'package:LinguifyAI/bloc_random_question/random_question_bloc.dart';
import 'package:LinguifyAI/bloc_random_question/random_question_states.dart';
import 'package:LinguifyAI/bloc_summarization/Summarization_bloc.dart';
import 'package:LinguifyAI/bloc_summarization/summarization_states.dart';
import 'package:LinguifyAI/bloc_validate_answer/validate_answer_bloc.dart';
import 'package:LinguifyAI/bloc_validate_answer/validate_answer_states.dart';
import 'package:LinguifyAI/cubit/language_cubit.dart';
import 'package:LinguifyAI/database/chat_db_operations.dart';
import 'package:LinguifyAI/prefs/shared_pref_controller.dart';
import 'package:LinguifyAI/screens/app/bottom_navigation_screen.dart';
import 'package:LinguifyAI/screens/app/brevity_bot_screen.dart';
import 'package:LinguifyAI/screens/app/chat_pro_ai_screen.dart';
import 'package:LinguifyAI/screens/app/correctly_ai_screen.dart';
import 'package:LinguifyAI/screens/app/explore_words_screen.dart';
import 'package:LinguifyAI/screens/app/grammar_gladiator_screen.dart';
import 'package:LinguifyAI/screens/app/win_zone_screen.dart';
import 'package:LinguifyAI/screens/app/grammar_guru_screen.dart';
import 'package:LinguifyAI/screens/app/no_object_detected.dart';
import 'package:LinguifyAI/screens/app/no_result_screen.dart';
import 'package:LinguifyAI/screens/app/object_lens_screen.dart';
import 'package:LinguifyAI/screens/app/translation_screen.dart';
import 'package:LinguifyAI/screens/launch_screen/launch_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await SharedPrefController().initPreferences();
  await SharedPrefController.instance.initPreferences(); // Ensure correct singleton access
  await ChatDatabaseOperations().initDatabase();
  // final dbOperations = ChatDatabaseOperations();
  // await dbOperations.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, child){
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => LanguageCubit()..getSavedLanguage()),
            BlocProvider<ChatBloc>(create: (context) => ChatBloc(ChatLoading())),
            BlocProvider<RandomQuestionBloc>(create: (context) => RandomQuestionBloc(RandomQuestionLoading())),
            BlocProvider<CorrectGrammarBloc>(create: (context) => CorrectGrammarBloc(CorrectGrammarLoading())),
            BlocProvider<ValidateAnswerBloc>(create: (context) => ValidateAnswerBloc(ValidateAnswerLoading())),
            BlocProvider<SummarizationBloc>(create: (context) => SummarizationBloc(SummarizationLoading())),
          ],
            child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Linguify',
        theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Color(0xff2D2B4E),
            appBarTheme: const AppBarTheme(
              titleTextStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff2D2B4E)
              ),
            ),
            // scaffoldBackgroundColor: kScaffoldColor
            scaffoldBackgroundColor: Color(0xFFB9B4C7),
        ),
        initialRoute: '/launch_screen',
        routes: {
          '/launch_screen':  (context) => const LaunchScreen(),
          '/bottom_navigation_screen': (context) => const BottomNavigationScreen(),
          '/translation_screen': (context) => const TranslationScreen(),
          '/explore_words_screen': (context) => const ExploreWordsScreen(),
          '/object_lens_screen': (context) => const ObjectLensScreen(),
          '/no_result_screen': (context) => const NoResultScreen(),
          '/no_object_detected': (context) => const NoObjectDetected(),
          '/chat_pro_ai_screen': (context) => const ChatProAiScreen(),
          '/grammar_guru_screen': (context) => const GrammarGuruScreen(),
          '/correctly_ai_screen': (context) => const CorrectlyAiScreen(),
          '/grammar_gladiator_screen': (context) => const GrammarGladiatorScreen(),
          '/win_zone_screen': (context) => const WinZoneScreen(),
          '/brevity_bot_screen': (context) => const BrevityBotScreen(),
        },
      )
        );

    }
    );
  }
}

