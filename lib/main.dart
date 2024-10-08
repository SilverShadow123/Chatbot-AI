import 'package:ai_chatbot/consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import 'home_page.dart';

void main()
{
  Gemini.init(apiKey: GEMINI_API_KEY,);
  runApp(const chatbot());
}

class chatbot extends StatelessWidget {
  const chatbot({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}




