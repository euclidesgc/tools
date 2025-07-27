import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'exemplo_state.dart';

class ExemploCubit extends Cubit<ExemploState> {
  ExemploCubit() : super(ExemploInitial());

  Future<void> metodoComErro() async {
    // Emite o estado de carregamento
    emit(ExemploLoading());
    try {
      // Simula uma operação assíncrona que pode falhar
      final result = await Future.delayed(
        Duration(seconds: 3),
        () => Random(1).nextInt(10),
      );

      emit(ExemploLoadSuccess('Número: $result'));
    } catch (e) {
      emit(ExemploError('Erro ao carregar o número!'));
    }
  }
}
