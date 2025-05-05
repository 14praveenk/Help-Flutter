import 'package:flutter/services.dart';
import 'package:fl_location/fl_location.dart'; // new dependency import
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class Init {
  String aname = "";  
  Future initialize() async {
    LatLng currentPosition = await whatToDo();
    // Create and execute a request to obtain a grid section within the provided bounding box
    /* var coordinates = await api
        .convertTo3wa(w3w.Coordinates(
            currentPosition.latitude, currentPosition.longitude))
        .execute();

    if (coordinates.isSuccessful()) {
      // Handle successful response
    } else {
      var error = coordinates.error();

      if (error == w3w.What3WordsError.BAD_WORDS) {
        print('BadWords: ${error!.message}');
      } else if (error == w3w.What3WordsError.INTERNAL_SERVER_ERROR) {
        print('InternalServerError: ${error!.message}');
      } else if (error == w3w.What3WordsError.NETWORK_ERROR) {
        print('NetworkError: ${error!.message}');
      } else {
        print('${error!.code} : ${error.message}');
      }
    }*/
    var setup = await _registerServices(currentPosition);
    var response = await http.get(Uri.parse(
        "https://api.mapbox.com/directions-matrix/v1/mapbox/walking/" +
            currentPosition.longitude.toString() +
            "," +
            currentPosition.latitude.toString() +
            ";" +
            (setup[0]['Longitude']).toString() +
            "," +
            (setup[0]['Latitude']).toString() +
            "?sources=0&destinations=1&annotations=duration&access_token=" +
            dotenv.env['MAPBOX_TOKEN'].toString()));
    var duration =
        (convert.jsonDecode(response.body) as Map<String, dynamic>);
    return [
      (setup[0]),
      currentPosition,
      2,
      ((duration['durations'][0][0] / 60).floor()),
      (setup[1]),
      (setup[2]),
    ];
  }

  Future whatToDo() async {
    var box = Hive.box('settings');
    var option = box.get('useGNSS');
    if (option == false) {
      var customLoc = box.get('cusLocCoords');
      return (LatLng(customLoc[1], customLoc[0]));
    } else {
      // Use fl_location API for obtaining the current position
      Location currentPosition = await _determinePosition();
      return LatLng(currentPosition.latitude!.toDouble(),
          currentPosition.longitude!.toDouble());
    }
  }

  Future _registerServices(currentPosition) async {
    double radius = 10;
    String field = 'position';
    final String response = await rootBundle.loadString('assets/aedlocs.json');
    final data = await convert.json.decode(response);
    var closestDist = 10000;
    var closestIndex = -1;
    var closestsIndexs = [];
    for (var x = 0; x < data.length; x++) {
      final Distance distance = new Distance();
      final int distanceToAED = distance(
              LatLng(currentPosition.latitude, currentPosition.longitude),
              LatLng(double.parse(data[x]['Latitude'].toString()),
                  double.parse(data[x]['Longitude'].toString())))
          .toInt();
      if (distanceToAED < closestDist) {
        closestDist = distanceToAED;
        closestIndex = x;
        closestsIndexs.add(x);
      }
    }
    closestsIndexs.add(closestIndex);
    return [data[closestIndex], data, closestsIndexs];
  }

  Future<Location> _determinePosition() async {
    final location = FlLocation();

    bool serviceEnabled = await FlLocation.isLocationServicesEnabled;
    if (!serviceEnabled) {
      LocationPermission permission = await FlLocation.checkLocationPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location service not granted");
      }
    }

    LocationPermission permissionStatus = await FlLocation.checkLocationPermission();
    if (permissionStatus == LocationPermission.denied) {
      permissionStatus = await FlLocation.requestLocationPermission();
      if (permissionStatus == LocationPermission.denied) {
        return Future.error("Location permission not granted");
      }
    }
    if (permissionStatus == LocationPermission.deniedForever) {
      var box = Hive.box('settings');
      box.put("welcome_shown", false);
      return Future.error("Location permission permanently denied");
    }

    return await FlLocation.getLocation();
  }
}
