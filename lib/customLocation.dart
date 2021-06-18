import 'package:flutter/material.dart';
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

  List<MapBoxPlace> _placePredictions = [];

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

  Widget _placeOption(MapBoxPlace prediction) {
    String? place = prediction.text;
    String? fullName = prediction.placeName;

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

  // Methods
  Future _autocompletePlace(String input) async {
    /// Will be called when the input changes. Making callbacks to the Places
    /// Api and giving the user Place options
    ///
    if (input.length > 0) {
      var placesSearch = PlacesSearch(
        apiKey: widget.apiKey,
        country: widget.country,
      );

      final predictions = await placesSearch.getPlaces(
        input,
      );
      setState(() => _placePredictions = predictions!);
    } else {
      setState(() => _placePredictions = []);
    }
  }

  void _selectPlace(MapBoxPlace prediction) async {
    /// Will be called when a user selects one of the Place options.
    // Sets TextField value to be the location selected
    _textEditingController.value = TextEditingValue(
      text: prediction.placeName.toString(),
      selection: TextSelection.collapsed(offset: prediction.placeName!.length),
    );
    setState(() {
      _placePredictions = [];
      // _selectedPlace = prediction;
      var box = Hive.box('settings');
      box.put("useGNSS", false);
      box.put("cusLocation", prediction.placeName.toString());
      box.put("cusLocCoords", prediction.geometry!.coordinates);
    });

    Navigator.pop(context, true);
  }
}
