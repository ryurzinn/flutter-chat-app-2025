import 'package:chat/helpers/mostrar_alerta.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/widgets/btn.dart';
import 'package:chat/widgets/custom_input.dart';
import 'package:chat/widgets/labels.dart';
import 'package:chat/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: const Color(0xffF2F2F2),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Logo(titulo: 'Messenger',),
              
                  _Form(),
              
                  const Labels(ruta: "register", label1: 'No tienes cuenta?', label2: 'Crea una ahora!',),
              
                  const Text("Terminos y condiciones de uso", style: TextStyle(fontWeight: FontWeight.w300))
                  ],
              ),
            ),
          ),
        ));
  }
}



class _Form extends StatefulWidget {
  @override
  State<_Form> createState() => __FormState();
}

class __FormState extends State<_Form> {

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context);

    return Container(
      margin: const EdgeInsets.only(top: 40),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      // ignore: prefer_const_constructors
      child: Column(
        children: [
          
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            keyboardType: TextInputType.emailAddress,
            textController: emailCtrl,
            ),
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            isPassword: true,
            ),

          //TODO: Crear boton
          Btn(
            text: 'Iniciar sesion', onPressed: authService.autenticando 
            ? () => {} 
            : () async{
              FocusScope.of(context).unfocus();
              final loginOK = await  authService.login(emailCtrl.text.trim(), passCtrl.text.trim());

              if(loginOK == true){
                //TODO:  Conectar  a nuestro socket server
                if(context.mounted){
                  Navigator.pushReplacementNamed(context, 'usuarios');
                }
              }else{
                // Mostrar alerta
                if(context.mounted){
                  mostrarAlerta(context, 'Login incorrecto', 'Revise sus credenciales');
                }   
              }
          }),
        ],
      ),
    );
  }
}

