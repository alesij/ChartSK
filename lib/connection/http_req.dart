import 'dart:convert';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:marine/model/vessel.dart';

class HttpRequest{

  final String urlSelf = 'http://demo.signalk.org/signalk/v1/api/vessels/self';
  final String urlAll = 'http://demo.signalk.org/signalk/v1/api/vessels';

  Future<List<Vessel>> createVessels() async{
    List<Vessel> vessels = [];

    //http request per trovare self
    Response responseSelf = await get(Uri.parse(urlSelf));

    Map dataSelf = jsonDecode(responseSelf.body);

    //estraggo prima i dati di self per far si che self sia il primo della lista (indice 0).
    try{
      double latitude = dataSelf['navigation']['position']['value']['latitude'];
      double longitude = dataSelf['navigation']['position']['value']['longitude'];
      double directionInRadians= dataSelf['navigation']['courseOverGroundTrue']['value'];
      double speed = dataSelf['navigation']['speedOverGround']['value'];

      Vessel temporaryVessel = new Vessel(
        id: dataSelf['uuid'],latLng:
        new LatLng(latitude,longitude),
        courseOverGroundTrue: directionInRadians,
        speedOverGround: speed
      );

      temporaryVessel.nextPosition(5);

      vessels.add(temporaryVessel);
      /*
      print(temporaryVessel.id);
      print(temporaryVessel.latLng.latitude);
      print(temporaryVessel.latLng.longitude);
      print(temporaryVessel.courseOverGroundTrue);
      print(temporaryVessel.speedOverGround);
       */
    }
    on Error catch(_){
      print('error');
    }

    //ora aggiungo tutti gli altri vessels
    //http request
    Response response = await get(Uri.parse(urlAll));
    Map data = jsonDecode(response.body);

    data.keys.forEach((key) {
      if(key!=vessels[0].id){
        String name;
        double directionInRadians;
        double speed;
        double latitude;
        double longitude;

      try {
        latitude = data[key]['navigation']['position']['value']['latitude'];
        longitude = data[key]['navigation']['position']['value']['longitude'];

        try{
          name = data[key]['name'];
        }on Error catch (_) {print('name not available');}

        try{
          speed = data[key]['navigation']['speedOverGround']['value'];
        }on Error catch(_) {print('speed not available');}
        try{
          directionInRadians =
          data[key]['navigation']['courseOverGroundTrue']['value'];
        }on Error catch(_) {print('gradi not available');}

        Vessel temporaryVessel = new Vessel(
            name: name,
            id: key,
            latLng: new LatLng(latitude,longitude),
            courseOverGroundTrue: directionInRadians,
            speedOverGround: speed
        );

        vessels.add(temporaryVessel);

        /*
        print(temporaryVessel.id);
        print(temporaryVessel.name);
        print(temporaryVessel.latLng.latitude);
        print(temporaryVessel.latLng.longitude);
        print(temporaryVessel.courseOverGroundTrue);
        print(temporaryVessel.speedOverGround);
         */


      }on Error catch(_) {print('position not available');}
    }});
    return vessels;
  }
}