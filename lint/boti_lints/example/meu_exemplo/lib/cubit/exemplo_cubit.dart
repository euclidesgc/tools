import 'dart:math';

import 'package:bloc/bloc.dart';

part 'exemplo_state.dart';

class ExemploCubit extends Cubit<ExemploState> {
  ExemploCubit() : super(ExemploInitial());

  Future<void> meuMetodoComErro() async {
    emit(ExemploLoading());

    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );

      emit(ExemploLoadSuccess('Número: $result'));
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }

  Future<void> meuMetodoSemErro() async {
    emit(ExemploLoading());

    try {
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );

      if (isClosed) return;
      emit(ExemploLoadSuccess('Número: $result'));

      if (!isClosed) {
        emit(ExemploLoadSuccess('Número: $result'));
      }
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }
}
