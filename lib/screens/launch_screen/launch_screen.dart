import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Preload the image to avoid delayed loading
    precacheImage(AssetImage('images/icons/magic.png'), context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(context, '/bottom_navigation_screen');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB9B4C7),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 140.w,
                height: 140.h,
                child: Image.asset(
                  'images/icons/magic.png',
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 5.h,),
              Text(
                'LinguifyAI',
                style: GoogleFonts.chewy(
                fontSize: 36.sp,
                color: Color(0xFF31363F),
              ),
              ),
            ],
          ),
        ),
    );
  }
}
