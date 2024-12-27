import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:test_location/model/CurrentLocationModel.dart';

enum ButtonState {
  start,
  stop,
  download,
}

class LocationReadingController extends GetxController {
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  StreamSubscription<LocationData>? positionStreamSubscription;
  Rx<ButtonState> currentBtnState = ButtonState.start.obs;
  ScrollController scrollController = ScrollController();
  RxList<CurrentLocationModel> receivedCoordinatedList =
      <CurrentLocationModel>[].obs;
  final Location location = Location();

  @override
  void onInit() {
    super.onInit();
    initLocationService();
  }

  Future<void> initLocationService() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    await requestBackgroundPermission();
  }

  Future<void> requestBackgroundPermission() async {
    var backgroundStatus =
        await permission_handler.Permission.locationAlways.status;

    if (backgroundStatus.isDenied) {
      backgroundStatus =
          await permission_handler.Permission.locationAlways.request();
      if (!backgroundStatus.isGranted) {
        debugPrint('Background location permission not granted');
        Get.snackbar('Error', 'Background permission is not allowed ');
        return;
      }
    }

    await location.enableBackgroundMode(enable: true);
  }

  Future<void> startFetchingLocation() async {
    debugPrint('isBg available:- ${await location.isBackgroundModeEnabled()}');
    positionStreamSubscription =
        location.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        latitude.value = currentLocation.latitude!;
        longitude.value = currentLocation.longitude!;

        debugPrint(
            'Latitude: $latitude, Longitude: $longitude ===>>> ${DateTime.now().second}');

        receivedCoordinatedList.insert(
            receivedCoordinatedList.length,
            CurrentLocationModel(
                latitude: latitude.toString(),
                longitude: longitude.toString(),
                time: DateTime.now().toString()));

        scrollController.animateTo(
          scrollController.position.maxScrollExtent + 150,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    currentBtnState.value = ButtonState.stop;
  }

  void stopListening() {
    positionStreamSubscription?.cancel();
    if (receivedCoordinatedList.isNotEmpty) {
      currentBtnState.value = ButtonState.download;
    } else {
      currentBtnState.value = ButtonState.start;
    }
  }

  Future<void> saveLocationsAsCsv() async {
    List<String> csvRows = [
      CurrentLocationModel.getCsvHeader(),
      ...receivedCoordinatedList.map((item) => item.toCsvRow())
    ];
    String csvContent = csvRows.join('\n');

    await saveFileToDownloads("locations.csv", csvContent);
  }

  Future<void> saveFileToDownloads(String fileName, String content) async {
    try {
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory == null)
          throw Exception('Unable to access storage directory');

        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);
        debugPrint("File saved to: ${file.path}");

        await OpenFilex.open(file.path);

        receivedCoordinatedList.clear();
        currentBtnState.value = ButtonState.start;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$fileName');
        await file.writeAsString(content);
        await OpenFilex.open(file.path);
      }
    } catch (e) {
      debugPrint("Error saving file: $e");
      rethrow;
    }
  }

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}

class Constants {
  static const String storageEmulatedDownloadPath =
      '/storage/emulated/0/Download';
  static const String sdcardDownloadPath = '/sdcard/Download';
}
