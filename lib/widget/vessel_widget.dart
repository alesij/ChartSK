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
    return /*GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                    AlertDialog(
                        title: Text('${widget.vessel.name}'),
                        content: Container(),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              setState(() {});
                              Navigator.of(context).pop();
                            },
                          ),
                        ]
                    );
                });
          },
      child: */Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              child: Text(widget.vessel.name ?? '', style: TextStyle(fontSize: 10),maxLines: 1, overflow: TextOverflow.visible),
            ),
            Container(
              child: Transform.rotate(
                angle: widget.vessel.courseOverGroundTrue,
                child: Image.asset(widget.icon,width: widget.width, height: widget.height),
              ),
            ),
          ]
     // ),
    );
  }
}
