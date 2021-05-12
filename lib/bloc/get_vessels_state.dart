part of 'get_vessels_bloc.dart';

@immutable
abstract class GetVesselsState {}

class GetVesselsInitial extends GetVesselsState {}
class GetVesselsLoading extends GetVesselsState {}
class GetVesselsSucceed extends GetVesselsState {
  List<Vessel> vessels;
  GetVesselsSucceed(this.vessels);
}
class GetVesselsFailure extends GetVesselsState {
  String message;
  GetVesselsFailure(this.message);
}