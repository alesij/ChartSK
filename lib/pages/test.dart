import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marine/bloc/get_vessels_bloc.dart';
import 'package:marine/model/vessel.dart';

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  /*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: FutureBuilder(
            future: VesselRepo().createVessels(),
            builder: (context, snapshot) {
              if(snapshot.hasData){
                return ListView.builder(itemBuilder: (context, index) {
                  Vessel vessel = snapshot.data[index];
                  return Text(vessel.id);
                },itemCount: snapshot.data.length);
              }else{
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            child: Center(
              child: BlocConsumer(
                bloc: BlocProvider.of<GetVesselsBloc>(context),
                builder: (context, state) {
                  if (state is GetVesselsLoading)
                    return CircularProgressIndicator();
                  else if (state is GetVesselsSucceed)
                    return ListView.builder(itemBuilder: (context, index) {
                      Vessel vessel = state.vessels[index];
                      return Text(vessel.id);
                    }, itemCount: state.vessels.length);
                  return Container();
                }, listener: (context, state) {
                if (state is GetVesselsFailure) {
                  final snackBar = SnackBar(content: Text(state.message));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              },
              ),
            )
        )
    );
  }
}
