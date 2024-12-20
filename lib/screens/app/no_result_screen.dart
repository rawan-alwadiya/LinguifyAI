import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NoResultScreen extends StatelessWidget {
  const NoResultScreen({super.key});

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
              SizedBox(height: 30.h,),
            Padding(
              padding: const EdgeInsets.only(
                  top:55, right: 25, left: 25),
              child: SizedBox(
                width: 140.w,
                height: 140.h,
                child: Image.asset(
                  'images/icons/search_4.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
              SizedBox(height: 50.h,),
              Text('No Result Found', style: GoogleFonts.roboto(
                fontSize: 25.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF373A40),
              ),),
              SizedBox(height: 20.h,),
              Text('Please ensure that the image you upload is clear and legible, avoid taking photos with glare or shadows, for best results, try scanning the text or taking a photo on a flat, well-lit surface',
                style: GoogleFonts.roboto(
                fontSize: 18.sp,
                // fontWeight: FontWeight.bold,
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
