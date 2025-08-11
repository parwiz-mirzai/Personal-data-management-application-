import 'package:flutter/material.dart';
import 'package:infogurd/App/View/HomePage/home.dart';

class Botton extends StatelessWidget {
  final String label;
  final VoidCallback press;

  const Botton({super.key, required this.label, required this.press});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return  Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 60,
          width: size.width * .9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color:primaryColor,
          ),
          child: TextButton(
            onPressed: press,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        
      ),
    );
  }
}
