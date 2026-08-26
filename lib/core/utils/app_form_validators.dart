import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/utils/strings_manager.dart';

class AppFormValidators {
  static FormFieldValidator<T> required<T>({String? errorText}) {
    return FormBuilderValidators.required(
      errorText: errorText ?? StringsManager.commonRequired.lang,
    );
  }

  static FormFieldValidator<String> numeric({String? errorText}) {
    return FormBuilderValidators.numeric(
      errorText: errorText ?? 'يجب إدخال رقم صحيح',
    );
  }

  static FormFieldValidator<String> min(num min, {String? errorText}) {
    return FormBuilderValidators.min(
      min,
      errorText: errorText ?? 'القيمة يجب ألا تقل عن $min',
    );
  }

  static FormFieldValidator<String> max(num max, {String? errorText}) {
    return FormBuilderValidators.max(
      max,
      errorText: errorText ?? 'القيمة يجب ألا تتجاوز $max',
    );
  }

  static FormFieldValidator<String> minLength(int length, {String? errorText}) {
    return FormBuilderValidators.minLength(
      length,
      errorText: errorText ?? 'يجب ألا يقل عن $length خانات',
    );
  }

  static FormFieldValidator<String> maxLength(int length, {String? errorText}) {
    return FormBuilderValidators.maxLength(
      length,
      errorText: errorText ?? 'يجب ألا يزيد عن $length خانات',
    );
  }

  static FormFieldValidator<String> email({String? errorText}) {
    return FormBuilderValidators.email(
      errorText: errorText ?? 'البريد الإلكتروني غير صحيح',
    );
  }

  static FormFieldValidator<T> compose<T>(List<FormFieldValidator<T>> validators) {
    return FormBuilderValidators.compose<T>(validators);
  }
}
