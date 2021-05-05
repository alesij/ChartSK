import 'package:flutter/material.dart';
import 'package:marine/model/vessel.dart';

class VesselWidget extends StatefulWidget {
  Vessel vessel;
  String icon;

  VesselWidget({Key key,@required this.vessel,@required this.icon}) : super(key: key);

  @override
  _VesselWidgetState createState() => _VesselWidgetState();
}

class _VesselWidgetState extends State<VesselWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Text(widget.vessel.name ?? '', style: TextStyle(fontSize: 10),maxLines: 1, overflow: TextOverflow.visible),
          ),
          Container(
            child: Transform.rotate(
              angle: widget.vessel.courseOverGroundTrue,
              child: Image.asset(widget.icon),
            ),
          ),
        ]
    );
  }
}
