import 'package:flutter/material.dart';

class AddCourseTextField extends StatefulWidget {
  final Color selectedColor;
  final TextEditingController controller;
  final String labelText;
  final int maxLines;
  final Icon icon;

  const AddCourseTextField({
    super.key,
    required this.selectedColor,
    required this.controller,
    required this.labelText,
    required this.maxLines,
    required this.icon,
  });

  @override
  State<AddCourseTextField> createState() => _AddCourseTextFieldState();
}

class _AddCourseTextFieldState extends State<AddCourseTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: widget.labelText,
        floatingLabelStyle: TextStyle(color: widget.selectedColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: widget.selectedColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.selectedColor.withOpacity(0.5)),
        ),
        prefixIcon: widget.icon,
      ),
      maxLines: widget.maxLines,
    );
  }
}
