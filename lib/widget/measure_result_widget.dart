import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:latlong/latlong.dart' as lat;
import 'package:easy_localization/easy_localization.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:marine/model/metric_system.dart';
import 'package:marine/utility/metric_choice.dart';

class MeasureResult extends StatelessWidget {
  final lat.LatLng start;
  final lat.LatLng end;
  final Metric metricChoice;
  final MetricSystem calculatedResult;

  const MeasureResult({Key key, this.start, this.end, this.metricChoice, this.calculatedResult}) : super(key: key);


  ///mostro il text opportuno a seconda del sistema metrico scelto
  Widget personalizedResult(){
    ///calcolo la distanza per i diversi sistemi metrici
    calculatedResult.calculate(SphericalUtil.computeDistanceBetween(
        LatLng(start.latitude,start.longitude),
        LatLng(end.latitude,end.longitude)));
    switch(metricChoice.name){
      case "meter":{
        return Text('measureDistanceBetweenPoints').tr(args: ["${calculatedResult.meter.toStringAsFixed(2)}","${metricChoice.name}"]);
      }
      case "ft":{
        return Text('measureDistanceBetweenPoints').tr(args: ["${calculatedResult.ft.toStringAsFixed(2)}","${metricChoice.name}"]);
      }
      case "yd":{
        return Text('measureDistanceBetweenPoints').tr(args: ["${calculatedResult.yd.toStringAsFixed(2)}","${metricChoice.name}"]);
      }
      case "mile":{
        return Text('measureDistanceBetweenPoints').tr(args: ["${calculatedResult.mile.toStringAsFixed(2)}","${metricChoice.name}"]);
      }
      default:{
        return Text('measureDistanceBetweenPoints').tr(args: ["${calculatedResult.meter}","${metricChoice.name}"]);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('measureResult').tr(),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('measureResultStartPoint').tr(args: [
              "${start.latitude.toStringAsFixed(4)}",
              "${start.longitude.toStringAsFixed(4)}"
            ]),
            Text('measureResultEndPoint').tr(args: [
              "${end.latitude.toStringAsFixed(4)}",
              "${end.longitude.toStringAsFixed(4)}"
            ]),
            personalizedResult(),
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
  }
}
