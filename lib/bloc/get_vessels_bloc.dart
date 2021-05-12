import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:marine/connection/vessel_repo.dart';
import 'package:marine/model/vessel.dart';
import 'package:meta/meta.dart';
part 'get_vessels_event.dart';
part 'get_vessels_state.dart';

class GetVesselsBloc extends Bloc<GetVesselsEvent, GetVesselsState> {
  GetVesselsBloc() : super(GetVesselsInitial());

  @override
  Stream<GetVesselsState> mapEventToState(
    GetVesselsEvent event,
  ) async* {
    if(event is GetVessels){
      yield GetVesselsLoading();
      List<Vessel> vessels = await VesselRepo().createVessels();
      //yield GetVesselsSucceed(vessels);
      yield GetVesselsFailure('qualcosa è andato storto');
    }
  }
}
