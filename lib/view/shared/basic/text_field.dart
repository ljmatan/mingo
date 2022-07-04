import 'package:flutter/material.dart';

class MinGOTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool obscured;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int numberOfLines;
  final bool bordered;

  const MinGOTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscured = false,
    this.validator,
    this.keyboardType,
    this.numberOfLines = 1,
    this.bordered = false,
  });

  @override
  State<MinGOTextField> createState() => _MinGOTextFieldState();
}

class _MinGOTextFieldState extends State<MinGOTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.obscured,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: widget.bordered
              ? const BorderSide(
                  color: Color(0xffE7E7E7),
                )
              : BorderSide.none,
        ),
        hintText: widget.label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      ),
      minLines: widget.numberOfLines,
      maxLines: widget.numberOfLines,
      validator: widget.validator,
    );
  }
}
