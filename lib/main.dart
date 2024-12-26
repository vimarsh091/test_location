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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Location'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Obx(
              () => controller.receivedCoordinatedList.isEmpty
                  ? Center(
                      child: Text('No Coordinate Received'),
                    )
                  : ListView.builder(
                      itemCount: controller.receivedCoordinatedList.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var item = controller.receivedCoordinatedList[index];
                        return ListTile(
                          title: Text(
                              'Uid :- ${item.uid}, \nLat :- ${item.latitude}, \nLong :- ${item.longitude}, \nTime :- ${item.time}'),
                        );
                      },
                    ),
            ),
          ),
          Obx(
            () => ElevatedButton(
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
                child:
                    Text(controller.currentBtnState.value == ButtonState.start
                        ? 'Start'
                        : controller.currentBtnState.value == ButtonState.stop
                            ? 'Stop'
                            : 'Download')),
          ),
          SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }
}
