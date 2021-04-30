import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:marine/model/vessel.dart';
import 'package:flutter_map/flutter_map.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  List<Vessel> vessels = [];
  Vessel myVessel;

  Home({Key key, @required this.vessels}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Marker> _markers = [];

  void addMarkers() {

    for (int i = 0; i < widget.vessels.length; i++) {
      //print('$i: ${widget.vessels[i].id} - ${widget.vessels[i].latLng.latitude} - ${widget.vessels[i].latLng.longitude}');

      if(i==0){
        _markers.add(
            Marker(
                width: 80.0,
                height: 80.0,
                point: widget.vessels[i].latLng,
                builder: (ctx) =>
                new Container(
                    child: Transform.rotate(
                      angle: widget.vessels[i].directionInRadians,
                      child: Image.asset(
                          'assets/icona.png',
                          scale: 0.1,
                          width: 50,
                          height: 50),
                    )
                )
            )
        );
      }else{
        _markers.add(Marker(
            width: 80.0,
            height: 80.0,
            point: this.widget.vessels[i].latLng,
            builder: (ctx) =>
            new Container(
                child: Transform.rotate(
                  angle: widget.vessels[i].directionInRadians,
                  child: Image.asset('assets/icona.png'),
                  ),
                )
            )
        );
      }
    }
  }

  @override void initState() {
    super.initState();
    addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FlutterMap(
      options: MapOptions(
        center: _markers[0].point,
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a','b','c'],
        ),
        MarkerLayerOptions(
          markers: _markers,
        ),
        PolylineLayerOptions(
          polylines: [Polyline(
            points: [widget.vessels[0].latLng,widget.vessels[0].nextPosition(5)]
          ),
          ]

        ),
      ],
    ),

      floatingActionButton: FloatingActionButton(
      onPressed: (){
        // Automatically center the location marker on the map when location updated until user interact with the map.
        setState(() => {});},
        child: Icon(Icons.gps_fixed_rounded),
    )
    );
  }
}
