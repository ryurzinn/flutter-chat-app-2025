import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  const Btn({super.key, required this.text, required this.onPressed});

  final String text;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: onPressed(),child: Text(text, style: const TextStyle(color: Color.fromARGB(255, 76, 149, 208))));
  }
}