import 'dart:convert';

import 'package:http/http.dart';

class HttpRequest{

  String url;
  
  HttpRequest(this.url);

  Future createVessels() async{
    //http request
    Response response = await get(Uri.parse(url));

    Map data = jsonDecode(response.body);

    data.keys.forEach((key) {
      print('id: $key');
      try{
        print('latitude : ${data[key]['navigation']['position']['value']['latitude']}');
        print('longitude : ${data[key]['navigation']['position']['value']['longitude']}');
      }
      on Error catch(_){
        print("Position not available");
      };
    });
  }
}