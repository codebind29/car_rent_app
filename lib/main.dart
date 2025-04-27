import 'package:car_rent/firebase_options.dart';
import 'package:car_rent/injection_container.dart';
import 'package:car_rent/presentation/bloc/car_bloc.dart';
import 'package:car_rent/presentation/bloc/car_event.dart';
import 'package:car_rent/presentation/pages/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform
  );
  initInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CarBloc>(
          create: (context) => getIt<CarBloc>()..add(LoadCars()),
        ),
      ],
      child: MaterialApp(
        title: 'Car Rental App',
        debugShowCheckedModeBanner: false,
        home:  SplashScreen(),
      ),
    );
  }
}