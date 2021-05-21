import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:marine/utility/metric_choice.dart';

class MetricRadio extends StatefulWidget {
  Metric choiceMetricSystem;

  MetricRadio({Key key,this.choiceMetricSystem}) : super(key: key);

  @override
  _MetricRadioState createState() => _MetricRadioState();
}

class _MetricRadioState extends State<MetricRadio> {

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text('selectSystem').tr(),
        content: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  RadioListTile<Metric>(
                    title: const Text('Meter'),
                    value: Metric.meter,
                    groupValue: widget.choiceMetricSystem,
                    onChanged: (Metric value) {
                      setState(() {
                        widget.choiceMetricSystem = value;
                      });
                    },),
                  RadioListTile<Metric>(
                    title: const Text('Ft'),
                    value: Metric.ft,
                    groupValue: widget.choiceMetricSystem,
                    onChanged: (Metric value) {
                      setState(() {
                        widget.choiceMetricSystem = value;
                      });
                    },),
                  RadioListTile<Metric>(
                    title: const Text('Yd'),
                    value: Metric.yd,
                    groupValue: widget.choiceMetricSystem,
                    onChanged: (Metric value) {
                      setState(() {
                        widget.choiceMetricSystem = value;
                      });
                    },),
                  RadioListTile<Metric>(
                    title: const Text('Mile'),
                    value: Metric.mile,
                    groupValue: widget.choiceMetricSystem,
                    onChanged: (Metric value) {
                      setState(() {
                        widget.choiceMetricSystem = value;
                      });
                    },),
                ]
            )
        ),
        actions: <Widget>[
          TextButton(
            child: Text('close').tr(),
            onPressed: () {
              ///Ritorno il valore della scelta fatta
              Navigator.of(context).pop(widget.choiceMetricSystem);
            },
          ),
        ]
    );
  }
}
