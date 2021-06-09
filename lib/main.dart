import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_html/flutter_html.dart';
import 'init.dart';
import 'splash.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'popupMsg.dart';
import 'package:georange/georange.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: "dotenv");
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  /// The future is part of the state of our widget. We should not call `initializeApp`
  /// directly inside [build].
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Yellow();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Yellow();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help',
      home: FutureBuilder(
        future: Init().initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SafeArea(child: MyHomePage(initData: snapshot.data));
          } else {
            return SplashScreen();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Object? initData;
  MyHomePage({Key? key, required this.initData}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<AlignmentGeometry> alignments = [
    Alignment.centerLeft,
    Alignment.topCenter,
    Alignment.centerRight,
    Alignment.bottomCenter,
    Alignment.center,
  ];
  int _selectedIndex = 1;
  String aedName = "";
  final PageController _pageController = PageController(initialPage: 1);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {});
  }

  bool rotate = true;
  bool fade = true;
  bool snapToMarker = true;
  AlignmentGeometry popupAlignment = alignments[1];
  AlignmentGeometry anchorAlignment = alignments[1];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          Red(
              snap: _popupSnap,
              rotate: rotate,
              fade: fade,
              markerAnchorAlign: _markerAnchorAlign,
              initData: widget.initData),
          Blue(initData: widget.initData),
          Yellow(),
        ],
        onPageChanged: (page) {
          setState(() {
            _selectedIndex = page;
          });
        },
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        child: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment(-1.0120371718436161e-7, -1.0000000017898854),
                  end: Alignment(-0.0009034435046230138, 0.6979166228607521),
                  stops: [0, 0.00009999999747378752, 0.00019999999494757503, 1],
                  colors: [
                    Color.fromARGB(255, 106, 78, 166),
                    Color.fromARGB(0, 70, 140, 222),
                    Color.fromARGB(252, 62, 120, 189),
                    Color.fromARGB(255, 91, 104, 226)
                  ],
                  tileMode: TileMode.mirror)),
          child: BottomNavyBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _selectedIndex,
            showElevation: true,
            itemCornerRadius: 24,
            curve: Curves.easeIn,
            onItemSelected: (index) {
              setState(() => _selectedIndex = index);
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
              );
            },
            items: <BottomNavyBarItem>[
              BottomNavyBarItem(
                activeColor: Colors.white70,
                inactiveColor: Colors.white30,
                icon: Icon(Icons.map_outlined),
                title: Text('Map', style: TextStyle(fontFamily: 'Raleway')),
                textAlign: TextAlign.center,
              ),
              BottomNavyBarItem(
                activeColor: Colors.white70,
                inactiveColor: Colors.white30,
                icon: Icon(Icons.home_outlined),
                title: Text('Home', style: TextStyle(fontFamily: 'Raleway')),
                textAlign: TextAlign.center,
              ),
              BottomNavyBarItem(
                activeColor: Colors.white70,
                inactiveColor: Colors.white30,
                icon: Icon(Icons.settings_outlined),
                title:
                    Text('Settings', style: TextStyle(fontFamily: 'Raleway')),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AnchorAlign get _markerAnchorAlign {
    return <AlignmentGeometry, AnchorAlign>{
      Alignment.centerLeft: AnchorAlign.left,
      Alignment.topCenter: AnchorAlign.top,
      Alignment.centerRight: AnchorAlign.right,
      Alignment.bottomCenter: AnchorAlign.bottom,
      Alignment.center: AnchorAlign.center,
    }[anchorAlignment]!;
  }

  PopupSnap get _popupSnap {
    if (snapToMarker) {
      return <AlignmentGeometry, PopupSnap>{
        Alignment.centerLeft: PopupSnap.markerLeft,
        Alignment.topCenter: PopupSnap.markerTop,
        Alignment.centerRight: PopupSnap.markerRight,
        Alignment.bottomCenter: PopupSnap.markerBottom,
        Alignment.center: PopupSnap.markerCenter,
      }[popupAlignment]!;
    } else {
      return <AlignmentGeometry, PopupSnap>{
        Alignment.centerLeft: PopupSnap.mapLeft,
        Alignment.topCenter: PopupSnap.mapTop,
        Alignment.centerRight: PopupSnap.mapRight,
        Alignment.bottomCenter: PopupSnap.mapBottom,
        Alignment.center: PopupSnap.mapCenter,
      }[popupAlignment]!;
    }
  }
}

class Red extends StatefulWidget {
  final Object? initData;
  final PopupSnap snap;
  final bool rotate;
  final bool fade;
  final AnchorAlign markerAnchorAlign;
  Red(
      {Key? key,
      required this.snap,
      required this.rotate,
      required this.fade,
      required this.markerAnchorAlign,
      required this.initData})
      : super(key: key);
  @override
  _RedState createState() => _RedState();
}

class _RedState extends State<Red> {
  List<Marker> allMarkers = [];
  List<String> hashMarkers = [];
  final PopupController _popupLayerController = PopupController();
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      var r = (widget.initData as dynamic)[4].length;
      for (var x = 0; x < r; x++) {
        GeoRange georange = GeoRange();
        hashMarkers.add(georange.encode(
            ((widget.initData as dynamic)[4][x].data())['position']['geopoint']
                .latitude,
            (((widget.initData as dynamic)[4][x].data())['position']['geopoint']
                .longitude)));
        allMarkers.add(
          Marker(
            point: LatLng(
                (((widget.initData as dynamic)[4][x].data())['position']
                        ['geopoint']
                    .latitude),
                (((widget.initData as dynamic)[4][x].data())['position']
                        ['geopoint']
                    .longitude)),
            builder: (context) => const Icon(
              Icons.circle,
              color: Colors.red,
              size: 25.0,
            ),
          ),
        );
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FlutterMap(
      options: MapOptions(
        center: LatLng((widget.initData as dynamic)[1].latitude,
            (widget.initData as dynamic)[1].longitude),
        zoom: 13.0,
        onTap: (_) => _popupLayerController.hidePopup(),
      ),
      children: [
        TileLayerWidget(
          options: TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c']),
        ),
        PopupMarkerLayerWidget(
          options: PopupMarkerLayerOptions(
            markers: allMarkers,
            popupSnap: widget.snap,
            popupController: _popupLayerController,
            popupBuilder: (BuildContext context, Marker marker) =>
                markerPopupMsg(widget.initData, marker, hashMarkers),
            markerRotate: widget.rotate,
            markerRotateAlignment: PopupMarkerLayerOptions.rotationAlignmentFor(
              widget.markerAnchorAlign,
            ),
            popupAnimation: widget.fade
                ? PopupAnimation.fade(duration: Duration(milliseconds: 700))
                : null,
          ),
        ),
      ],
    ));
  }
}

