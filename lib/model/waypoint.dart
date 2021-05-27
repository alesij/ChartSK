import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong/latlong.dart';
import 'package:marine/utility/dragmarker.dart';
import 'package:easy_localization/easy_localization.dart';

class Waypoint{
  String label;
  LatLng point;
  DragMarker marker;
  BuildContext context;

  Waypoint({@required this.point, this.label,this.context}) {
    marker = DragMarker(point: this.point,builder: (context) => Icon(FontAwesomeIcons.mapMarkerAlt,size: 30,color: Colors.orange), onTap: (point) =>
      showDialog(
        context: context,
          builder: (BuildContext context) {
            return
              AlertDialog(
                  title: Text(this.label),
                  content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("Lat: ${point.latitude.toStringAsFixed(4)}"),
                          Text("Lat: ${point.longitude.toStringAsFixed(4)}"),
                        ],
                      )
                  ),
                  actions: <Widget>[

                    TextButton(
                      child: Text('close').tr(),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),

                  ]
              );
    },));
  }
}