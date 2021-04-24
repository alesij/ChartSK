import 'package:flutter/material.dart';
import 'package:marine/connection/http_req.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  HttpRequest request = new HttpRequest('http://demo.signalk.org/signalk/v1/api/vessels');


  @override void initState() {
    super.initState();
    request.createVessels();
  }





  //grafica
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
