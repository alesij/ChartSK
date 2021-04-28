import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:marine/model/vessel.dart';
import 'package:flutter_map/flutter_map.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  List<Vessel> vessels = [];
  Vessel myVessel;

  List<Marker> _markers = [];

  Home({Key key, @required this.vessels}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  void addMarkers() {

    for (int i = 0; i < widget.vessels.length; i++) {
      print('$i: ${widget.vessels[i].id} - ${widget.vessels[i].latLng.latitude} - ${widget.vessels[i].latLng.longitude}');

      if(i==0){
        widget._markers.add(
            Marker(
                width: 80.0,
                height: 80.0,
                point: widget.vessels[i].latLng,
                builder: (ctx) =>
                new Container(
                    child: Icon(
                      Icons.location_on,
                      color: Colors.red[700],
                      size: 30,
                    )
                )
            )
        );
      }else{
        this.widget._markers.add(Marker(
            width: 80.0,
            height: 80.0,
            point: this.widget.vessels[i].latLng,
            builder: (ctx) =>
            new Container(
                child: Icon(
                  Icons.location_on,
                  color: Colors.green[700],
                  size: 30,
                )
            )
        ));
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
        center: widget._markers[0].point,
        zoom: 13.0,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a','b','c']
        ),
        MarkerLayerOptions(
          markers: widget._markers,
        )
      ],
    ),
      floatingActionButton: FloatingActionButton(
      onPressed: (){},
      child: Icon(Icons.gps_fixed_rounded),
    )
    );
  }
}