class Blue extends StatefulWidget {
  final Object? initData;
  Blue({Key? key, required this.initData}) : super(key: key);
  @override
  _BlueState createState() => _BlueState();
}

class _BlueState extends State<Blue> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
                margin: EdgeInsets.only(
                  bottom: 30,
                ),
                child: FractionallySizedBox(
                    alignment: Alignment.topLeft,
                    heightFactor: 0.7,
                    widthFactor: 1,
                    child: Stack(children: [
                      Container(
                        width: double.infinity,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return // create function here to adapt to the parent widget's constraints
                              CachedNetworkImage(
                            imageUrl:
                                'https://api.mapbox.com/styles/v1/mapbox/streets-v11/static/pin-s+f74e4e(' +
                                    (widget.initData as dynamic)[0]['position']
                                            ['geopoint']
                                        .longitude
                                        .toString() +
                                    ',' +
                                    ((widget.initData as dynamic)[0]['position']
                                            ['geopoint']
                                        .latitude
                                        .toString()) +
                                    '),pin-s-home+555555(' +
                                    (widget.initData as dynamic)[1]
                                        .longitude
                                        .toString() +
                                    ',' +
                                    ((widget.initData as dynamic)[1]
                                        .latitude
                                        .toString()) +
                                    '/auto/' +
                                    (constraints.maxWidth * 0.65)
                                        .floor()
                                        .toString() +
                                    'x' +
                                    (constraints.maxHeight * 0.65)
                                        .floor()
                                        .toString() +
                                    '@2x?access_token=' +
                                    dotenv.env['MAPBOX_TOKEN'].toString(),
                            fit: BoxFit.contain,
                          );
                        }),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 200),
                          margin: EdgeInsets.only(top: 10, left: 5),
                          padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                  begin: Alignment(-2.870196942339476e-7,
                                      -2.9523809173103817),
                                  end: Alignment(-3.471565204193894e-7,
                                      7.0714286847386845),
                                  stops: [0, 0.7713881134986877],
                                  colors: [
                                    Color.fromARGB(155, 157, 75, 239),
                                    Color.fromARGB(158, 38, 146, 192)
                                  ],
                                  tileMode: TileMode.clamp)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.done_outlined),
                                Text(
                                    "${(widget.initData as dynamic)[2]['words']}")
                              ]),
                        ),
                      ),
                    ])))),
        Container(
            padding: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  size: 35,
                ),
                Text(" Nearest AED",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 35,
                    )),
              ],
            )),
        Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          margin: EdgeInsets.fromLTRB(22, 30, 22, 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: LinearGradient(
                  begin: Alignment(0.0010858093046581807, -1.0000000648203722),
                  end: Alignment(-2.331161696029882, 2.34839945076237),
                  stops: [0, 1],
                  colors: [
                    Color.fromARGB(137, 240, 132, 34),
                    Color.fromARGB(255, 142, 185, 48),
                  ],
                  tileMode: TileMode.clamp),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: ListTile(
                      title: Text(
                          "${((widget.initData as dynamic)[0] as dynamic)['name']}",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 30,
                          )),
                      subtitle: Row(children: [
                        Icon(
                          Icons.directions_walk_outlined,
                          size: 17,
                        ),
                        Text(
                            ' ${(widget.initData as dynamic)[3]} minutes away.',
                            style: TextStyle(
                              fontSize: 17,
                            ))
                      ]),
                    ),
                  ),
                  Stack(children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35, 20, 0, 20),
                      child: Html(
                          data: ((widget.initData as dynamic)[0]
                                  as dynamic)['description']
                              .replaceAll(RegExp('<br />\\s+'), "<br />"),
                          style: {
                            "body": Style(
                                fontSize: FontSize(20),
                                fontFamily: 'KrubLight'),
                          }),
                    ),
                    /* COULD ADD INFO BUTTON NOT SURE?: Container(
                      margin: EdgeInsets.fromLTRB(0, 50, 10, 10),
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(5)),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all<CircleBorder>(
                            CircleBorder(),
                          ),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          size: 25,
                        ),
                        onPressed: () => {print("Pressed Info")},
                      ),
                    ), */
                  ]),
                ]),
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 50, 20, 0),
          child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    )
                  ],
                  gradient: LinearGradient(
                      begin:
                          Alignment(0.0009855687786108902, -4.543046378961659),
                      end: Alignment(0.0009854648765976748, 3.470198684990992),
                      stops: [0, 1],
                      colors: [
                        Color.fromARGB(255, 67, 255, 2),
                        Color.fromARGB(173, 43, 166, 219)
                      ],
                      tileMode: TileMode.clamp)),
              child: Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    elevation: MaterialStateProperty.all(0),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.transparent),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(30),
                    ),
                  ),
                  child: Text(
                    'Get directions.',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      color: Colors.black,
                      fontSize: 25,
                    ),
                  ),
                ),
              )),
        ),
      ],
    );
  }
}

class Yellow extends StatefulWidget {
  @override
  _YellowState createState() => _YellowState();
}

class _YellowState extends State<Yellow> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
