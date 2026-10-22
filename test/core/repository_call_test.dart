import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/core/error/failures.dart';
import 'package:baseet/core/error/repository_call.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps expected validation errors at the repository boundary', () async {
    final result = await repositoryCall<void>(
      () => throw const ValidationException(message: 'invalid_value'),
    );

    expect(result, const Left(ValidationFailure(message: 'invalid_value')));
  });

  test('does not expose unexpected exception details', () async {
    final result = await repositoryCall<void>(
      () => throw Exception('private value'),
    );

    expect(result, const Left(GeneralFailure(message: 'unexpected_error')));
  });
}
