import 'package:dartz/dartz.dart';
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
  } catch (_) {
    return const Left(GeneralFailure(message: 'unexpected_error'));
  }
}
