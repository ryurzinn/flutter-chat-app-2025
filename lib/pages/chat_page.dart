import 'dart:io';

import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chat_service.dart';
import 'package:chat/services/socket_service.dart';
import 'package:chat/widgets/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin{

  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  late ChatService chatService;
  late SocketService socketService;
  late AuthService authService;

  List<ChatMessage> _messages = [];

  bool _estaEscribiendo = false;

  @override
  void initState(){
    super.initState();
    
    chatService = Provider.of<ChatService>(context, listen: false);
    socketService = Provider.of<SocketService>(context, listen: false);
    authService = Provider.of<AuthService>(context, listen: false);

    socketService.socket.on('mensaje-personal', _escucharMensaje);
  }

  void _escucharMensaje(dynamic payload) {
    ChatMessage message = ChatMessage(
      texto: payload['mensaje'],
      uid: payload['de'],
      animationController: AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
    );
    setState(() {
      _messages.insert(0, message);
    });
    message.animationController.forward();
  }


  @override
  Widget build(BuildContext context) {

    final nombreUsuario = chatService.usuarioPara;

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
              child: Text(nombreUsuario.nombre.substring(0,2), style: TextStyle(fontSize: 12)),
            ),
            const SizedBox(height: 3),
            Text(nombreUsuario.nombre, style: TextStyle(color: Colors.black87, fontSize: 12))
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

socketService.emit('mensaje-personal', {
  'de' : authService.usuario.uid,
  'para' :  chatService.usuarioPara.uid,
  'mensaje' : texto
});

  void dispose(){
    for(ChatMessage message in _messages){
      message.animationController.dispose();
    }
    socketService.socket.off('mensaje-personal');
    super.dispose();
  }
}
}
