import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomInputField extends StatelessWidget {
  CustomInputField({
    super.key,
    required this.inputController,
    required this.labelText,
    required this.hint,
    required this.textInputType,
  });

  TextEditingController inputController;
  Text labelText;
  String hint;
  TextInputType textInputType;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: textInputType,
        style: TextStyle(color: Colors.white),
        controller: inputController,
        decoration: InputDecoration(
            label: labelText,
            hintText: hint,
            labelStyle: TextStyle(color: Colors.white),
            hintStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.purple))),
      ),
    );
  }
}
