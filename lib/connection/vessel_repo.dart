import 'dart:convert';
import 'package:http/http.dart';
import 'package:marine/model/vessel.dart';

///Usata in [GetVesselsBloc] ritorna la lista dei Vessels
class VesselRepo{
  Future<List<Vessel>> createVessels() async{
    final String url = 'http://demo.signalk.org/signalk/v1/api/';
    List<Vessel> vessels = [];
    Response response = await get(Uri.parse(url));
    Map<String,dynamic> data = jsonDecode(response.body);
    //Memorizzo l'id del self
    String idSelf = data['self'];
    Map vesselsMap = data['vessels'];
    vesselsMap.keys.forEach((key) {
      Vessel tmp = Vessel.fromJson(vesselsMap[key]);
      if(tmp.latLng!=null){
        //inserisco il self all'indice 0 della lista
        if(tmp.id == idSelf)
          vessels.insert(0, tmp);
        else
          vessels.add(tmp);
      }
    });
    return vessels;
  }
}