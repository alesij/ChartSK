import 'dart:convert';
import 'package:http/http.dart';
import 'package:marine/model/vessel.dart';

class HttpRequest{

  final String url = 'http://demo.signalk.org/signalk/v1/api/vessels';


  Future<List<Vessel>> createVessels() async{
    List<Vessel> vessels = [];

    //http request
    Response response = await get(Uri.parse(url));

    Map data = jsonDecode(response.body);

    data.keys.forEach((key) {
      print('id: $key');
      try{
        double latitude = data[key]['navigation']['position']['value']['latitude'];
        double longitude = data[key]['navigation']['position']['value']['longitude'];

        print('latitude : ${data[key]['navigation']['position']['value']['latitude']}');
        print('longitude : ${data[key]['navigation']['position']['value']['longitude']}');
        Vessel temporaryVessel = new Vessel(id: key,latitude: latitude,longitude: longitude);
        vessels.add(temporaryVessel);
      }
      on Error catch(_){
        print("Position not available");
      };
    });
    return vessels;
  }
}