import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class AppSectionLabel extends StatelessWidget {
  const AppSectionLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.text,
      ),
    );
  }
}

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.contentPadding,
    this.labelStyle,
    this.hintStyle,
    this.prefixIconSize,
    this.borderSideNone = true,
    this.focusedBorderWidth = 1.4,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int minLines;
  final int maxLines;
  final bool obscureText;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final double? prefixIconSize;
  final bool borderSideNone;
  final double focusedBorderWidth;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      enabled: enabled,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.text,
      ),
      decoration: appFormFieldDecoration(
        label: label,
        hint: hint,
        prefixIcon: icon,
        suffixIcon: suffixIcon,
        contentPadding: contentPadding,
        labelStyle: labelStyle,
        hintStyle: hintStyle,
        prefixIconSize: prefixIconSize,
        borderSideNone: borderSideNone,
        focusedBorderWidth: focusedBorderWidth,
      ),
    );
  }
}

class AppPasswordField extends StatelessWidget {
  const AppPasswordField({
    super.key,
    required this.controller,
    required this.label,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.enabled,
    this.textInputAction,
    this.onFieldSubmitted,
    this.focusedBorderWidth = 1.4,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final FormFieldValidator<String>? validator;
  final bool? enabled;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final double focusedBorderWidth;

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: controller,
      label: label,
      icon: Icons.lock_outline,
      obscureText: obscureText,
      enabled: enabled,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      focusedBorderWidth: focusedBorderWidth,
      suffixIcon: IconButton(
        onPressed: enabled == false ? null : onToggleVisibility,
        icon: Icon(
          obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textMute,
        ),
        tooltip: obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
    this.icon = Icons.tune_rounded,
    this.hint,
    this.contentPadding,
    this.focusedBorderWidth = 1.4,
    this.borderSideNone = true,
    this.dropdownIcon,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelBuilder;
  final ValueChanged<T?>? onChanged;
  final IconData icon;
  final String? hint;
  final EdgeInsetsGeometry? contentPadding;
  final double focusedBorderWidth;
  final bool borderSideNone;
  final Widget? dropdownIcon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: appFormFieldDecoration(
        label: label,
        hint: hint,
        prefixIcon: icon,
        contentPadding: contentPadding,
        focusedBorderWidth: focusedBorderWidth,
        borderSideNone: borderSideNone,
      ),
      icon: dropdownIcon,
      items: values
          .map(
            (T value) => DropdownMenuItem<T>(
              value: value,
              child: Text(labelBuilder(value)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    required this.value,
    required this.onTap,
    required this.label,
    this.icon = Icons.event_outlined,
    this.inputDecorator = false,
    this.hint,
    this.contentPadding,
    this.focusedBorderWidth = 1.4,
    this.borderSideNone = true,
  });

  final DateTime value;
  final VoidCallback? onTap;
  final String label;
  final IconData icon;
  final bool inputDecorator;
  final String? hint;
  final EdgeInsetsGeometry? contentPadding;
  final double focusedBorderWidth;
  final bool borderSideNone;

  @override
  Widget build(BuildContext context) {
    if (inputDecorator) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: appFormFieldDecoration(
            label: label,
            hint: hint ?? label,
            prefixIcon: icon,
            contentPadding: contentPadding,
            focusedBorderWidth: focusedBorderWidth,
            borderSideNone: borderSideNone,
          ),
          child: Text(_formatDate(value), style: _fieldTextStyle),
        ),
      );
    }

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, color: AppColors.textMute),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$label: ${_formatDate(value)}',
                  style: _fieldTextStyle,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textMute,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration appFormFieldDecoration({
  required String label,
  String? hint,
  required IconData prefixIcon,
  Widget? suffixIcon,
  EdgeInsetsGeometry? contentPadding,
  TextStyle? labelStyle,
  TextStyle? hintStyle,
  double? prefixIconSize,
  bool borderSideNone = true,
  double focusedBorderWidth = 1.4,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: Icon(
      prefixIcon,
      size: prefixIconSize,
      color: AppColors.textMute,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.surface,
    contentPadding: contentPadding,
    labelStyle: labelStyle,
    hintStyle: hintStyle,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: borderSideNone ? BorderSide.none : const BorderSide(),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: AppColors.primary,
        width: focusedBorderWidth,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: AppColors.red, width: focusedBorderWidth),
    ),
  );
}

String _formatDate(DateTime value) {
  final String month = value.month.toString().padLeft(2, '0');
  final String day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

const TextStyle _fieldTextStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: AppColors.text,
);
