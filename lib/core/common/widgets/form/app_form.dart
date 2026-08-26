import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class AppForm extends StatelessWidget {
  final GlobalKey<FormBuilderState> formKey;
  final Widget child;
  final Map<String, dynamic> initialValue;
  final VoidCallback? onChanged;
  final AutovalidateMode? autovalidateMode;
  final bool enabled;

  const AppForm({
    super.key,
    required this.formKey,
    required this.child,
    this.initialValue = const <String, dynamic>{},
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return FormBuilder(
      key: formKey,
      initialValue: initialValue,
      onChanged: onChanged,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      child: child,
    );
  }
}
