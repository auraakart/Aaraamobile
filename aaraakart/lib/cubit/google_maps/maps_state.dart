import 'package:aaraa_kart/data/model/reverse_geo_code_response.dart';

abstract class MapsState {}

class MapInitial extends MapsState {}

class ReverseGeoLoading extends MapsState {
  final bool isLoading;

  ReverseGeoLoading({required this.isLoading});

  @override
  List<Object?> get props => [isLoading];
}

class ReverseGeoSuccess extends MapsState {
  final ReverseGeoCodeResponseModel reverseGeoData;
  ReverseGeoSuccess(this.reverseGeoData);
}

class ReverseGeoError extends MapsState {
  final String message;
  ReverseGeoError(this.message);
}

class ValidateConfirmAddressState extends MapsState {
  bool isValid = false;
  ValidateConfirmAddressState({required this.isValid});
  List<Object?> get props => [isValid];
}


