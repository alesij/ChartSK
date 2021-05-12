import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine/bloc/get_vessels_bloc.dart';
import 'package:marine/pages/loading.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) =>
          BlocProvider(
            create: (context) => GetVesselsBloc()..add(GetVessels()),
            child: Loading(),
          ),
    },
  ));
}