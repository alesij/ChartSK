import 'package:flutter/material.dart';
import 'package:marine/model/vessel.dart';

///Definisce il modo in cui vengono mostrati i [Vessel] sulla mappa
class VesselWidget extends StatefulWidget {
  Vessel vessel;
  String icon;
  double width;
  double height;
  VesselWidget({Key key,@required this.vessel,@required this.icon,@required this.width,@required this.height}) : super(key: key);

  @override
  _VesselWidgetState createState() => _VesselWidgetState();
}

class _VesselWidgetState extends State<VesselWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Transform.rotate(
        angle: widget.vessel.courseOverGroundTrue,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.vessel.name ?? '', style: TextStyle(fontSize: 10),maxLines: 1, overflow: TextOverflow.visible),
              Image.asset(widget.icon,width: widget.width, height: widget.height),
          ]
      ))
     // ),
    );
  }
}
