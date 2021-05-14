part of 'get_vessels_bloc.dart';

///Definisce i vari stati dell'applicazione
@immutable
abstract class GetVesselsState {}

///Stato iniziale
class GetVesselsInitial extends GetVesselsState {}
///Stato di loading
class GetVesselsLoading extends GetVesselsState {}
///Stato di successo
class GetVesselsSucceed extends GetVesselsState {
  ///Genera una lista di [Vessel]
  List<Vessel> vessels;
  GetVesselsSucceed(this.vessels);
}
///Stato di failure
class GetVesselsFailure extends GetVesselsState {
  ///Viene creato un messaggio d'errore
  String message;
  GetVesselsFailure(this.message);
}