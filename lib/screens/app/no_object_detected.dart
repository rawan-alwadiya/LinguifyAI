import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoObjectDetected extends StatelessWidget {
  const NoObjectDetected({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(
              top:55,right: 25, left: 25
          ),
          child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                      onPressed: ()=> Navigator.pushReplacementNamed(context,'/bottom_navigation_screen'),
                      icon: Icon(Icons.arrow_back_ios_new_outlined, color: Color(0xFF373A40),)
                  ),
                ),
                SizedBox(height: 10.h,),
                Padding(
                  padding: const EdgeInsets.only(
                      top:50, right: 25, left: 25),
                  child: SizedBox(
                    width: 180.w,
                    height: 180.h,
                    child: Image.asset(
                      'images/icons/search_9.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 50.h,),
                Text('No Object Detected', style: GoogleFonts.roboto(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF373A40),
                ),),
                SizedBox(height: 20.h,),
                Text('Ensure the object is well-lit, and avoid blurry or dark areas for better detection results',
                    style: GoogleFonts.roboto(
                      fontSize: 18.sp,
                      color: Color(0xFF686D76),
                    ),
                    textAlign: TextAlign.center
                ),
              ]
          ),
        ),
      ),
    );
  }
}
