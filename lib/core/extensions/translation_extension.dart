import 'package:easy_localization/easy_localization.dart';

extension StringTranslationExtension on String {
  String get lang => tr(this);

  String trArgs({List<String>? args, Map<String, String>? namedArgs}) {
    return tr(this, args: args, namedArgs: namedArgs);
  }
}
