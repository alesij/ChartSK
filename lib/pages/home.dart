import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  double positionPrevisionMin=0;
  MapController mapController = MapController();
  bool followPosition = false;
  bool followDirection = false;
  double currentZoom = 13.0;
  Marker generateMarker(int i){
    return Marker(
        width: 70.0,
        height: 70.0,
        point: this.widget.vessels[i].latLng,
        builder: (ctx) => GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return
                      AlertDialog(
                          title: Text('${this.widget.vessels[i].name}'),
                          content: SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (context, setState) => Slider(
                                value: positionPrevisionMin,
                                onChanged: (newValue){
                                  setState(() {
                                    positionPrevisionMin = newValue;
                                  });
                                },
                                min: 0,
                                max: 60,
                                divisions: 60,
                                label: positionPrevisionMin.round().toString(),
                              ),
                            ),
                          ),
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
            child: VesselWidget(vessel: widget.vessels[i], icon: i==0?'assets/ship_red.png': 'assets/ais_active.png',width: 25,height: 25))
    );
  }
  void createMarkers() {
    for (int i = 0; i < widget.vessels.length; i++) {
      _markers.add(generateMarker(i));
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
      _markers[index]=generateMarker(index);
  }

  //modifica valori del vessel
  void readWS(snapshot) {
    if (snapshot.hasData && !snapshot.hasError) {
      Map data = jsonDecode(snapshot.data);
      if (data.containsKey('context') && data.containsKey('updates')) {
        String id = data['context'].toString().replaceAll("vessels.", "");
        String path = data['updates'][0]['values'][0]['path'];
        int vesselToUpdateIndex = widget.vessels.indexWhere((element) =>
        element.id == id);
        if (vesselToUpdateIndex != -1) {
          Vessel vesselToUpdate = widget.vessels[vesselToUpdateIndex];
          print('modificato vessel $vesselToUpdateIndex ovvero ${vesselToUpdate
              .name}, id=${vesselToUpdate.id}');
          if (path == 'navigation.speedOverGround') {
                vesselToUpdate.speedOverGround =
                data['updates'][0]['values'][0]['value'].toDouble();
          } else if (path == 'navigation.courseOverGroundTrue') {
            vesselToUpdate.courseOverGroundTrue =
            data['updates'][0]['values'][0]['value'].toDouble();

          }else if (path == 'navigation.position') {
              LatLng latLng = new LatLng(
                  data['updates'][0]['values'][0]['value']['latitude'].toDouble(),
                  data['updates'][0]['values'][0]['value']['longitude'].toDouble()
              );
              vesselToUpdate.latLng = latLng;
          }
          //calcolo la previsione sulla prossima posizione
          vesselToUpdate.nextPosition(positionPrevisionMin);
          updateMarker(vesselToUpdateIndex);
          if(vesselToUpdateIndex==0 && (followDirection || followPosition))
            followVessel();
        }
      }
    }
  }

  void followVessel(){
      if (followPosition)
        mapController.move(_markers[0].point, currentZoom);
      if (followDirection)
        mapController.rotate(widget.vessels[0].directionToDegrees());
      else
        mapController.rotate(0);
  }

  bool showNavigation=false;
  int _selectedIndex=0;
  Widget getNavigation() {
    if(showNavigation) {
      return NavigationRail(
        labelType: NavigationRailLabelType.selected,
        backgroundColor: Colors.black,
        unselectedIconTheme: IconThemeData(
          color: Colors.white,
        ),
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
            switch (index) {
              case 2:
                showDialog(
                context: context,
                builder: (BuildContext context) {
                  return
                AlertDialog(
                    title: Text('Prevision in min:'),
                    content: SingleChildScrollView(
                        child: StatefulBuilder(
                          builder: (context, setState) => Slider(
                          value: positionPrevisionMin,
                          onChanged: (newValue){
                            setState(() {
                              positionPrevisionMin = newValue;
                            });
                          },
                          min: 0,
                          max: 60,
                          divisions: 60,
                          label: positionPrevisionMin.round().toString(),
                      ),
                        ),
                    ),
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
                break;
              case 5:
                followPosition = !followPosition;
                followVessel();
                break;
              case 4:
                followDirection = !followDirection;
                followVessel();
                break;
            }
          });
        },

        extended: false,
        destinations: const <NavigationRailDestination>[
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.bars),
            selectedIcon: Icon(FontAwesomeIcons.bars),
            label: Text('Menu'),
          ),
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.exclamationTriangle),
            selectedIcon: Icon(FontAwesomeIcons.exclamationTriangle),
            label: Text('Crash'),
          ),
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.layerGroup),
            selectedIcon: Icon(FontAwesomeIcons.layerGroup),
            label: Text('Layers'),
          ),
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.pencilAlt),
            selectedIcon: Icon(FontAwesomeIcons.pencilAlt),
            label: Text('Edit'),
          ),
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.locationArrow),
            selectedIcon: Icon(FontAwesomeIcons.locationArrow),
            label: Text('Route'),
          ),
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.crosshairs),
            selectedIcon: Icon(FontAwesomeIcons.crosshairs),
            label: Text('Center'),
          ),
          NavigationRailDestination(
            icon: Icon(FontAwesomeIcons.ellipsisH),
            selectedIcon: Icon(FontAwesomeIcons.ellipsisH),
            label: Text('Other'),
          ),
        ],
      );
    }else{
      return Align(
        alignment: Alignment.topLeft,
        child: ElevatedButton(
          child: Text('>'),
          onPressed: () {
            setState(() {
              showNavigation=true;
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder(
              stream: widget.channel.stream,
              builder: (context,snapshot) {
                readWS(snapshot);
                return FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    onTap: (point) {
                      print(point);
                    },
                    onPositionChanged: (position, hasGesture) {
                      if(_selectedIndex!=0){
                        setState(() {
                           _selectedIndex = 0;
                          followPosition=false;
                        });
                      }
                    },
                    center: _markers[0].point,
                    zoom: currentZoom,
                  ),
                  layers: [
                    TileLayerOptions(
                      urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                      subdomains: ['a','b','c'],
                      maxZoom: 18,
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
                            points: [widget.vessels[0].latLng,widget.vessels[0].nextPosition(positionPrevisionMin)]
                        ),
                        ]
                    ),
                  ],
                );
              },
          ),
            ),
            /*Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                    width: 200,
                    height: 100,
                    child: Slider(
                      value: positionPrevisionMin,
                      onChanged: (newValue){
                        setState(() => positionPrevisionMin = newValue);
                      },
                      min: 0,
                      max: 60,
                      divisions: 60,
                      label: positionPrevisionMin.round().toString(),
                    )
                )
            ),
            Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    width: 200,
                    height: 100,
                    child: ElevatedButton(
                      child: Icon(Icons.gps_fixed),
                      onPressed: () {
                        setState(() => followPosition=!followPosition );
                      },
                    )
                )
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                    width: 200,
                    height: 100,
                    child: ElevatedButton(
                      child: Icon(Icons.gps_fixed),
                      onPressed: () {
                        setState(() => followRoute = !followRoute);
                      },
                    )
                )
            ),*/
            Align(
                alignment: Alignment.topRight,
                child:  Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            currentZoom++;
                            mapController.move(mapController.center, currentZoom);
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.plus,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          setState(() {
                            currentZoom--;
                            mapController.move(mapController.center, currentZoom);
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.minus,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                        },
                        icon: Icon(
                          FontAwesomeIcons.exclamationTriangle,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return
                                  AlertDialog(
                                      title: Text('Prevision in min:'),
                                      content: SingleChildScrollView(
                                        child: StatefulBuilder(
                                          builder: (context, setState) => Slider(
                                            value: positionPrevisionMin,
                                            onChanged: (newValue){
                                              setState(() {
                                                positionPrevisionMin = newValue;
                                              });
                                            },
                                            min: 0,
                                            max: 60,
                                            divisions: 60,
                                            label: positionPrevisionMin.round().toString(),
                                          ),
                                        ),
                                      ),
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
                        icon: Icon(
                          FontAwesomeIcons.layerGroup,
                        )
                    ),

                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(
                          FontAwesomeIcons.pencilAlt,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          setState(() {
                            if(followPosition)
                              followPosition=false;
                            else followPosition=true;
                            followVessel();
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.crosshairs,
                          color: followPosition?Colors.blue:Colors.black,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          setState(() {
                            if(followDirection)
                              followDirection=false;
                            else followDirection=true;
                            followVessel();
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.locationArrow,
                          color: followDirection?Colors.redAccent:Colors.black,
                        )
                    ),
                    IconButton(
                        onPressed: () {

                        },
                        icon: Icon(
                          FontAwesomeIcons.ellipsisH,
                        )
                    ),

                  ],
                )
            ),

          ],
        ),
      ),
    );
  }
}
