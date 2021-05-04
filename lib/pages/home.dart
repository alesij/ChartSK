import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:marine/model/vessel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:web_socket_channel/io.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  List<Vessel> vessels = [];
  Vessel myVessel;
  final channel = IOWebSocketChannel.connect('ws://demo.signalk.org/signalk/v1/stream?subscribe=none');



  Home({Key key, @required this.vessels}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Marker> _markers = [];

  Future<void> addMarkers() async {
    for (int i = 0; i < widget.vessels.length; i++) {
      if(i==0){
         _markers.add(
            Marker(
                width: 40.0,
                height: 40.0,
                point: widget.vessels[i].latLng,
                builder: (ctx) =>
                new Container(
                    child: Transform.rotate(
                      angle: widget.vessels[i].courseOverGroundTrue,
                      child: Image.asset('assets/icona.png',),
                    )
                )
            )
        );
      }else{
        _markers.add(Marker(
            width: 40.0,
            height: 40.0,
            point: this.widget.vessels[i].latLng,
            builder: (ctx) =>
            new Container(
              child: Transform.rotate(
                angle: widget.vessels[i].courseOverGroundTrue,
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
    var msg = {
        "context": "vessels.*",
        "subscribe": [
          {
            "path": "navigation.position",
            "period": 1000,
            "format": "delta",
            "policy": "ideal",
            "minPeriod": 200
          },
          {
            "path": "navigation.speedOverGround",
            "period": 1000,
            "format": "delta",
            "policy": "ideal",
            "minPeriod": 200
          },
          {
            "path": "navigation.courseOverGroundTrue",
            "period": 1000,
            "format": "delta",
            "policy": "ideal",
            "minPeriod": 200
          }
        ]
    };

    var jsonString = json.encode(msg);
    widget.channel.sink.add(jsonString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
          stream: widget.channel.stream,
          builder: (context,snapshot) {
            if(snapshot.hasData && !snapshot.hasError){
            Map data = jsonDecode(snapshot.data);
            //print(data['updates'][0]['values'][0]['path']);
           //print(data['updates'][0]['values'][0]['value']);
            String id = data['context'].toString().substring(8);
            print(id);
            String path=data['updates'][0]['values'][0]['path'];
            for(int i=0;i<widget.vessels.length;i++){
              if(widget.vessels[i].id == id){
                if(path=='navigation.speedOverGround'){
                  try {
                    widget.vessels[i].speedOverGround =
                    data['updates'][0]['values'][0]['value'];
                    _markers[i] = Marker(width: 40.0,
                        height: 40.0,
                        point: this.widget.vessels[i].latLng,
                        builder: (ctx) =>
                        new Container(
                          child: Transform.rotate(
                            angle: widget.vessels[i].courseOverGroundTrue,
                            child: Image.asset('assets/icona.png'),
                          ),
                        ));
                  }catch(e,s){
                    print("impossibile aggiornare velocità->$e $s");
                  }
                }
                else if(path=='navigation.courseOverGroundTrue'){
                  try {
                    //necessario perché 0 lo legget come int
                    if(data['updates'][0]['values'][0]['value'] == 0){
                      widget.vessels[i].courseOverGroundTrue = 0.0;
                    }
                    else {
                      widget.vessels[i].courseOverGroundTrue = data['updates'][0]['values'][0]['value'];
                    }
                    _markers[i] = Marker(width: 40.0,
                        height: 40.0,
                        point: this.widget.vessels[i].latLng,
                        builder: (ctx) =>
                        new Container(
                          child: Transform.rotate(
                            angle: widget.vessels[i].courseOverGroundTrue,
                            child: Image.asset('assets/icona.png'),
                          ),
                        ));
                  }catch (e,s){
                    print("impossibile aggiornare direzione->$e $s");

                  }
                }
                else{
                  try {
                    LatLng latLng = new LatLng(
                        data['updates'][0]['values'][0]['value']['latitude'],
                        data['updates'][0]['values'][0]['value']['longitude']
                    );
                    widget.vessels[i].latLng = latLng;
                    _markers[i].point.latitude = latLng.latitude;
                    _markers[i].point.longitude = latLng.longitude;
                  }catch (e,s){
                    print("impossibile aggiornare position->$e $s");
                  }
                }
              }
              else{
                //add vessel and marker
              }
            }

            }

            return FlutterMap(
              options: MapOptions(
                center: _markers[0].point,
                zoom: 13.0,
              ),
              children: [],
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
            );
          },
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
