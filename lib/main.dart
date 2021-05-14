import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine/bloc/get_vessels_bloc.dart';
import 'package:marine/pages/home.dart';
import 'package:marine/pages/list_vessel.dart';

///Definisce il route dell'app
void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      ///BlocProvider viene utilizzato per fornire il bloc alle due pages
      '/': (context) =>
          BlocProvider(
            create: (context) => GetVesselsBloc()..add(GetVessels()),
            child: Home(),
          ),
      '/list': (context) =>
          BlocProvider(
            create: (context) => GetVesselsBloc()..add(GetVessels()),
            child: ListVessel(),
          ),
    },
  ));
}