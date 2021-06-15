import 'package:flutter/services.dart';
import 'package:location/location.dart';
import 'package:location/location.dart' as loc;
import 'dart:async';
import 'package:what3words/what3words.dart';
import 'package:what3words/what3words.dart' as w3w;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

class Init {
  String aname = "";
  var api = What3WordsV3(dotenv.env['W3WKEY'].toString());
  Future initialize() async {
    LatLng currentPosition = await whatToDo();
    // Create and execute a request to obtain a grid section within the provided bounding box
    var coordinates = await api
        .convertTo3wa(w3w.Coordinates(
            currentPosition.latitude, currentPosition.longitude))
        .execute();

    if (coordinates.isSuccessful()) {
    } else {
      var error = coordinates.error();

      if (error == What3WordsError.BAD_WORDS) {
        // The three word address provided is invalid
        print('BadWords: ${error!.message}');
      } else if (error == What3WordsError.INTERNAL_SERVER_ERROR) {
        // Server Error
        print('InternalServerError: ${error!.message}');
      } else if (error == What3WordsError.NETWORK_ERROR) {
        // Network Error
        print('NetworkError: ${error!.message}');
      } else {
        print('${error!.code} : ${error.message}');
      }
    }
    var setup = await _registerServices(currentPosition);
    print("Finished registering services; returning back to main");
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
    var duration = (convert.jsonDecode(response.body) as Map<String, dynamic>);
    return [
      (setup[0]),
      currentPosition,
      coordinates.data()?.toJson(),
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
      LocationData currentPosition = await _determinePosition();

      return LatLng(currentPosition.latitude!.toDouble(),
          currentPosition.longitude!.toDouble());
    }
  }

  Future _registerServices(currentPosition) async {
    print("Started registering services");

    double radius = 10;
    String field = 'position';
    final String response = await rootBundle.loadString('aedlocs.json');
    final data = await convert.json.decode(response);
    var closestDist = 10000;
    var closestIndex = -1;
    var closestsIndexs = [];
    for (var i = 0; i < data.length; i++) {
      final Distance distance = new Distance();
      final int distanceToAED = distance(
              LatLng(currentPosition.latitude, currentPosition.longitude),
              LatLng(data[i]['Latitude'], data[i]['Longitude']))
          .floor();
      if (distanceToAED < closestDist) {
        closestDist = distanceToAED;
        closestsIndexs.add(closestIndex);
        closestIndex = i;
      }
    }
    closestsIndexs.add(closestIndex);
    return [data[closestIndex], data, closestsIndexs];
  }

  Future<loc.LocationData> _determinePosition() async {
    loc.Location location = new loc.Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return Future.error("Not granted");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return Future.error("Not granted");
      }
    }
    if (_permissionGranted == PermissionStatus.deniedForever) {
      var box = Hive.box('settings');
      box.put("welcome_shown", false);
      return Future.error("Not granted");
    }

    return await location.getLocation();
  }
}
