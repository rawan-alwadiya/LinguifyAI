import 'package:LinguifyAI/bloc_correct_grammar/correct_grammar_bloc.dart';
import 'package:LinguifyAI/bloc_correct_grammar/correct_grammar_events.dart';
import 'package:LinguifyAI/bloc_correct_grammar/correct_grammar_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CorrectlyAiScreen extends StatefulWidget {
  const CorrectlyAiScreen({super.key});

  @override
  State<CorrectlyAiScreen> createState() => _CorrectlyAiScreenState();
}

class _CorrectlyAiScreenState extends State<CorrectlyAiScreen> {
  late TextEditingController _inputController;
  late TextEditingController _outputController;
  late CorrectGrammarBloc correctGrammarBloc;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController();
    _outputController = TextEditingController();
    correctGrammarBloc = BlocProvider.of<CorrectGrammarBloc>(context);
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Padding(
        padding: const EdgeInsets.only(
        top: 23, right: 20, left: 20, bottom: 10),
          child: BlocBuilder<CorrectGrammarBloc, CorrectGrammarState>(
              builder: (context, state){
                if (state is CorrectGrammarLoading) {
                  _outputController.text = '';
                  return SingleChildScrollView(
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
                              Text('CorrectlyAI', style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF31363F),
                              ),),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h,),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 15),
                          child: Text(
                              'Enter your text, tap the magic wand, and let CorrectlyAI transform it into flawless grammar perfection!',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,

                                // color: Color(0xFF686D76),
                                color: Color(0xFF31363F),
                                // color: Color(0xFF50545A),
                              ),
                              textAlign: TextAlign.start
                          ),
                        ),
                        SizedBox(height: 15.h,),
                        Container(
                          child: TextFormField(
                            controller: _inputController,
                            textInputAction: TextInputAction.search,
                            minLines: 6,
                            maxLines: 6,
                            cursorColor: Color(0xff2D2B4E),
                            decoration: InputDecoration(
                              hintText: 'Drop your text here and unleash the magic!',
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
                        SizedBox(height: 20.h,),
                        InkWell(
                          onTap: (){
                            setState(() {
                              final inputText = _inputController.text;
                              print(inputText);
                              if (inputText.isNotEmpty) {
                                print(inputText);
                                correctGrammarBloc.add(SendTextEvent(text: inputText));
                              }
                            });
                          },
                          child: SizedBox(
                            width: 185.w,
                            height: 170.h,
                            child: Image.asset(
                              'images/icons/magic-hat.png',
                              // 'images/icons/magic.png',
                              // 'images/icons/book7.png',
                              fit: BoxFit.cover,
                            ),
                          ),
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
                              hintText: 'Voilà! Your corrected masterpiece will appear here.',
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

                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15.h,),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/bottom_navigation_screen');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 130.w, vertical: 15.h), // Adjust padding
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF248888),
                                  Color(0xFF1B6E6A)
                                  // Color(0xFF7C3E66),
                                  // Color(0xFF7C3E66),
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
                  );
                } else if (state is LoadCorrectedText){
                  _outputController.text = state.correctGrammarResponse.correctedText; // Update corrected text
                  return SingleChildScrollView(
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
                              Text('CorrectlyAI', style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF31363F),
                              ),),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h,),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 15),
                          child: Text(
                              'Enter your text, tap the magic wand, and let CorrectlyAI transform it into flawless grammar perfection!',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                    
                                // color: Color(0xFF686D76),
                                color: Color(0xFF31363F),
                                // color: Color(0xFF50545A),
                              ),
                              textAlign: TextAlign.start
                          ),
                        ),
                        SizedBox(height: 15.h,),
                        Container(
                          child: TextFormField(
                            controller: _inputController,
                            textInputAction: TextInputAction.search,
                            minLines: 6,
                            maxLines: 6,
                            cursorColor: Color(0xff2D2B4E),
                            decoration: InputDecoration(
                              hintText: 'Drop your text here and unleash the magic!',
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
                        SizedBox(height: 20.h,),
                        InkWell(
                          onTap: (){
                            setState(() {
                              final inputText = _inputController.text;
                              print(inputText);
                              if (inputText.isNotEmpty) {
                                print(inputText);
                                correctGrammarBloc.add(SendTextEvent(text: inputText));
                              }
                            });
                          },
                          child: SizedBox(
                            width: 185.w,
                            height: 170.h,
                            child: Image.asset(
                              'images/icons/magic-hat.png',
                              fit: BoxFit.cover,
                            ),
                          ),
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
                              hintText: 'Voilà! Your corrected masterpiece will appear here.',
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

                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15.h,),
                        InkWell(
                          onTap: () {
                            setState(() {
                              correctGrammarBloc.add(ResetCorrectionEvent());
                              Navigator.pushNamed(context, '/bottom_navigation_screen');
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 130.w, vertical: 15.h), // Adjust padding
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
                  );
                } else if (state is CorrectGrammarError) {
                  print(state.error);
                  _outputController.text = 'Something went wrong! try again later.';
                  return SingleChildScrollView(
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
                              Text('CorrectlyAI', style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF31363F),
                              ),),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h,),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 15),
                          child: Text(
                              'Enter your text, tap the magic wand, and let CorrectlyAI transform it into flawless grammar perfection!',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                    
                                // color: Color(0xFF686D76),
                                color: Color(0xFF31363F),
                                // color: Color(0xFF50545A),
                              ),
                              textAlign: TextAlign.start
                          ),
                        ),
                        SizedBox(height: 15.h,),
                        Container(
                          child: TextFormField(
                            controller: _inputController,
                            textInputAction: TextInputAction.search,
                            minLines: 6,
                            maxLines: 6,
                            cursorColor: Color(0xff2D2B4E),
                            decoration: InputDecoration(
                              hintText: 'Drop your text here and unleash the magic!',
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
                        SizedBox(height: 20.h,),
                        SizedBox(
                          width: 185.w,
                          height: 170.h,
                          child: Image.asset(
                            'images/icons/magic-hat.png',
                            // 'images/icons/magic.png',
                            // 'images/icons/book7.png',
                            fit: BoxFit.cover,
                          ),
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
                              hintText: 'Voilà! Your corrected masterpiece will appear here.',
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
                        SizedBox(height: 15.h,),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/bottom_navigation_screen');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 130.w, vertical: 15.h), // Adjust padding
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF248888),
                                  Color(0xFF1B6E6A)
                                  // Color(0xFF7C3E66),
                                  // Color(0xFF7C3E66),
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
                  );
                } else {
                  return SingleChildScrollView(
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
                              Text('CorrectlyAI', style: GoogleFonts.roboto(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF31363F),
                              ),),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h,),
                        Padding(
                          padding: const EdgeInsets.only(
                              right: 15, left: 15),
                          child: Text(
                              'Enter your text, tap the magic wand, and let CorrectlyAI transform it into flawless grammar perfection!',
                              style: GoogleFonts.roboto(
                                fontSize: 16.sp,
                    
                                // color: Color(0xFF686D76),
                                color: Color(0xFF31363F),
                                // color: Color(0xFF50545A),
                              ),
                              textAlign: TextAlign.start
                          ),
                        ),
                        SizedBox(height: 15.h,),
                        Container(
                          child: TextFormField(
                            controller: _inputController,
                            textInputAction: TextInputAction.search,
                            minLines: 6,
                            maxLines: 6,
                            cursorColor: Color(0xff2D2B4E),
                            decoration: InputDecoration(
                              hintText: 'Drop your text here and unleash the magic!',
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
                        SizedBox(height: 20.h,),
                        SizedBox(
                          width: 185.w,
                          height: 170.h,
                          child: Image.asset(
                            'images/icons/magic-hat.png',
                            // 'images/icons/magic.png',
                            // 'images/icons/book7.png',
                            fit: BoxFit.cover,
                          ),
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
                              hintText: 'Voilà! Your corrected masterpiece will appear here.',
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
                        SizedBox(height: 15.h,),
                        InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/bottom_navigation_screen');
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 130.w, vertical: 15.h), // Adjust padding
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF248888),
                                  Color(0xFF1B6E6A)
                                  // Color(0xFF7C3E66),
                                  // Color(0xFF7C3E66),
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
                  );
                }
              }
          ),
      ),
      ),
    );
  }
}
