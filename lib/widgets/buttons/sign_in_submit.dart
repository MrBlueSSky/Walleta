import 'package:flutter/material.dart';
import 'package:walleta/themes/app_colors.dart';

class SignInSubmitButton extends StatelessWidget {
  final bool isLoading;
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final List<Color>? gradientColors;
  final Color? shadowColor;
  final BorderRadius? borderRadius;

  const SignInSubmitButton({
    super.key,
    required this.isLoading,
    required this.text,
    required this.onPressed,
    this.height = 54,
    this.gradientColors,
    this.shadowColor,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final defaultGradientColors =
        gradientColors ??
        [AppColors.primary, AppColors.primary.withOpacity(0.8)];

    final defaultShadowColor =
        shadowColor ?? AppColors.primary.withOpacity(0.3);
    final defaultBorderRadius = borderRadius ?? BorderRadius.circular(12);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: defaultBorderRadius,
        gradient: LinearGradient(
          colors: defaultGradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: defaultShadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: defaultBorderRadius),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textPrimary,
                  ),
                )
                : Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                    color: AppColors.textPrimary,
                  ),
                ),
      ),
    );
  }
}
