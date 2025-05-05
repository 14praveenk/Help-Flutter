import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';

class customLocationScreen extends StatefulWidget {
  /// API Key of the MapBox.
  final String apiKey = dotenv.env['MAPBOX_TOKEN'].toString();
  /// The callback that is called when the user taps on the search icon.
  // final void Function(MapBoxPlaces place) onSearch;

  ///Limits the search to the given country
  ///
  /// Check the full list of [supported countries](https://docs.mapbox.com/api/search/) for the MapBox API
  final String country = "GB";

  @override
  _customLocationScreenState createState() => _customLocationScreenState();
}

class _customLocationScreenState extends State<customLocationScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController _textEditingController = TextEditingController();

  List<Suggestion> _placePredictions = [];

  // MapBoxPlace _selectedPlace;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Material(
              child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.of(context).size.width,
        child: _searchContainer(
          child: _searchInput(context),
        ),
      )));

  // Widgets
  Widget _searchContainer({required Widget child}) {
    return Builder(builder: (context) {
      return Container(
        height: 600,
        decoration: _containerDecoration(),
        padding: EdgeInsets.only(left: 0, right: 0, top: 15),
        alignment: Alignment.center,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: child,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView(
                // addSemanticIndexes: true,
                // itemExtent: 10,
                children: <Widget>[
                  for (var places in _placePredictions) _placeOption(places),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _searchInput(BuildContext context) {
    return Center(
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              decoration: _inputStyle(),
              controller: _textEditingController,
              onChanged: (value) async {
                await _autocompletePlace(value);
                if (mounted) {
                  setState(() {});
                }
              },
            ),
          ),
          Container(width: 15),
          GestureDetector(
            child: Icon(Icons.search, color: Colors.blue),
            onTap: () {},
          )
        ],
      ),
    );
  }

  Widget _placeOption(Suggestion prediction) {
    String? place = prediction.name;
    String? fullName = prediction.fullAddress ?? "";

    return MaterialButton(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      onPressed: () => _selectPlace(prediction),
      child: ListTile(
        title: Text(
          place!.length < 45
              ? "$place"
              : "${place.replaceRange(45, place.length, "")} ...",
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
          maxLines: 1,
        ),
        subtitle: Text(
          fullName!,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.03),
          maxLines: 1,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 0,
        ),
      ),
    );
  }

  // Styling
  InputDecoration _inputStyle() {
    return InputDecoration(
      hintText: 'Enter a location',
      contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
    );
  }

  BoxDecoration _containerDecoration() {
    return BoxDecoration(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black87,
      borderRadius: BorderRadius.all(Radius.circular(6.0)),
      boxShadow: [
        BoxShadow(color: Colors.black, blurRadius: 0, spreadRadius: 0)
      ],
    );
  }

Future _autocompletePlace(String input) async {
  if (input.isNotEmpty) {
    // Use the new GeoCoding class instead of PlacesSearch
    final geoCoding = SearchBoxAPI(
      apiKey: widget.apiKey, // or omit if you already called MapBoxSearch.init(...)
      limit: 5, // optional limit on the number of places returned
      // country: widget.country, // pass any country or other relevant parameters if needed
    );

    // getPlaces now returns an ApiResponse type
    final apiResponse = await geoCoding.getSuggestions(
    input,
  );
    // Handle Success or Failure with fold
    apiResponse.fold(
      (successData) {
        setState(() => _placePredictions = successData.suggestions);
      },
      (failureData) {
        // In case of an error, handle it or log it. For example:
        setState(() => _placePredictions = []);
      },
    );
  } else {
    // If the input is empty, clear predictions
    setState(() => _placePredictions = []);
  }
}


  void _selectPlace(Suggestion prediction) async {
    /// Will be called when a user selects one of the Place options.
    // Sets TextField value to be the location selected
    _textEditingController.value = TextEditingValue(
      text: prediction.name.toString(),
      selection: TextSelection.collapsed(offset: prediction.name!.length),
    );
    final geoCode = GeoCode();
    try {
      final geoCoding = SearchBoxAPI(
      apiKey: widget.apiKey, // or omit if you already called MapBoxSearch.init(...)
      limit: 5, // optional limit on the number of places returned
      // country: widget.country, // pass any country or other relevant parameters if needed
    );
      final ApiResponse<RetrieveResonse> searchPlace = await geoCoding.getPlace(prediction.mapboxId);
      final coordinates = searchPlace.fold(
        (successData) {
          return(successData.features[0].geometry.coordinates);
        },
        (failureData) {
          // Handle failure case
          return null;
        },
      );
      setState(() {
      final List<double> coordForm = [coordinates!.long, coordinates!.lat];
      _placePredictions = [];
      // _selectedPlace = prediction;
      var box = Hive.box('settings');
      box.put("useGNSS", false);
      box.put("cusLocation", prediction.name.toString());
      box.put("cusLocCoords", coordForm);
      print(coordForm);
    });
    } catch (e) {
      print("Error retrieving coordinates: $e");
    }
    Navigator.pop(context, true);
  }
}
