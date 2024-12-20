import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrammarGuruScreen extends StatefulWidget {
  const GrammarGuruScreen({super.key});

  @override
  State<GrammarGuruScreen> createState() => _GrammarGuruScreenState();
}

class _GrammarGuruScreenState extends State<GrammarGuruScreen> {
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
                        'images/icons/magic.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 15.w,),
                    Text('Grammar Guru', style: GoogleFonts.roboto(
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
                    'Challenge your grammar skills or get them corrected with AI-powered tools. Choose your path below and start your journey to grammar mastery!',
                    style: GoogleFonts.roboto(
                      fontSize: 16.sp,
                      color: Color(0xFF31363F),
                      // color: Color(0xFF686D76),
                    ),
                    textAlign: TextAlign.start
                ),
              ),
              SizedBox(height: 20.h,),
              SizedBox(
                width: 247.w,
                height: 225.h,
                child: Image.asset(
                    'images/icons/magic_wand.png',
                    fit: BoxFit.cover,
                  ),
              ),
              SizedBox(height: 40.h),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/grammar_gladiator_screen');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 70.w, vertical: 8.h), // Adjust padding
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF11698E),
                        Color(0xFF19456B),
                      ], // Gradient colors
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12), // Rounded corners
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 28, // Adjust icon size
                        color: Colors.white, // Icon color
                      ),
                      SizedBox(height: 4.h),
                      // Space between icon and text
                      Text(
                        'Grammar Gladiator',
                        style: TextStyle(
                          fontSize: 16.sp, // Text size
                          color: Colors.white, // Text color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/correctly_ai_screen');
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 97.w, vertical: 7.h), // Adjust padding
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF248888),
                        Color(0xFF1B6E6A)
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
                        Icons.menu_book,
                        size: 24, // Adjust icon size
                        color: Colors.white, // Icon color
                      ),
                      SizedBox(height: 4.h),
                      // Space between icon and text
                      Text(
                        'Correctly AI',
                        style: TextStyle(
                          fontSize: 16.sp, // Text size
                          color: Colors.white, // Text color
                        ),
                      ),
                    ],
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
