import 'package:flutter_bloc/flutter_bloc.dart';

class SplashCubit extends Cubit<bool> {
  SplashCubit() : super(false);

  void startSplash() {
    Future.delayed(Duration(seconds: 3), () {
      emit(true);  // Move to next screen after 3 seconds
    });
  }
}
