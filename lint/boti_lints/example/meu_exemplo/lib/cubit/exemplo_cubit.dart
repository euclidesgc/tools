import 'dart:developer' as dev;
import 'dart:math';

import 'package:bloc/bloc.dart';

part 'exemplo_state.dart';

class ExemploCubit extends Cubit<ExemploState> {
  ExemploCubit() : super(ExemploInitial());

  /// BAD: emit after async gap, no guard
  Future<void> emitAfterAsyncGap() async {
    emit(ExemploLoading());
    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      // This emit is after an async gap and NOT guarded
      emit(ExemploLoadSuccess('Número: $result'));
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  /// GOOD: emit after async gap, with guard (if isClosed return)
  Future<void> emitWithIsClosedReturnGuard() async {
    emit(ExemploLoading());
    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      // Guard: check if cubit is closed before emitting
      if (isClosed) return;
      emit(ExemploLoadSuccess('Número: $result'));
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  /// GOOD: emit inside if (!isClosed) block
  Future<void> emitWithNotIsClosedBlock() async {
    emit(ExemploLoading());
    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      // Guard: emit only if cubit is not closed
      if (!isClosed) {
        emit(ExemploLoadSuccess('Número: $result'));
      }
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  /// BAD: emit after async gap, guard is after emit (wrong)
  Future<void> emitWithGuardAfterEmit() async {
    emit(ExemploLoading());
    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      // BAD: emit before checking isClosed
      emit(ExemploLoadSuccess('Número: $result'));
      if (isClosed) return;
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  /// BAD: emit after async gap, guard is unrelated
  Future<void> emitWithUnrelatedGuard() async {
    emit(ExemploLoading());
    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      // BAD: unrelated guard (not isClosed)
      if (someOtherCondition()) return;
      emit(ExemploLoadSuccess('Número: $result'));
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  /// GOOD: emit before async gap
  Future<void> emitBeforeAsyncGap() async {
    emit(ExemploLoading());
    try {
      emit(ExemploLoadSuccess('Número: 42'));
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      dev.log('Número carregado: $result');
      // This emit is before the async gap, so it's always safe
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  /// BAD: emit after async gap, inside unrelated if
  Future<void> emitInsideUnrelatedIf() async {
    emit(ExemploLoading());
    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );
      // BAD: unrelated if (not isClosed)
      if (someOtherCondition()) {
        emit(ExemploLoadSuccess('Número: $result'));
      }
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  bool someOtherCondition() => false;
}
