import 'dart:convert';
import 'package:http/http.dart';
import 'package:latlong/latlong.dart';
import 'package:marine/model/vessel.dart';

class VesselRepo{

  final String urlSelf = 'http://demo.signalk.org/signalk/v1/api/vessels/self';
  final String urlAll = 'http://demo.signalk.org/signalk/v1/api/vessels';

  Future<List<Vessel>> createVesselsOld() async{
    List<Vessel> vessels = [];

    //http request per trovare self
    Response responseSelf = await get(Uri.parse(urlSelf));

    Map dataSelf = jsonDecode(responseSelf.body);

    //estraggo prima i dati di self per far si che self sia il primo della lista (indice 0).
    {
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


    //ora aggiungo tutti gli altri vessels
    //http request
    Response response = await get(Uri.parse(urlAll));
    Map data = jsonDecode(response.body);

    data.keys.forEach((key) {
      if(key!=vessels[0].id){
        String name='';
        double directionInRadians=0;
        double speed=0;
        double latitude;
        double longitude;
      Map navigation = data[key]['navigation'];
      if(navigation.containsKey('position')) {
        Map position = navigation['position']['value'];
        latitude = position['latitude'];
        longitude = position['longitude'];

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


      }
    }});
    return vessels;
  }

  Future<List<Vessel>> createVessels() async{
    final String url = 'http://demo.signalk.org/signalk/v1/api/';
    List<Vessel> vessels = [];

    //http request per trovare self
    Response response = await get(Uri.parse(url));

    Map<String,dynamic> data = jsonDecode(response.body);
    String idSelf = data['self'];
    Map vesselsMap = data['vessels'];
    vesselsMap.keys.forEach((key) {
      Vessel tmp = Vessel.fromJson(vesselsMap[key]);
      if(tmp.latLng!=null){
        if(tmp.id == idSelf)
          vessels.insert(0, tmp);
        else
          vessels.add(tmp);
      }
    });
    return vessels;
  }
}