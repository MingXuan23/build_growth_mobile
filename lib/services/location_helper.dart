import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelper {
  static Position? currentPosition;
  static String? currentAddress;

  static Future<List<String>> getAddress() async {
    try {
      if (!await requestLocationPermission()) {
        return [];
      }
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings(
            accuracy: LocationAccuracy.best, forceLocationManager: true),
      );
      currentPosition = position;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      // List<Placemark> placemarks = await placemarkFromCoordinates(
      //     1.6308170573688727, 103.60533184889859);

      Placemark place = placemarks[0];
      List<String> address_list = [];

      address_list.add(place.street ?? "");
      address_list.add(place.thoroughfare ?? "");
      address_list.add(place.subLocality ?? "");
      address_list.add(place.postalCode ?? "");

      address_list.add(place.locality ?? "");

      if (place.administrativeArea == "Malacca") {
        address_list.add("Melaka");
      } else if (place.administrativeArea == "Pulau Pinang") {
        address_list.add("Penang");
      } else {
        address_list.add(place.administrativeArea ?? "");
      }

      address_list =
          address_list.where((value) => value.isNotEmpty).toSet().toList();

      return address_list;
    } catch (e) {
      return [];
    }
  }

  static Future<bool> requestLocationPermission() async {
    // Check the current permission status.
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      // Request permission if it's denied.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied again, handle appropriately.
      
        return false;
      }
    }


    // Check if location services are enabled.
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      // Prompt the user to enable location services.
      await Geolocator.openLocationSettings();
     await Future.delayed(Duration(milliseconds: 100));
        while (WidgetsBinding.instance?.lifecycleState != AppLifecycleState.resumed) {
          await Future.delayed(Duration(milliseconds: 300));
        }
        return await Geolocator.isLocationServiceEnabled();

    } 

    // Permissions are granted and location services are enabled.
    return true;
  }
}
