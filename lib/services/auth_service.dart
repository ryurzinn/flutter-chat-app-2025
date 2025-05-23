import 'dart:convert';

import 'package:chat/global/environment.dart';
import 'package:chat/models/login_response.dart';
import 'package:chat/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService with ChangeNotifier{

  late Usuario usuario;
  bool _autenticando = false;

//Crear storage
  final _storage = const FlutterSecureStorage();

  bool get autenticando => _autenticando;

  set autenticando(bool valor){
    _autenticando = valor;
    notifyListeners();
  }

  // Getters  del  token de forma estatica
  static Future<String?> getToken() async {
    final _storage = const FlutterSecureStorage();
    final token = await _storage.read(key: 'token');
    return token;
  }

  static Future<void> deleteToken() async {
    final _storage = const FlutterSecureStorage();
    await _storage.delete(key: 'token');
    
  }

  Future<bool>login(String email, String password) async{

    autenticando = true;

    final data ={
      'email' : email,
      'password' : password
    };

    final uri = Uri.parse('${Environment.apiUrl}/login');

    final resp = await http.post(uri, 
    body: jsonEncode(data),
    headers: {
      'Content-Type' : 'application/json'
    });

  
    print(resp.body);
    autenticando = false;
  
    if(resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;

      // TODO guardar el token en un lugar seguro
      await _guardarToken(loginResponse.token);

      return true;
    }else{
      return false;
    }

  }

  Future<bool>register(String nombre ,String email, String password) async{

    autenticando = true;

    final data ={
      'nombre' : nombre,
      'email' : email,
      'password' : password
    };

    final uri = Uri.parse('${Environment.apiUrl}/login/new');

    final resp = await http.post(uri, 
    body: jsonEncode(data),
    headers: {
      'Content-Type' : 'application/json'
    });

  
    print(resp.body);
    autenticando = false;
  
    if(resp.statusCode == 200){
      final loginResponse = loginResponseFromJson(resp.body);
      usuario = loginResponse.usuario;

      // TODO guardar el token en un lugar seguro
      await _guardarToken(loginResponse.token);

      return true;
    }else{
      final respBody = jsonDecode(resp.body);
      return respBody['msg'];
    }

  }

  Future _guardarToken(String token) async {
    return await _storage.write(key: 'token', value: token);
  }

  Future logout() async {
    return await _storage.delete(key: 'token');
  }

}