part of 'exemplo_cubit.dart';

sealed class ExemploState {}

final class ExemploInitial extends ExemploState {}

final class ExemploLoading extends ExemploState {}

final class ExemploLoadSuccess extends ExemploState {
  final String data;

  ExemploLoadSuccess(this.data);
}

final class ExemploError extends ExemploState {
  final String message;

  ExemploError(this.message);
}
