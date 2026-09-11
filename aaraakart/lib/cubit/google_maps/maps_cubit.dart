import 'package:aaraa_kart/cubit/google_maps/maps_state.dart';
import 'package:aaraa_kart/domain/google_map_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MapsCubit extends Cubit<MapsState> {
  final GoogleMapRepository _repository;

  MapsCubit(this._repository) : super(MapInitial());

  void getReverseGeoData(latitude, longtitude) async {
    try {
      emit(ReverseGeoLoading(isLoading: true));

      final result = await _repository.getReverseGeoCode(
        latitude.toString(),
        longtitude.toString(),
      );

      emit(ReverseGeoLoading(isLoading: false));

      emit(ReverseGeoSuccess(result));
    } catch (e) {
      emit(ReverseGeoLoading(isLoading: false));

      emit(ReverseGeoError(e.toString()));
    }
  }

  validateConfirmAddressButton(bool isValid) {
    emit(ValidateConfirmAddressState(isValid: isValid));
  }
}


