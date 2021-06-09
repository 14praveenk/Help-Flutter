import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:what3words/what3words.dart';
import 'package:what3words/what3words.dart' as w3w;
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Init {
  String aname = "";
  var api = What3WordsV3(dotenv.env['W3WKEY'].toString());
  Future initialize() async {
    Position currentPosition = await _determinePosition();
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
            (setup[0].data() as dynamic)['position']['geopoint']
                .longitude
                .toString() +
            "," +
            (setup[0].data() as dynamic)['position']['geopoint']
                .latitude
                .toString() +
            "?sources=0&destinations=1&annotations=duration&access_token=" +
            dotenv.env['MAPBOX_TOKEN'].toString()));
    var duration = (convert.jsonDecode(response.body) as Map<String, dynamic>);
    return [
      (setup[0].data()),
      currentPosition,
      coordinates.data()?.toJson(),
      ((duration['durations'][0][0] / 60).floor()),
      (setup)
    ];
  }

  Future<List<DocumentSnapshot<Object?>>> _registerServices(
      currentPosition) async {
    print("Starting registering services");
    final _firestore = FirebaseFirestore.instance;
    GeoFlutterFire geo = GeoFlutterFire();
    GeoFirePoint center = geo.point(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude);
    var collectionReference = _firestore.collection('AEDs');

    double radius = 10;
    String field = 'position';

    return geo
        .collection(collectionRef: collectionReference)
        .within(center: center, radius: radius, field: field, strictMode: false)
        .first;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
