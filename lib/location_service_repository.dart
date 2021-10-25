import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
//import 'dart:math' show cos, sqrt, asin;

import 'package:background_locator/location_dto.dart';

import 'file_manager.dart';

class LocationServiceRepository {
  static LocationServiceRepository _instance = LocationServiceRepository._();

  LocationServiceRepository._();

  static List coordinates = [];

  factory LocationServiceRepository() {
    return _instance;
  }

  static const String isolateName = 'LocatorIsolate';

  int _count = -1;

  Future<void> init(Map<dynamic, dynamic> params) async {
    //TODO change logs
    print("***********Init callback handler");
    if (params.containsKey('countInit')) {
      dynamic tmpCount = params['countInit'];
      if (tmpCount is double) {
        _count = tmpCount.toInt();
      } else if (tmpCount is String) {
        _count = int.parse(tmpCount);
      } else if (tmpCount is int) {
        _count = tmpCount;
      } else {
        _count = -2;
      }
    } else {
      _count = 0;
    }
    print("$_count");
    await setLogLabel("start");
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> dispose() async {
    print("***********Dispose callback handler");
    print("$_count");
    await setLogLabel("end");
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(null);
  }

  Future<void> callback(LocationDto locationDto) async {
    print('$_count location in dart: ${locationDto.toString()}');
    await setLogPosition(_count, locationDto);
    final SendPort send = IsolateNameServer.lookupPortByName(isolateName);
    send?.send(locationDto);
    _count++;

  }

  static Future<void> setLogLabel(String label) async {
    // final date = DateTime.now();
    // await FileManager.writeToLogFile(
    //     '------------\n$label: ${formatDateLog(date)}\n------------\n');
  }

  // static Future<void> setLogPosition(int count, LocationDto data) async {
  //   var location = new Location();
  //   location.latitude = data.latitude;
  //   location.longitude = data.longitude;
  //   final date = DateTime.now();
  //   var totalDistance;
  //   coordinates.add(location);
  //   double calculateDistance(lat1, lon1, lat2, lon2){
  //     var p = 0.017453292519943295;
  //     var c = cos;
  //     var a = 0.5 - c((lat2 - lat1) * p)/2 +
  //         c(lat1 * p) * c(lat2 * p) *
  //             (1 - c((lon2 - lon1) * p))/2;
  //     return 12742 * asin(sqrt(a));
  //   }
  //   totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"], data[i+1]["lat"], data[i+1]["lng"]);
  //
  //   await FileManager.writeToLogFile(
  //       '$count : ${formatDateLog(date)}  -  ${formatLog(data)}, ${data.accuracy}, ${data.altitude}, ${data.heading}, ${data.speed}, ${data.speedAccuracy}\n'); // --- isMocked: ${data.isMocked}
  // }
  static Future<void> setLogPosition(int count, LocationDto data) async {
    final date = DateTime.now();
    // await FileManager.writeToLogFile(
    //     '$count : ${formatDateLog(date)} --> ${formatLog(data)} --- isMocked: ${data.isMocked}\n');
    Map a = {
      "count" : count.toString(),
      "date" : formatDateLog(date).toString(),
      "lat" : double.parse(data.latitude.toStringAsFixed(4)),
      "long" : double.parse(data.longitude.toStringAsFixed(4)),
      "speed" : double.parse(data.speed.toStringAsFixed(2)),
      "isMocked" : data.isMocked
    };
    await FileManager.writeToLogFile(
        '${jsonEncode(a)}\n');
    // if(data.speed <= 0.3) {
    //   return;
    // }
    // else {
    //   await FileManager.writeToLogFile(
    //       '${jsonEncode(a)}\n');
    // }

    // await FileManager.writeToLogFile(
    //     '${a.toString()}\n');
  }



  static double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);

  }

  static String formatDateLog(DateTime date) {
    return date.hour.toString() +
        ":" +
        date.minute.toString() +
        ":" +
        date.second.toString();
  }

  static String formatLog(LocationDto locationDto) {
    return dp(locationDto.latitude, 4).toString() +
        " " +
        dp(locationDto.longitude, 4).toString();
  }


}

class Location {
  var latitude;
  var longitude;
}
