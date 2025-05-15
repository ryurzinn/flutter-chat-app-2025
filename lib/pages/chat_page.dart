import 'dart:io';

import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin{

  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  List<ChatMessage> _messages = [];

  bool _estaEscribiendo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 1,
        title: Column(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              maxRadius: 15,
              child: const Text('Te', style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 3),
            const Text('Melissa Flores', style: TextStyle(color: Colors.black87, fontSize: 12))
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) => _messages[i],
                itemCount: _messages.length,
                reverse: true,
              )
            ),
            const Divider(height: 1,),

            Container(
              color: Colors.white,
              child: _inputChat(),
            )
          ],
        ),
      ),
    );
  }

Widget _inputChat(){

  return SafeArea(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmit,
              onChanged: (texto){
                setState(() {
                  if(texto.trim().length > 0){
                    _estaEscribiendo = true;
                  }else{
                    _estaEscribiendo = false;
                  }
                });
              },
              decoration: const InputDecoration.collapsed(hintText: 'Enviar mensaje'),
              focusNode: _focusNode,
            ),
          ),
          //Boton de enviar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Platform.isIOS
            ? CupertinoButton(
              child: const Text('Enviar'),
              onPressed: _estaEscribiendo 
                  ? () => _handleSubmit(_textController.text.trim())
                  : null,
            )
            : Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconTheme(
                data: IconThemeData(color: Colors.blue[400]),
                child: IconButton(
                  onPressed: _estaEscribiendo 
                  ? () => _handleSubmit(_textController.text.trim())
                  : null,
                  icon: const Icon(Icons.send),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                ),
              ),
            )
          )
          
        ],
      ),
    )
  );
}
_handleSubmit(String texto){

  if(texto.length == 0) return;

  final newMessage  = ChatMessage(
    texto: texto,
    uid: '123',
    animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 200)),
    );
  _messages.insert(0, newMessage);
  newMessage.animationController.forward();

  _textController.clear();
  _focusNode.requestFocus();
setState(() {
  _estaEscribiendo = false;
});

  void dispose(){
    //TODO off del socket

    for(ChatMessage message in _messages){
      message.animationController.dispose();
    }
    super.dispose();
  }
}
}
