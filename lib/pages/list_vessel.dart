import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marine/bloc/get_vessels_bloc.dart';
import 'package:marine/model/vessel.dart';

class ListVessel extends StatefulWidget {

  @override
  _ListVesselState createState() => _ListVesselState();
}

class _ListVesselState extends State<ListVessel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer(
        bloc: BlocProvider.of<GetVesselsBloc>(context),
        listener: (context, state) {
          if(state is GetVesselsFailure){
            final snackBar = SnackBar(content: Text(state.message));
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
        },
        builder: (context, state) {
          if(state is GetVesselsSucceed)
          return ListView.builder(
              itemCount: state.vessels.length,
              itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Icon(FontAwesomeIcons.ship),
                    title: Text(state.vessels[index].name.isEmpty?'no name':state.vessels[index].name),
                    subtitle: Text("LAT: ${state.vessels[index].latLng.latitude}\nLON: ${state.vessels[index].latLng.longitude}"),
                    trailing: Icon(FontAwesomeIcons.chevronRight),
                    isThreeLine: true,
                    onTap: (){
                      Navigator.of(context).pop(state.vessels[index]);
                    },
                  )
              )
          );
          if(state is GetVesselsLoading)
            return Center(child: CircularProgressIndicator());
          return Container();
        },
      ),
    );
  }
}
