import 'package:flutter/material.dart';
import 'package:marine/model/vessel.dart';


class Home extends StatefulWidget {
  List<Vessel> vessels = [];
  Home({Key key, @required this.vessels}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  @override void initState() {
    super.initState();
    print(this.widget.vessels[0].id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text('fratm'),
    );
  }
}
