import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';

class SignUpTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Color? fillColor;
  final Color? labelColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const SignUpTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.validator,
    this.onChanged,
    this.fillColor,
    this.labelColor,
    this.focusedBorderColor,
    this.borderRadius = 12,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final defaultFillColor = fillColor ?? AppColors.cardBackground;
    final defaultLabelColor = labelColor ?? AppColors.textSecondary;
    final defaultFocusedBorderColor = focusedBorderColor ?? AppColors.primary;
    final defaultContentPadding =
        contentPadding ??
        const EdgeInsets.symmetric(vertical: 16, horizontal: 16);

    return TextFormField(
      controller: controller,
      style: TextStyle(color: AppColors.textPrimary, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: defaultLabelColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        fillColor: defaultFillColor,
        filled: true,
        contentPadding: defaultContentPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: defaultFocusedBorderColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorStyle: TextStyle(color: AppColors.primary, fontSize: 12),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
    );
  }
}
