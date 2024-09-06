import 'dart:typed_data';
import 'dart:io';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Gemini gemini = Gemini.instance;
  List<ChatMessage> messages = [];
  ChatUser currentUser = ChatUser(id: "0", firstName: "User");
  ChatUser geminiUser = ChatUser(
      id: "1",
      firstName: 'Gemini',
      profileImage:
          'https://i.pinimg.com/236x/ca/59/84/ca5984fe778c501215a4107dff8cf2f5.jpg');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBot'),
        centerTitle: true,
      ),
      body: buildUI(),
    );
  }

  Widget buildUI() {
    return DashChat(
        inputOptions: InputOptions(trailing: [
          IconButton(
              onPressed: _sendMediaMesseage, icon: const Icon(Icons.image))
        ]),
        currentUser: currentUser,
        onSend: _sendMessage,
        messages: messages);
  }

  void _sendMessage(ChatMessage chatMessage) {
    messages = [chatMessage, ...messages];
    setState(() {});
    try {
      String question = chatMessage.text;
      List<Uint8List>? images;
      if (chatMessage.medias?.isNotEmpty ?? false) {
        images = [
          File(chatMessage.medias!.first.url).readAsBytesSync(),
        ];
      }
      gemini.streamGenerateContent(question,images: images).listen((event) {
        ChatMessage? lastMessage = messages.firstOrNull;
        if (lastMessage != null && lastMessage.user == geminiUser) {
          lastMessage = messages.removeAt(0);
          String response = event.content?.parts?.fold(
                  '', (previous, current) => '$previous${current.text}') ??
              '';
          lastMessage.text += response;
          messages = [lastMessage, ...messages];
          setState(() {});
        } else {
          String response = event.content?.parts?.fold(
                  '', (previous, current) => '$previous${current.text}') ??
              '';
          ChatMessage message = ChatMessage(
            user: geminiUser,
            createdAt: DateTime.now(),
            text: response,
          );
          messages = [message, ...messages];
          setState(() {});
        }
      });
    } catch (e) {
      print(e);
    }
  }

  void _sendMediaMesseage() async {
    ImagePicker picker = ImagePicker();
    XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (file != null) {
      ChatMessage chatMessage = ChatMessage(
          user: currentUser,
          createdAt: DateTime.now(),
          text: 'Describe this picture?',
          medias: [
            ChatMedia(url: file.path, fileName: '', type: MediaType.image)
          ]);
      _sendMessage(chatMessage);
    }
  }
}
