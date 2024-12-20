import 'package:LinguifyAI/bloc_random_question/random_question_bloc.dart';
import 'package:LinguifyAI/bloc_random_question/random_question_events.dart';
import 'package:LinguifyAI/bloc_random_question/random_question_states.dart';
import 'package:LinguifyAI/bloc_validate_answer/validate_answer_bloc.dart';
import 'package:LinguifyAI/bloc_validate_answer/validate_answer_event.dart';
import 'package:LinguifyAI/bloc_validate_answer/validate_answer_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrammarGladiatorScreen extends StatefulWidget {
  const GrammarGladiatorScreen({super.key});

  @override
  State<GrammarGladiatorScreen> createState() => _GrammarGladiatorScreenState();
}

class _GrammarGladiatorScreenState extends State<GrammarGladiatorScreen> {
  late RandomQuestionBloc randomQuestionBloc;
  late ValidateAnswerBloc validateAnswerBloc;
  String selectedChoice = '';
  int questionCount = 0;
  int score = 0;
  bool _hasScored = false;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    randomQuestionBloc = BlocProvider.of<RandomQuestionBloc>(context);
    validateAnswerBloc = BlocProvider.of<ValidateAnswerBloc>(context);
    randomQuestionBloc.add(GetRandomQuestionEvent());
  }


  void handleNext() {
    if (questionCount < 10) {
      setState(() {
        questionCount++;
        selectedChoice = '';
        _isSubmitted = false;
        _hasScored = false;
        validateAnswerBloc.add(ResetValidateAnswerEvent());
        randomQuestionBloc.add(GetRandomQuestionEvent());
      });
    } else {
      Navigator.pushNamed(context, '/win_zone_screen', arguments: score).then((_) {
        // Reset score and question count for a new quiz
        setState(() {
          score = 0;
          questionCount = 0;
          validateAnswerBloc.add(ResetValidateAnswerEvent());
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
        padding: const EdgeInsets.only(
        top: 23, right: 20, left: 20, bottom: 10),
          child: BlocBuilder<RandomQuestionBloc, RandomQuestionState>(
              builder: (context, state) {
                if (state is RandomQuestionLoading) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30, right: 20, left: 0, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  onPressed: ()=> Navigator.pushReplacementNamed(context,'/bottom_navigation_screen'),
                                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xFF373A40),)
                              ),
                            ),
                            SizedBox(
                              width: 35.w,
                              height: 35.h,
                              child: Image.asset(
                                'images/icons/dictionary.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 15.w,),
                            Text('Grammar Gladiator', style: GoogleFonts.roboto(
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
                            'The arena awaits your brilliance—choose wisely!',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,

                              color: Color(0xFF686D76),
                              // color: Color(0xFF686D76),
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        width: 320.w,
                        height: 100.h,// Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              // Color(0xFF69779B) : Color(0xFF9692AF),
                              // Color(0xFF827397),
                              // Color(0xFF827397),
                              Color(0xFF898AA6),
                              Color(0xFF9A86A4),
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child:
                        Center(
                          child: Text(
                            'Finding you next challenge...',
                            style: TextStyle(
                              fontSize: 16.sp, // Text size
                              color: Colors.black, // Text color
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, // Fixed height
                            decoration: BoxDecoration(
                              // color: Color(0xFF69779B),
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option A',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, // Fixed height // Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option B',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, //  Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option C',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, //  // Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              // Color(0xFF7C3E66),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option D',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                          width: 160.w,
                          height: 150.h,
                          child: Image.asset(
                            'images/icons/person.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 20.h,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 110.w, vertical: 13.h), // Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF248888),
                              Color(0xFF1B6E6A)
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16.sp, // Text size
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 120.w, vertical: 13.h), // Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB91646),
                              Color(0xFFB91646),
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16.sp, // Text size
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (state is RandomQuestionLoaded) {
                  final question = state.randomQuestionResponse.question;
                  final choices = state.randomQuestionResponse.choices;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 30, right: 20, left: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: IconButton(
                                    onPressed: ()=> Navigator.pushReplacementNamed(context,'/bottom_navigation_screen'),
                                    icon: Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xFF373A40),)
                                ),
                              ),
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
                              Text('Grammar Gladiator', style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF31363F),
                              ),),
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 15),
                          child: Text(
                              'The arena awaits your brilliance—choose wisely!',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,

                                // color: Color(0xFF686D76),
                                // color: Color(0xFF50545A),
                                color: Color(0xFF31363F),
                              ),
                              textAlign: TextAlign.start
                          ),
                        ),
                        SizedBox(height: 7.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10.w, vertical: 10.h),
                          width: 320.w,
                          height: 110.h,// Adjust padding
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                // Color(0xFF69779B) : Color(0xFF9692AF),
                                // Color(0xFF827397),
                                // Color(0xFF827397),
                                Color(0xFF898AA6),
                                Color(0xFF9A86A4),
                              ], // Gradient colors
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12), // Rounded corners
                          ),
                          child:
                          Center(
                            child: SingleChildScrollView(
                              child: Text(
                                question,
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: (){
                                setState(() {
                                  selectedChoice = choices.s1;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h), // Adjust padding
                                width: 155.w, // Fixed width
                                height: 55.h, // Fixed height
                                decoration: BoxDecoration(
                                  // color: Color(0xFF69779B),
                                  color: selectedChoice != choices.s1? Color(0xFF69779B) : Color(0xFF7C3E66),
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Center(
                                  child: Text(
                                    choices.s1,
                                    style: TextStyle(
                                      fontSize: 16.sp, // Text size
                                      color: Colors.black, // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w,),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedChoice = choices.s2;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h), // Adjust padding
                                width: 155.w, // Fixed width
                                height: 55.h, // Fixed height // Adjust padding
                                decoration: BoxDecoration(
                                  color: selectedChoice != choices.s2? Color(0xFF69779B) : Color(0xFF7C3E66),
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Center(
                                  child: Text(
                                    choices.s2,
                                    style: TextStyle(
                                      fontSize: 16.sp, // Text size
                                      color: Colors.black, // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h,),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedChoice = choices.s3;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h), // Adjust padding
                                width: 155.w, // Fixed width
                                height: 55.h, //  Adjust padding
                                decoration: BoxDecoration(
                                  color: selectedChoice != choices.s3? Color(0xFF69779B) : Color(0xFF7C3E66),
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Center(
                                  child: Text(
                                    choices.s3,
                                    style: TextStyle(
                                      fontSize: 16.sp, // Text size
                                      color: Colors.black, // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedChoice = choices.s4;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 5.h), // Adjust padding
                                width: 155.w, // Fixed width
                                height: 55.h, //  // Adjust padding
                                decoration: BoxDecoration(
                                  color: selectedChoice != choices.s4? Color(0xFF69779B) : Color(0xFF7C3E66),
                                  // Color(0xFF7C3E66),
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                child: Center(
                                  child: Text(
                                    choices.s4,
                                    style: TextStyle(
                                      fontSize: 16.sp, // Text size
                                      color: Colors.black, // Text color
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        BlocBuilder<ValidateAnswerBloc, ValidateAnswerState>(
                            builder: (context, state) {
                              if (state is ValidateAnswerLoading) {
                                print('Loading...');
                                return SizedBox(
                                        width: 185.w,
                                        height: 175.h,
                                        child: Image.asset(
                                          'images/icons/person.png',
                                          fit: BoxFit.cover,
                                        ),
                                );
                              } else if (state is ValidateAnswerLoaded) {
                                    if (state.validateAnswerResponse.correct && !_hasScored) {
                                      score++;
                                      _hasScored = true;
                                    }
                                return Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 140.w,
                                          height: 120.h,
                                          child: Image.asset(
                                            state.validateAnswerResponse.correct? 'images/icons/party2.png' : 'images/icons/person4.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 10.h,),
                                        Text(
                                          state.validateAnswerResponse.message,
                                        style: GoogleFonts.roboto(
                                          fontSize: 16.sp,
                                          color: Colors.black,
                                        ),
                                            textAlign: TextAlign.center
                                        ),
                                        SizedBox(height: 5.h,),
                                        Text(
                                            'The correct answer is: ${state.validateAnswerResponse.correctAnswer}',
                                            style: GoogleFonts.roboto(
                                              fontSize: 16.sp,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center
                                        ),
                                      ],
                                );
                              } else if (state is ValidateAnswerError) {
                                print('Error: ${state.error}');
                                return SizedBox(
                                        width: 185.w,
                                        height: 175.h,
                                        child: Image.asset(
                                          'images/icons/person.png',
                                          fit: BoxFit.cover,
                                        ),
                                );
                              } else {
                                return SizedBox(
                                        width: 185.w,
                                        height: 175.h,
                                        child: Image.asset(
                                          'images/icons/person.png',
                                          fit: BoxFit.cover,
                                        ),
                                );
                              }
                            }
                        ),
                        SizedBox(height: 8.h,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (selectedChoice != '' && !_isSubmitted) {
                                validateAnswerBloc.add(SendAnswerEvent(question: question, userChoice: selectedChoice));
                                _isSubmitted = true;
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 110.w, vertical: 13.h), // Adjust padding
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF248888),
                                  Color(0xFF1B6E6A)
                                ], // Gradient colors
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Text(
                              'Submit',
                              style: TextStyle(
                                fontSize: 16.sp, // Text size
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (selectedChoice != '' && _isSubmitted) {
                                handleNext();
                              }
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 120.w, vertical: 13.h), // Adjust padding
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFB91646),
                                  Color(0xFFB91646),
                                ], // Gradient colors
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 16.sp, // Text size
                                color: Colors.white, // Text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is RandomQuestionError) {
                  print('Error: ${state.error}');
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30, right: 20, left: 0, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  onPressed: ()=> Navigator.pushReplacementNamed(context,'/bottom_navigation_screen'),
                                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xFF373A40),)
                              ),
                            ),
                            SizedBox(
                              width: 35.w,
                              height: 35.h,
                              child: Image.asset(
                                'images/icons/dictionary.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 15.w,),
                            Text('Grammar Gladiator', style: GoogleFonts.roboto(
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
                            'The arena awaits your brilliance—choose wisely!',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,

                              color: Color(0xFF686D76),
                              // color: Color(0xFF686D76),
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 13.h),
                        width: 320.w,
                        height: 110.h,// Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              // Color(0xFF69779B) : Color(0xFF9692AF),
                              // Color(0xFF827397),
                              // Color(0xFF827397),
                              Color(0xFF898AA6),
                              Color(0xFF9A86A4),
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child:
                        Center(
                          child: Text(
                            'Oops! Something went wrong. Please try again.',
                            style: TextStyle(
                              fontSize: 16.sp, // Text size
                              color: Colors.black, // Text color
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, // Fixed height
                            decoration: BoxDecoration(
                              // color: Color(0xFF69779B),
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option A',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, // Fixed height // Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option B',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, //  Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option C',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, //  // Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              // Color(0xFF7C3E66),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option D',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                          width: 160.w,
                          height: 150.h,
                          child: Image.asset(
                            'images/icons/person.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      SizedBox(height: 20.h,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 110.w, vertical: 13.h), // Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF248888),
                              Color(0xFF1B6E6A)
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16.sp, // Text size
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 120.w, vertical: 13.h), // Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB91646),
                              Color(0xFFB91646),
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16.sp, // Text size
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  print('Something went wrong! try again later.');
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 30, right: 20, left: 0, bottom: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: IconButton(
                                  onPressed: ()=> Navigator.pushReplacementNamed(context,'/bottom_navigation_screen'),
                                  icon: Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xFF373A40),)
                              ),
                            ),
                            SizedBox(
                              width: 35.w,
                              height: 35.h,
                              child: Image.asset(
                                'images/icons/dictionary.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 15.w,),
                            Text('Grammar Gladiator', style: GoogleFonts.roboto(
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
                            'The arena awaits your brilliance—choose wisely!',
                            style: GoogleFonts.roboto(
                              fontSize: 16.sp,

                              color: Color(0xFF686D76),
                              // color: Color(0xFF686D76),
                            ),
                            textAlign: TextAlign.start
                        ),
                      ),
                      SizedBox(height: 15.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 13.h),
                        width: 320.w,
                        height: 110.h,// Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              // Color(0xFF69779B) : Color(0xFF9692AF),
                              // Color(0xFF827397),
                              // Color(0xFF827397),
                              Color(0xFF898AA6),
                              Color(0xFF9A86A4),
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child:
                        Center(
                          child: Text(
                            'Oops! Something went wrong. Please try again.',
                            style: TextStyle(
                              fontSize: 16.sp, // Text size
                              color: Colors.black, // Text color
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, // Fixed height
                            decoration: BoxDecoration(
                              // color: Color(0xFF69779B),
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option A',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w,),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, // Fixed height // Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option B',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h,),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, //  Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option C',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 10.h), // Adjust padding
                            width: 155.w, // Fixed width
                            height: 50.h, //  // Adjust padding
                            decoration: BoxDecoration(
                              color: Color(0xFF69779B),
                              // Color(0xFF7C3E66),
                              borderRadius: BorderRadius.circular(12), // Rounded corners
                            ),
                            child: Center(
                              child: Text(
                                'Option D',
                                style: TextStyle(
                                  fontSize: 16.sp, // Text size
                                  color: Colors.black, // Text color
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      SizedBox(
                          width: 160.w,
                          height: 150.h,
                          child: Image.asset(
                            'images/icons/person.png',
                            fit: BoxFit.cover,
                          ),
                      ),
                      SizedBox(height: 20.h,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 110.w, vertical: 13.h), // Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF248888),
                              Color(0xFF1B6E6A)
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16.sp, // Text size
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h,),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 120.w, vertical: 13.h), // Adjust padding
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFB91646),
                              Color(0xFFB91646),
                            ], // Gradient colors
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12), // Rounded corners
                        ),
                        child: Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16.sp, // Text size
                            color: Colors.white, // Text color
                          ),
                        ),
                      ),
                    ],
                  );
                }
              }
          )
      ),
      )
    );
  }
}