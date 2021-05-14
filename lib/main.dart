import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine/bloc/get_vessels_bloc.dart';
import 'package:marine/pages/home.dart';
import 'package:marine/pages/list_vessel.dart';
import 'package:easy_localization/easy_localization.dart';

///Definisce il route dell'app
void main() async {
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
    supportedLocales: [Locale('en', 'EN'), Locale('it', 'IT')],
    path: "translations",
    fallbackLocale: Locale('en', 'EN'),
    child: MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',

      theme: ThemeData(
        //TODO LIGHT THEME DATA
      ),
      darkTheme: ThemeData(
        //TODO DARK THEME COLOR
      ),
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
    );
  }
}
