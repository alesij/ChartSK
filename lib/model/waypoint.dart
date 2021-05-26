import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart';
import 'package:marine/utility/dragmarker.dart';

class Waypoint{
  String label;
  LatLng point;
  DragMarker marker;

  Waypoint({@required this.point, this.label}) {
    marker = DragMarker(point: this.point);

  }
}