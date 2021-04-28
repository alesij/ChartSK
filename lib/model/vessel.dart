import 'package:latlong/latlong.dart';
import 'package:vector_math/vector_math.dart';
class Vessel{

  String id;
  LatLng latLng;
  double directionInRadians;
  double speed;

  Vessel({this.id,this.latLng,this.directionInRadians,this.speed});

  double toDegrees(radians) => radians * radians2Degrees; // da radianti a gradi

}