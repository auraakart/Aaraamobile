import 'dart:async';

import 'package:aaraa_kart/app/theme/app_colors.dart';
import 'package:aaraa_kart/core/constants/const.dart';
import 'package:aaraa_kart/cubit/google_maps/maps_cubit.dart';
import 'package:aaraa_kart/cubit/google_maps/maps_state.dart';
import 'package:aaraa_kart/presentation/common/my_app_bar.dart';
import 'package:aaraa_kart/presentation/common/my_app_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_icon_button.dart';
import 'package:aaraa_kart/presentation/common/my_app_shimmer.dart';
import 'package:aaraa_kart/presentation/common/my_app_text.dart';
import 'package:aaraa_kart/presentation/home/address_bottom_sheet.dart';
import 'package:aaraa_kart/presentation/widgets/bottom_button_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/place_type.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:iconsx_plus/iconsx_plus.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({super.key});

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  final TextEditingController _searchController = TextEditingController();

  CameraPosition? _initialPosition;
  LatLng? _selectedPosition;
  String _address = "Loading address...";
  bool _isLocationLoading = true;
  bool _locationPermissionDenied = false;
  bool _isManualLocationMode = false;

  @override
  void initState() {
    super.initState();
    _getGeoLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool containsLetterInFirstThreeWords(String text, String letter) {
    try {
      final words = text.split(' ');
      final firstThree = words.take(3);
      return firstThree
          .any((word) => word.toLowerCase().contains(letter.toLowerCase()));
    } catch (e) {
      return false;
    }
  }

  Future<void> _getGeoLocation() async {
    try {
      setState(() {
        _isLocationLoading = true;
        _locationPermissionDenied = false;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _handleLocationServiceDisabled();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _handleLocationPermissionDenied();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _handleLocationPermissionDeniedForever();
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final selectedPosition = LatLng(position.latitude, position.longitude);
      final initialPosition = CameraPosition(
        target: selectedPosition,
        zoom: 14.4746,
      );

      setState(() {
        _selectedPosition = selectedPosition;
        _initialPosition = initialPosition;
        _isLocationLoading = false;
        _isManualLocationMode = false;
      });

      if (mounted) {
        context.read<MapsCubit>().getReverseGeoData(
              position.latitude,
              position.longitude,
            );
      }
    } catch (e) {
      debugPrint('Location error: $e');
      _handleLocationError(e.toString());
    }
  }

  void _handleLocationServiceDisabled() {
    setState(() {
      _isLocationLoading = false;
      _locationPermissionDenied = true;
    });

    _showLocationDialog(
      title: 'Location Services Disabled',
      message:
          'Please enable location services to get your current location, or select your location manually on the map.',
      showSettings: true,
    );
  }

  void _handleLocationPermissionDenied() {
    setState(() {
      _isLocationLoading = false;
      _locationPermissionDenied = true;
    });

    _showLocationDialog(
      title: 'Location Permission Required',
      message:
          'This app needs location permission to show your current location. You can also select your location manually on the map.',
      showSettings: false,
    );
  }

  void _handleLocationPermissionDeniedForever() {
    setState(() {
      _isLocationLoading = false;
      _locationPermissionDenied = true;
    });

    _showLocationDialog(
      title: 'Location Permission Denied',
      message:
          'Location permission has been permanently denied. Please enable it in app settings or select your location manually on the map.',
      showSettings: true,
    );
  }

  void _handleLocationError(String error) {
    setState(() {
      _isLocationLoading = false;
      _locationPermissionDenied = true;
    });

    _showLocationDialog(
      title: 'Location Error',
      message:
          'Unable to get your location: $error. Please select your location manually on the map.',
      showSettings: false,
    );
  }

  void _showLocationDialog({
    required String title,
    required String message,
    required bool showSettings,
  }) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            if (showSettings)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Geolocator.openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _enableManualLocationMode();
              },
              child: const Text('Select Manually'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _retryLocationAccess();
              },
              child: const Text('Retry'),
            ),
          ],
        );
      },
    );
  }

  void _enableManualLocationMode() {
    const defaultLocation = LatLng(12.925480, 80.232823);
    final initialPosition = CameraPosition(
      target: defaultLocation,
      zoom: 10.0,
    );

    setState(() {
      _selectedPosition = defaultLocation;
      _initialPosition = initialPosition;
      _isLocationLoading = false;
      _isManualLocationMode = true;
      _address = "Please select your location on the map";
    });
  }

  void _retryLocationAccess() {
    _getGeoLocation();
  }

  Future<void> _moveToLocation(LatLng position) async {
    if (!_controller.isCompleted) return;

    try {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(CameraUpdate.newLatLng(position));
    } catch (e) {
      debugPrint('Error moving camera: $e');
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_isManualLocationMode) {
      // In manual mode, try to get current location again
      _retryLocationAccess();
      return;
    }

    if (_initialPosition == null) return;

    try {
      final GoogleMapController controller = await _controller.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_initialPosition!),
      );
    } catch (e) {
      debugPrint('Error moving to current location: $e');
    }
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _selectedPosition = position.target;
    });
  }

  void _onCameraIdle() {
    if (_selectedPosition != null && mounted) {
      context.read<MapsCubit>().getReverseGeoData(
            _selectedPosition!.latitude,
            _selectedPosition!.longitude,
          );
    }
  }

  void _onPlaceSelected(Prediction prediction) async {
    if (prediction.lat == null || prediction.lng == null) return;

    try {
      final lat = double.parse(prediction.lat.toString());
      final lng = double.parse(prediction.lng.toString());
      final selectedLatLng = LatLng(lat, lng);

      setState(() {
        _selectedPosition = selectedLatLng;
      });

      await _moveToLocation(selectedLatLng);
    } catch (e) {
      debugPrint('Error parsing coordinates: $e');
    }
  }

  void _onSearchItemClicked(Prediction prediction) {
    if (prediction.description != null) {
      _searchController.text = prediction.description!;
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: prediction.description!.length),
      );
    }
  }

  void _onAddMoreDetailsPressed(String? pincode) {
    showAddressDetailsBottomSheet(
        context: context,
        location: _address,
        pincode: pincode ?? "Pincode Not Found");
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocationLoading || _initialPosition == null) {
      return Scaffold(
        appBar: MyAppBar(
          centerTitle: false,
          title: MyAppText(data: 'Confirm delivery location'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: MyAppBar(
        centerTitle: false,
        title: MyAppText(data: 'Confirm delivery location'),
      ),
      body: Stack(
        children: [
          _buildGoogleMap(),
          _buildLocationPin(),
          _buildSearchField(),
          if (_isManualLocationMode) _buildManualLocationBanner(),
          _buildDeliveryLocationCard(),
          _buildCurrentLocationButton(),
        ],
      ),
    );
  }

  Widget _buildGoogleMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _initialPosition!,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
    );
  }

  Widget _buildLocationPin() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 36.h),
        child: Icon(
          Iconsax.location_bold,
          color: AppColors.brandPrimary,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: _searchController,
          googleAPIKey: AppConstants.gcpkey,
          inputDecoration: InputDecoration(
            fillColor: AppColors.backgroundBase.withOpacity(0.8),
            filled: true,
            hintText: 'Search for area, street name...',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.6),
              fontSize: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Iconsax.search_normal_1_outline,
                color: AppColors.brandPrimary,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppColors.brandPrimary, width: 0.5)),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppColors.brandPrimary, width: 0.5)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: AppColors.brandPrimary, width: 0.5)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          debounceTime: 400,
          countries: const ["in"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: _onPlaceSelected,
          itemClick: _onSearchItemClicked,
          itemBuilder: (context, index, Prediction prediction) {
            return Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: AppColors.brandPrimary,
                  ),
                  SizedBox(width: 7.w),
                  Expanded(
                    child: MyAppText(
                      data: prediction.description ?? "",
                      size: 12.sp,
                      color: AppColors.textPrimary,
                      maxLines: 5,
                    ),
                  )
                ],
              ),
            );
          },
          seperatedBuilder: Divider(
            height: 1,
            color: AppColors.backgroundBase,
          ),
          isCrossBtnShown: false,
          containerHorizontalPadding: 0,
          placeType: PlaceType.geocode,
        ),
      ),
    );
  }

  Widget _buildCurrentLocationButton() {
    return Positioned(
      right: 16,
      bottom: 250,
      child: FloatingActionButton(
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.brandPrimary,
        elevation: 4,
        onPressed: _moveToCurrentLocation,
        child: Icon(
          _isManualLocationMode ? Icons.location_searching : Icons.my_location,
        ),
      ),
    );
  }

  Widget _buildManualLocationBanner() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Manual location mode - Move the map to select your location',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isManualLocationMode = false;
                });
              },
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryLocationCard() {
    return BlocConsumer<MapsCubit, MapsState>(
      listener: (context, state) {},
      buildWhen: (previous, current) {
        return current is ReverseGeoSuccess ||
            current is ReverseGeoLoading ||
            current is ReverseGeoError;
      },
      builder: (context, state) {
        String displayAddress = _address;
        String? pincode;
        bool isDeliverable = false;

        if (state is ReverseGeoSuccess) {
          displayAddress = state.reverseGeoData.results?.isNotEmpty == true
              ? state.reverseGeoData.results!.first.formattedAddress ??
                  'Address not found'
              : 'Address not found';
          _address = displayAddress;
          state.reverseGeoData.results?.first.addressComponents
              ?.forEach((component) {
            if (component.types!.contains("postal_code")) {
              pincode = component.longName;
            }
          });
        } else if (state is ReverseGeoError) {
          displayAddress = 'Failed to load address';
        }

        print(pincode);

        if (containsLetterInFirstThreeWords(pincode.toString(), '600')) {
          isDeliverable = true;
        } else {
          isDeliverable = false;
        }

        return Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: MyAppShimmer(
            isLoading: state is ReverseGeoLoading,
            child: BottomButtonContainer(widgets: [
              SizedBox(
                height: 16.h,
              ),
              MyAppText(
                data: 'Select delivery location',
                size: 14.sp,
                weight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyAppIconButton(
                    icon: Iconsax.location_bold,
                    onPressed: () {},
                    variant: 'color',
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyAppText(
                          data: displayAddress,
                          size: 12.sp,
                          weight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(height: 4.h),
                        MyAppText(
                          data: 'Move the map to adjust pin location',
                          size: 10.sp,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              if (!isDeliverable) ...[
                MyAppText(
                  data:
                      'Sorry for the inconvenience. We are currently delivering only within Chennai.',
                  color: Colors.red,
                  align: TextAlign.center,
                  size: 10.sp,
                ),
                SizedBox(height: 18.h),
              ],
              Row(
                children: [
                  Expanded(
                    child: MyAppButton(
                      isDisabled: !isDeliverable,
                      onPressed: () => {_onAddMoreDetailsPressed(pincode)},
                      label: 'Add More address details',
                    ),
                  ),
                ],
              )
            ]),
          ),
        );
      },
    );
  }
}


