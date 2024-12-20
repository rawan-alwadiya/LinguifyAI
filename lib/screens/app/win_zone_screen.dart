import 'package:LinguifyAI/bloc_validate_answer/validate_answer_bloc.dart';
import 'package:LinguifyAI/bloc_validate_answer/validate_answer_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WinZoneScreen extends StatefulWidget {
  const WinZoneScreen({super.key});

  @override
  State<WinZoneScreen> createState() => _WinZoneScreenState();
}

class _WinZoneScreenState extends State<WinZoneScreen> {

  String image = '';
  String title = '';
  String message = '';


  @override
  Widget build(BuildContext context) {
    final int score = ModalRoute.of(context)!.settings.arguments as int;
    if(score == 10){
      image = 'images/icons/cup.png';
      title = 'Unstoppable Champion!';
      message = 'You\'re a Grammar Gladiator Supreme! Conquer another challenge and show your brilliance!';
    } else if(score >= 8){
      image = 'images/icons/shield.png';
      title = 'Grammar Warrior!';
      message = 'Amazing work! You\'re just a step away from perfection. Take on another battle!';
    } else if(score >= 6){
      image = 'images/icons/bronze-medal.png';
      title = 'Aspiring Legend!';
      message = 'You’re rising! Keep sharpening your skills, and soon the top will be yours. Your journey has just begun!';
    } else {
      image = 'images/icons/book4.png';
      title = 'Future Champion!';
      message = 'The road to victory is clear! Keep learning and growing—each step brings you closer to the top!';
    }
    return Scaffold(
      body: Container(
        child: Padding(
            padding: EdgeInsets.only(
                top: 25, right: 20, left: 20, bottom: 10
            ),
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
                    Text('Win Zone', style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF31363F),
                    ),),
                  ],
                ),
              ),
              SizedBox(height: 40.h),
              SizedBox(
                width: 300.w,
                height: 275.h,
                child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 40.h,),
              Text('${score}/10',
                  style: GoogleFonts.roboto(
                    fontSize: 19.sp,
                    // color: Color(0xFF686D76),
                    color: Color(0xFF31363F),
                    // color: Color(0xFF31363F),
                    // color: Color(0xFF686D76),
                  ),
                  textAlign: TextAlign.center
              ),
              SizedBox(height: 10.h,),
              Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 19.sp,
                    // color: Color(0xFF686D76),
                    color: Color(0xFF31363F),
                    // color: Color(0xFF686D76),
                  ),
                  textAlign: TextAlign.center
              ),
              SizedBox(height: 10.h,),
              Text(
                  message,
                  style: GoogleFonts.roboto(
                    fontSize: 19.sp,
                    // color: Color(0xFF686D76),
                    color: Color(0xFF31363F),
                // color: Color(0xFF686D76),
                      ),
                  textAlign: TextAlign.center),
              SizedBox(height: 40.h,),
              InkWell(
                onTap: () {
                  setState(() {
                    BlocProvider.of<ValidateAnswerBloc>(context).add(ResetValidateAnswerEvent());
                  });
                  Navigator.pushNamed(context, '/bottom_navigation_screen');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 120.w, vertical: 13.h), // Adjust padding
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
                    'Back',
                    style: TextStyle(
                      fontSize: 16.sp, // Text size
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
