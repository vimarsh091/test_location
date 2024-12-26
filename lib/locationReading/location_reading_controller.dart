import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:test_location/model/CurrentLocationModel.dart';

enum ButtonState {
  start,
  stop,
  download,
}

class LocationReadingController extends GetxController {
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  StreamSubscription<Position>? positionStreamSubscription;
  Rx<ButtonState> currentBtnState = ButtonState.start.obs;
  RxList<CurrentLocationModel> receivedCoordinatedList =
      <CurrentLocationModel>[].obs;

  void startFetchingLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    receivedCoordinatedList.clear();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }

    positionStreamSubscription = Stream.periodic(const Duration(seconds: 2))
        .asyncMap((_) => Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high),
            ))
        .listen((Position position) {
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      debugPrint(
          'Latitude: $latitude, Longitude: $longitude ===>>> ${DateTime.now().second}');

      receivedCoordinatedList.add(CurrentLocationModel(
          latitude: latitude.toString(),
          longitude: longitude.toString(),
          time: DateTime.now().toString()));
    });
    currentBtnState.value = ButtonState.stop;
  }

  /// stop listening location
  void stopListening() {
    positionStreamSubscription?.cancel();
    if (receivedCoordinatedList.isNotEmpty) {
      currentBtnState.value = ButtonState.download;
    } else {
      currentBtnState.value = ButtonState.start;
    }
  }

  /// download csv file to local
  Future<void> saveLocationsAsCsv() async {
    // Prepare CSV content
    List<String> csvRows = [
      CurrentLocationModel.getCsvHeader(),
      ...receivedCoordinatedList.map((item) => item.toCsvRow())
    ];
    String csvContent = csvRows.join('\n');

    // Save to Downloads folder
    await saveFileToDownloads("locations.csv", csvContent);
  }

  Future<void> saveFileToDownloads(String fileName, String content) async {
    // Request storage permissions
    var status = await Permission.storage.request();
  /*  if (!status.isGranted) {
      print("Storage permission is required.");
      return;
    }*/

    try {
      // Get the Downloads directory
      Directory downloadsDirectory = Directory('/storage/emulated/0/Download');

      // Ensure the directory exists
      if (!await downloadsDirectory.exists()) {
        throw Exception("Downloads directory does not exist.");
      }

      // Create the file in the Downloads folder
      File file = File('${downloadsDirectory.path}/$fileName');
      await file.writeAsString(content);

      print("File saved to: ${file.path}");
      OpenFilex.open(file.path);
    } catch (e) {
      print("Error saving file: $e");
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
