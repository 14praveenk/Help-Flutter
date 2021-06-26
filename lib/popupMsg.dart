import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:georange/georange.dart';

class markerPopupMsg extends StatefulWidget {
  final Marker marker;
  final Object? initData;
  final List<String> hashMarkers;
  markerPopupMsg(this.initData, this.marker, this.hashMarkers, {Key? key})
      : super(key: key);
  @override
  _markerPopupMsg createState() => _markerPopupMsg();
}

class _markerPopupMsg extends State<markerPopupMsg> {
  Marker? _marker;
  List<int> aedIndex = [];
  void initState() {
    super.initState();
    GeoRange georange = GeoRange();
    aedIndex.add(widget.hashMarkers
        .indexOf(georange.encode(
            widget.marker.point.latitude, widget.marker.point.longitude))
        .toInt());
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 20, right: 10),
              child: Icon(Icons.health_and_safety_outlined),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                constraints: BoxConstraints(minWidth: 100, maxWidth: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      "${((widget.initData as dynamic)[4][aedIndex[0]] as dynamic)['name']}",
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.0,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 4.0)),
                    Text(
                      'Location: ${((widget.initData as dynamic)[4][aedIndex[0]] as dynamic)['address']}',
                      style: const TextStyle(fontSize: 12.0),
                    ),
                    HtmlWidget(
                      ((widget.initData as dynamic)[0]
                              as dynamic)['description']
                          .replaceAll(RegExp('<br />\\s+'), "<br />"),
                      textStyle: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
