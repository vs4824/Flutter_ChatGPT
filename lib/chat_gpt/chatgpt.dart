import 'dart:async';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import '../type_indicator/chat_loader.dart';


class ChatBotWidget extends StatefulWidget {
  final String? title;
  const ChatBotWidget({Key? key, this.title}) : super(key: key);

  @override
  _ChatBotWidgetState createState() => _ChatBotWidgetState();
}

class _ChatBotWidgetState extends State<ChatBotWidget> {
  Duration duration = const Duration();
  Duration position = const Duration();
  List<String> chat = [];
  List<String> isSender_string = [];
  List<String> isSender = [];
  TextEditingController searchController = TextEditingController();
  OpenAI? chatGPT;
  bool bools = false;
  String? msg;
  Timer? periodicTimer;
  DateTime selectedDate = DateTime.now();
  StreamSubscription? _subscription;
  bool _isImageSearch = false;
  int counter2 = 0;
  String? text;

  Future<void> _sendMessage() async {
    setState((){
      counter2 = 0;
    });
    final request = CompleteText(
        prompt: text!, model: kTranslateModelV3, maxTokens: 500);
    _subscription = chatGPT
        ?.onCompleteStream(request: request)
        .asBroadcastStream()
        .listen((response) {
      // Vx.log(response?.choices[0].text);
      msg = response?.choices[0].text;
      counter2++;
      counter2 < 2 ? insertNewData() : print("");
    });
    // insertNewData(msg, isImage: false);
  }

  insertNewData(){
    if(msg != null){
      setState(() {
        bools = false;
        chat.insert(0, msg!.replaceAll('\n', ''));
        isSender.insert(0,"false");
        searchController.clear();
        // sharedFalse();
      });
    }
  }

  Restriction(){

    final request = CompleteText(prompt: "", model: kTranslateModelV3, maxTokens: 500);

    _subscription = chatGPT
        ?.onCompleteStream(request: request)
        .asBroadcastStream()
        .listen((response) {
      // Vx.log(response?.choices[0].text);
    });
  }

  @override
  void initState() {
    super.initState();
    chatGPT = OpenAI.instance.build(
      token: "Your API Key",
    );
    Restriction();
    Future.delayed(const Duration(seconds: 1), (){
      chat.isEmpty ? setState(() {
        chat.insert(0,"Hello");
        isSender.insert(0, "false");
      }) : print("");
    });
    Future.delayed(const Duration(seconds: 1), (){
      chat.length == 1 ? setState(() {
        chat.insert(0,"How can i help you?");
        isSender.insert(0, "false");
      }) : print("");
    });
  }

  @override
  void dispose() {
    chatGPT?.close();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final scale = mediaQueryData.textScaleFactor.clamp(1.0, 1.1);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: scale),
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                title: const Text("Flutter ChatGPT"),
              ),
              body: chat.length > 1 ?
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ListView.builder(
                            reverse: true,
                            itemCount: chat.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: index == 0 ? const EdgeInsets.only(
                                        top: 8.0)
                                        : const EdgeInsets.only(top: 0.0),
                                    child: BubbleNormal(
                                      text: chat[index],
                                      isSender: isSender[index].toLowerCase() ==
                                          "true" ? true : false,
                                      color: isSender[index] == "true" ? const Color
                                          .fromRGBO(213, 224, 242, 1) : const Color
                                          .fromRGBO(225, 228, 234, 1),
                                      tail: true,
                                      textStyle: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                      ),
                      bools == true ? TypingIndicator(
                          showIndicator: bools
                      )
                          : const SizedBox(height: 0, width: 0,),
                    ],
                  ),
                ),
              ) : const Center(child: CircularProgressIndicator()),
              persistentFooterButtons: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0,right: 20,top: 10,bottom: 0),
                      child: Container(
                        height: 50,
                        width: searchController.text != null && searchController.text != "" ?
                        MediaQuery.of(context).size.width * 0.73 : MediaQuery.of(context).size.width * 0.86,
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 255, 255, 1),
                          boxShadow: const [BoxShadow(
                            color: Color.fromRGBO(238, 239, 242, 1),
                            blurRadius: 15.0,
                          ),],
                          border: Border.all(
                              width: 1.0,
                              color: const Color.fromRGBO(255, 255, 255, 1)
                          ),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(12.0) //                 <--- border radius here
                          ),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 5.0,left: 10),
                                child: TextFormField(
                                  controller: searchController,
                                  decoration: const InputDecoration(
                                    hintText: 'Message',
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value){
                                    setState(() {
                                      searchController.text;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    searchController.text != null && searchController.text != "" ?
                    GestureDetector(
                      onTap: () async {
                        if(searchController.text == null || searchController.text == ""){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Message field is empty'),
                          ));
                        }
                        else{
                          setState(() {
                            chat.insert(0, searchController.text);
                            isSender.insert(0,"true");
                            bools = true;
                            text = searchController.text;
                            searchController.clear();
                            _sendMessage();
                          });
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10,top: 20,bottom: 10),
                        child: Container(
                          height: 50,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.indigo.shade700,
                          ),
                          child: const Icon(Icons.arrow_upward_outlined,color: Colors.white,),
                        ),
                      ),
                    ) : const SizedBox(width: 0,height: 0,),
                  ],
                )
              ],
            ),
          );
        }
    );
  }
}
