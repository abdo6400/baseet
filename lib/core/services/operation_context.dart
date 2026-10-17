import 'package:baseet/core/utils/uuid_generator.dart';

abstract class OperationContext {
  DateTime now();
  String newId(String prefix);
}

class SystemOperationContext implements OperationContext {
  const SystemOperationContext();
  @override
  DateTime now() => DateTime.now();
  @override
  String newId(String prefix) => UuidGenerator.generate(prefix);
}
