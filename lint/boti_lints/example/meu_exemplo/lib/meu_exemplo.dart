import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

  // Exemplo que DEVE acusar o lint
  Future<void> metodoComErro(Emitter<int> emit) async {
    await Future.delayed(Duration(seconds: 1));
    emit(1); // Deve acusar!
  }

  // Exemplo que NÃO DEVE acusar o lint
  Future<void> metodoCorreto(Emitter<int> emit) async {
    await Future.delayed(Duration(seconds: 1));
    if (this.isClosed) return;
    emit(1); // Não deve acusar
  }

  // Exemplo totalmente síncrono (não deve acusar)
  void metodoSincrono(Emitter<int> emit) {
    emit(1);
    emit(2);
  }
}
