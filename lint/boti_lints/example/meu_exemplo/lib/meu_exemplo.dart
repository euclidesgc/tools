import 'package:bloc/bloc.dart';

class MyBloc extends Bloc<int, int> {
  MyBloc() : super(0);

  Future<void> loadData(Emitter<int> emit) async {
    await Future.delayed(Duration(seconds: 1));
    emit(1); // Deve acusar!
  }
}
