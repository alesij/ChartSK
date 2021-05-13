import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong/latlong.dart' as lat;
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:marine/bloc/get_vessels_bloc.dart';
import 'package:marine/model/vessel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:marine/pages/list_vessel.dart';
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
  int positionPrevisionMin=0;
  MapController mapController = MapController();
  bool followPosition = false;
  bool followDirection = false;
  bool checkCrash = false;
  double currentZoom = 13.0;
  bool measure = false;
  lat.LatLng startMeasure, stopMeasure;
  Polyline measurePolyline = Polyline(points: [lat.LatLng(0,0),lat.LatLng(0,0)]);

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
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
                                value: positionPrevisionMin.toDouble(),
                                onChanged: (newValue){
                                  setState(() {
                                    positionPrevisionMin = newValue.toInt();
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
    if (snapshot.hasData && !snapshot.hasError && snapshot.data!="null") {
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
              lat.LatLng latLng = new lat.LatLng(
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

          if(checkCrash&&positionPrevisionMin>0){
            int slot = positionPrevisionMin~/5;
            Vessel vesselInCrash;
            int i=1;
            for(i=1;i<6 && vesselInCrash==null;i++) {
              int slice = i*slot;
              if(slice!=0) {
                vesselInCrash = widget.vessels[0].checkCollision(
                    widget.vessels, slice);
              }
            }
            if(vesselInCrash!=null) {
              WidgetsBinding.instance.addPostFrameCallback((_){


                print('Crash in: ${i*slot} min with ${vesselInCrash.name}');
                final snackBar = SnackBar(content: Text('Crash in: ${i*slot} min with ${vesselInCrash.name}'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              });
            }
          }
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<GetVesselsBloc, GetVesselsState>(
        bloc: BlocProvider.of<GetVesselsBloc>(context),
  listener: (context, state) {
    if(state is GetVesselsFailure){
      final snackBar = SnackBar(content: Text(state.message));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  },
  builder: (context, state) {
    if(state is GetVesselsLoading) {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    else if(state is GetVesselsSucceed) {
      widget.vessels = state.vessels;
      if(_markers==null || _markers.length==0){
        createMarkers();
      }
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: StreamBuilder(
                stream: widget.channel.stream,
                builder: (context, snapshot) {
                  readWS(snapshot);
                  return FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      maxZoom: 16,
                      minZoom: 6,
                      onTap: (point) {
                        print(point);
                        if (measure) {
                          if (startMeasure != null) {
                            stopMeasure = point;

                            setState(() {
                              measurePolyline = Polyline(
                                  strokeWidth: 4.0,
                                  color: Colors.red,
                                  points: [startMeasure, stopMeasure]);

                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  title: Text('Measure result'),
                                  content: SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Text('Start: Lat:${startMeasure.latitude
                                            .toStringAsFixed(
                                            4)} Lon: ${startMeasure.longitude
                                            .toStringAsFixed(4)}'),
                                        Text('End: Lat:${stopMeasure.latitude
                                            .toStringAsFixed(
                                            4)} Lon: ${stopMeasure.longitude
                                            .toStringAsFixed(4)}'),
                                        Text('Distance : ${SphericalUtil
                                            .computeDistanceBetween(LatLng(
                                            startMeasure.latitude,
                                            startMeasure.longitude), LatLng(
                                            stopMeasure.latitude,
                                            stopMeasure.longitude))
                                            .toStringAsFixed(2)} metres'),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Ok'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },);
                            });
                          } else {
                            startMeasure = point;
                          }
                        }
                      },
                      onPositionChanged: (position, hasGesture) {
                        if (_selectedIndex != 0) {
                          setState(() {
                            _selectedIndex = 0;
                            followPosition = false;
                          });
                        }
                      },
                      center: widget.vessels[0].latLng,
                      zoom: currentZoom,
                    ),
                    layers: [
                      TileLayerOptions(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      TileLayerOptions(
                          urlTemplate: "https://tiles.openseamap.org/seamark/{z}/{x}/{y}.png",
                          subdomains: ['a', 'b', 'c'],
                          backgroundColor: Colors.transparent
                      ),
                      MarkerLayerOptions(
                        markers: _markers,
                      ),
                      PolylineLayerOptions(
                          polylines: [Polyline(
                              points: [
                                widget.vessels[0].latLng,
                                widget.vessels[0].nextPosition(
                                    positionPrevisionMin)
                              ]
                          ), measurePolyline
                          ]
                      ),
                    ],
                  );
                },
              ),
            ),

            Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          //setState(() {
                            if (currentZoom != mapController.zoom)
                              currentZoom = mapController.zoom;
                            currentZoom++;
                            mapController.move(
                                mapController.center, currentZoom);
                          //});
                        },
                        icon: Icon(
                          FontAwesomeIcons.searchPlus,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          //setState(() {
                            if (currentZoom != mapController.zoom)
                              currentZoom = mapController.zoom;
                            currentZoom--;
                            mapController.move(
                                mapController.center, currentZoom);
                          //});
                        },
                        icon: Icon(
                          FontAwesomeIcons.searchMinus,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          //setState(() {
                            if (checkCrash) {
                              checkCrash = false;
                              for (Vessel vess in widget.vessels) {
                                vess.crashNotified = false;
                              }
                            } else {
                              checkCrash = true;
                            }
                         // });
                        },
                        icon: Icon(
                          FontAwesomeIcons.exclamationTriangle,
                          color: checkCrash ? Colors.red : Colors.black,

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
                                          builder: (context, setState) =>
                                              Slider(
                                                value: positionPrevisionMin
                                                    .toDouble(),
                                                onChanged: (newValue) {
                                                  setState(() {
                                                    positionPrevisionMin =
                                                        newValue.toInt();
                                                  });
                                                },
                                                min: 0,
                                                max: 60,
                                                divisions: 60,
                                                label: positionPrevisionMin
                                                    .round().toString(),
                                              ),
                                        ),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text('Close'),
                                          onPressed: () {
                                            for (Vessel vess in widget
                                                .vessels) {
                                              vess.crashNotified = false;
                                            }
                                            setState(() {});
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ]
                                  );
                              });
                        },
                        icon: Icon(
                          FontAwesomeIcons.mapMarkedAlt,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (measure) {
                              measure = false;
                              measurePolyline = Polyline(
                                  points: [lat.LatLng(0, 0), lat.LatLng(0, 0)]);
                              startMeasure = null;
                              stopMeasure = null;
                            } else
                              measure = true;
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.rulerCombined,
                          color: measure ? Colors.blue : Colors.black,

                        )
                    ),

                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (currentZoom != mapController.zoom)
                              currentZoom = mapController.zoom;
                            if (followPosition)
                              followPosition = false;
                            else
                              followPosition = true;
                            followVessel();
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.crosshairs,
                          color: followPosition ? Colors.blue : Colors.black,
                        )
                    ),

                    IconButton(
                        onPressed: () {
                          setState(() {
                            if (currentZoom != mapController.zoom)
                              currentZoom = mapController.zoom;
                            if (followDirection)
                              followDirection = false;
                            else
                              followDirection = true;
                            followVessel();
                          });
                        },
                        icon: Icon(
                          FontAwesomeIcons.locationArrow,
                          color: followDirection ? Colors.blue : Colors.black,
                        )
                    ),
                    IconButton(
                        onPressed: () async {
                          Vessel selected = await Navigator.of(context)
                              .push(MaterialPageRoute<Vessel>(
                              builder: (BuildContext context) {
                                return BlocProvider(
                                  create: (context) =>
                                  GetVesselsBloc()
                                    ..add(GetVessels()),
                                  child: ListVessel(),
                                );
                              })
                          );
                          if(selected!=null) {
                            mapController.move(selected.latLng, currentZoom);
                          }
                        },
                        icon: Icon(
                          FontAwesomeIcons.ship,
                        )
                    ),
                  ],
                )
            ),

          ],
        ),
      );
    }
    return Container();
  },
),
    );
  }
}
