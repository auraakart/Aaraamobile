import 'package:aaraa_kart/cubit/banner/banner_state.dart';
import 'package:aaraa_kart/domain/banner_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BannerCubit extends Cubit<BannerState> {
  final BannerRepository _repository;

  BannerCubit(this._repository) : super(BannerInitial());

  Future<void> getMobileBanners() async {
    if (state is BannerLoading) return;
    emit(BannerLoading(isLoading: true));

    try {
      final result = await _repository.fetchMobileBanners();

      if (result.success == false) {
        emit(BannerError('Failed to load banners'));
        return;
      }

      emit(BannerSuccess(banners: result.banners ?? []));
    } catch (e) {
      emit(BannerError(e.toString()));
    }
  }
}


