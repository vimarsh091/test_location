import 'package:uuid/uuid.dart';

class CurrentLocationModel {
  String uid;
  String? latitude;
  String? longitude;
  String? time;

  CurrentLocationModel({
    String? uid,
    this.latitude,
    this.longitude,
    this.time,
  }) : uid = uid ?? const Uuid().v4().substring(0, 6);

  String toCsvRow() {
    return '$uid,${latitude ?? ''},${longitude ?? ''},${time ?? ''}';
  }

  static String getCsvHeader() {
    return 'UID,Latitude,Longitude,Time';
  }
}
