import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import 'package:baseet/core/error/exceptions.dart';
import 'package:baseet/core/error/failures.dart';

Future<Either<Failure, T>> repositoryCall<T>(Future<T> Function() call) async {
  try {
    final result = await call();
    return Right(result);
  } on ServerException catch (e) {
    return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
  } on CacheException catch (e) {
    return Left(CacheFailure(message: e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(message: e.message));
  } on DatabaseException catch (e) {
    if (e.isUniqueConstraintError()) {
      return const Left(
          ValidationFailure(message: 'validation.duplicate_record'));
    }
    return const Left(CacheFailure(message: 'validation.storage_error'));
  } catch (e) {
    return Left(GeneralFailure(message: e.toString()));
  }
}
