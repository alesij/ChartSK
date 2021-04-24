class Vessel{

  String id;
  String latitude;
  String longitude;

  Vessel({this.id,this.latitude,this.longitude});

  factory Vessel.fromJson(Map<String, dynamic> parsedJson){
    return Vessel(
        id: parsedJson['id'],
        //latitude: parsedJson['latitude'],
        //longitude: parsedJson['longitude']
    );
  }
}