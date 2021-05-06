import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong/latlong.dart';
import 'package:marine/model/vessel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:marine/widget/vessel_widget.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  List<Vessel> vessels = [];
  final channel = WebSocketChannel.connect(Uri.parse('ws://demo.signalk.org/signalk/v1/stream?subscribe=none'));


  Home({Key key, @required this.vessels}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Marker> _markers = [];
  double positionPrevision=0;


  Future<void> createMarkers() async {
    for (int i = 0; i < widget.vessels.length; i++) {
      if(i==0){
         _markers.add(
            Marker(
                width: 70.0,
                height: 70.0,
                point: widget.vessels[i].latLng,
                builder: (ctx) => VesselWidget(vessel: widget.vessels[i], icon: 'assets/ship_red.png',width: 50,height: 50)
            )
        );
      }else{
        _markers.add(Marker(
            width: 70.0,
            height: 70.0,
            point: this.widget.vessels[i].latLng,
            builder: (ctx) => VesselWidget(vessel: widget.vessels[i], icon: 'assets/ais_active.png',width: 25,height: 25)
            )
        );
      }
    }
  }

  @override void initState() {
    super.initState();
    createMarkers();
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

  void updateMarker(index){
    if(index==0) {
      _markers[index] = Marker(
          width: 70.0,
          height: 70.0,
          point: widget.vessels[index].latLng,
          builder: (ctx) => VesselWidget(vessel: widget.vessels[index], icon: 'assets/ship_red.png',width: 50,height: 50)
      );
    }
    else{
      _markers[index] = Marker(
          width: 70.0,
          height: 70.0,
          point: widget.vessels[index].latLng,
          builder: (ctx) => VesselWidget(vessel: widget.vessels[index], icon: 'assets/ais_active.png',width: 25,height: 25)
      );
    }
  }

  //modifica valori del vessel
  void readWS(snapshot){
    if(snapshot.hasData && !snapshot.hasError){
      Map data = jsonDecode(snapshot.data);
      String id = data['context'].toString().substring(8);
      String path=data['updates'][0]['values'][0]['path'];
      for(int i=0;i<widget.vessels.length;i++){
        if(widget.vessels[i].id == id){
          print('modificato vessel $i ovvero ${widget.vessels[i].name}, id=${widget.vessels[i].id}');
          if(path=='navigation.speedOverGround'){
            try {
              if(data['updates'][0]['values'][0]['value'] == 0){
                print('modifica speed overground da ${widget.vessels[i].speedOverGround} a ${data['updates'][0]['values'][0]['value']}');
                widget.vessels[i].speedOverGround = 0.0;
              }else{
                print('modifica speed overground da ${widget.vessels[i].speedOverGround} a ${data['updates'][0]['values'][0]['value']}');
                widget.vessels[i].speedOverGround =
                data['updates'][0]['values'][0]['value'];
              }

              //calcolo la previsione sulla prossima posizione
              widget.vessels[i].nextPosition(positionPrevision);
              updateMarker(i);
            }catch(e,s){
              print("impossibile aggiornare velocità->$e $s");
            }
          }
          else if(path=='navigation.courseOverGroundTrue'){
            try {
              //necessario perché 0 lo legge come int
              if(data['updates'][0]['values'][0]['value'] == 0){
                print('modifica courseoverground da ${widget.vessels[i].courseOverGroundTrue} a ${data['updates'][0]['values'][0]['value']}');
                widget.vessels[i].courseOverGroundTrue = 0.0;
              }
              else {
                print('modifica courseoverground da ${widget.vessels[i].courseOverGroundTrue} a ${data['updates'][0]['values'][0]['value']}');
                widget.vessels[i].courseOverGroundTrue = data['updates'][0]['values'][0]['value'];
              }
              widget.vessels[i].nextPosition(positionPrevision);
              updateMarker(i);
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
              print('modifica position da ${widget.vessels[i].latLng} a $latLng');
              widget.vessels[i].latLng = latLng;
              _markers[i].point.latitude = latLng.latitude;
              _markers[i].point.longitude = latLng.longitude;

            }catch (e,s){
              print("impossibile aggiornare position->$e $s");
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [StreamBuilder(
            stream: widget.channel.stream,
            builder: (context,snapshot) {
              try {
                readWS(snapshot);
              }catch (e){print('la prima lettura non fornisce info a me utili');}
              return FlutterMap(
                options: MapOptions(
                  center: _markers[0].point,
                  zoom: 13.0,
                ),
                layers: [
                  TileLayerOptions(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a','b','c'],
                    maxZoom: 200,
                  ),
                  TileLayerOptions(
                      urlTemplate: "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png",
                      subdomains: ['a','b','c'],
                      backgroundColor: Colors.transparent
                  ),
                  MarkerLayerOptions(
                    markers: _markers,
                  ),
                  PolylineLayerOptions(
                      polylines: [Polyline(
                          points: [widget.vessels[0].latLng,widget.vessels[0].nextPosition(positionPrevision)]
                      ),]
                  ),
                ],
              );
            },
          ),
      Align(
        alignment: Alignment.bottomRight,
             child: SizedBox(
               width: 200,
                 height: 100,
                 child: Slider(
                value: positionPrevision,
                onChanged: (newValue){
                  setState(() => positionPrevision = newValue);
                },
                min: 0,
                max: 60,
                divisions: 60,
                label: positionPrevision.round().toString(),
              )
      )
    )
            ],
        ),
    );
  }
}
