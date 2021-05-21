enum Metric{meter,ft,yd,mile}

extension MetricExtension on Metric {

  ///Una volta scelto uno dei parametri di Metric, posso richiamare la funzione
  ///[name] per ritornare la scelta
  String get name {
    switch (this) {
      case Metric.meter:
        return 'meter';
      case Metric.ft:
        return 'ft';
      case Metric.yd:
        return 'yd';
      case Metric.mile:
        return 'mile';
      default:
        return null;
    }
  }

  void talk() {
    print('meow');
  }
}