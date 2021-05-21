import 'dart:core';

class MetricSystem {
  double meter;
  double ft;
  double yd;
  double mile;

  void calculate(metri){
    meter = metri;
    ft = metri*3.281;
    yd = metri*1.094;
    mile = metri/1609;
  }
}