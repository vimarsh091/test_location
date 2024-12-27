import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:test_location/locationReading/location_reading_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LocationReadingPage(),
    );
  }
}

class LocationReadingPage extends StatelessWidget {
  LocationReadingPage({super.key});

  final controller = Get.put(LocationReadingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          'Location',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Expanded(
              child: Obx(
                () => controller.receivedCoordinatedList.isEmpty
                    ? const Center(
                        child: Text('No Coordinate Received'),
                      )
                    : ListView.builder(
                        itemCount: controller.receivedCoordinatedList.length,
                        controller: controller.scrollController,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var item = controller.receivedCoordinatedList[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            child: ListTile(
                              style: ListTileStyle.list,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Colors.deepPurple, width: 2, style: BorderStyle.solid)),
                              title: Text(
                                  'Uid :- ${item.uid}, \nLat :- ${item.latitude}, \nLong :- ${item.longitude}, \nTime :- ${item.time}'),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 30,
            child: Center(
              child: Obx(
                () => ElevatedButton(
                    style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.deepPurple)),
                    onPressed: () {
                      switch (controller.currentBtnState.value) {
                        case ButtonState.start:
                          controller.startFetchingLocation();
                          return;
                        case ButtonState.stop:
                          controller.stopListening();
                          return;
                        case ButtonState.download:
                          controller.saveLocationsAsCsv();
                          return;
                      }
                    },
                    child: Text(
                      controller.currentBtnState.value == ButtonState.start
                          ? 'Start'
                          : controller.currentBtnState.value == ButtonState.stop
                              ? 'Stop'
                              : 'Download',
                      style: const TextStyle(color: Colors.white),
                    )),
              ),
            ),
          )
        ],
      ),
    );
  }
}
