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
    //Verifico quale evento è stato scatenato
    ///Se l'evento è GetVessels
    if(event is GetVessels){
      ///Viene lanciato lo stato di loading
      yield GetVesselsLoading();

      ///se [VesselRepo().createVessels()] va a buon fine, viene instanziata la lista di Vessel
      ///e viene lanciato lo stato di successo
      try {
        List<Vessel> vessels = await VesselRepo().createVessels();
        yield GetVesselsSucceed(vessels);
        ///altrimenti viene lanciato lo stato failure
      }catch (e) {
        yield GetVesselsFailure('blocError');
      }
    }
  }
}
