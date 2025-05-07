import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'init.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'welcome.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive_ce/hive.dart';


Future<void> main() async {
  //await runZonedGuarded(() async {
  await dotenv.load(fileName: "dotenv");
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settings');
   runApp(MyApp());
  /*await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://74695678b2ad4ed488ee3546716682dd@o863841.ingest.sentry.io/5822329';
    },
    appRunner: () => runApp(SentryWidget(
        child: MyApp(),
      ),),
  );}, (error, stackTrace) async {
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
    );
  });*/
}

class App extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MyApp();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Help',
        theme: ThemeData(
          brightness: Brightness.light,
          primaryColor: Colors.black,
        ),
        darkTheme: ThemeData(
            scaffoldBackgroundColor: Colors.black87,
            primaryColor: Colors.white,
            brightness: Brightness.dark),
        home: ValueListenableBuilder(
            valueListenable: Hive.box('settings').listenable(),
            builder: (context, box, child) => (box as dynamic)
                    .get('welcome_shown', defaultValue: false)
                ? FutureBuilder(
                    future: Init().initialize(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return SafeArea(
                            child: MyHomePage(initData: snapshot.data));
                      } else {
                        return Container(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.black87);
                      }
                    })
                : WelcomeScreen()));
  }
}

class MyHomePage extends StatefulWidget {
  final Object? initData;
  MyHomePage({Key? key, required this.initData}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Widget> pageList = [];
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);
  @override
  void initState() {
    pageList.add(Red(initData: widget.initData));
    pageList.add(Blue(initData: widget.initData));
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          physics: new NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: pageList,
            )
          ],
        ),
        bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.white
                  : Colors.grey[850],
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(.1),
                )
              ],
            ),
            child: GNav(
              rippleColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[300]!
                  : Colors.black38,
              hoverColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey[100]!
                  : Colors.black38,
              gap: 8,
              activeColor: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor:
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.grey[100]!
                      : Colors.black12,
              color: Colors.black,
              tabs: [
                GButton(
                  icon: Icons.map_outlined,
                  text: 'Map',
                  iconColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  textColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
                GButton(
                  icon: Icons.home_outlined,
                  text: 'Home',
                  iconColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  textColor: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            )));
  }
}

class Red extends StatefulWidget {
  final Object? initData;
  Red({Key? key, required this.initData}) : super(key: key);
  @override
  _RedState createState() => _RedState();
}

class _RedState extends State<Red> {
  List<Marker> allMarkers = [];
  List<String> hashMarkers = [];
  late final MapController mapController;
  @override
  void initState() {
    super.initState();
    mapController = MapController();
    Future.microtask(() {
      var r = (widget.initData as dynamic)[5].length - 1;
      for (var x = 0; x < r; x++) {
        int q = (widget.initData as dynamic)[5][(x + 1)];
        allMarkers.add(
          Marker(
            point: LatLng((((widget.initData as dynamic)[4][q]['Latitude'])),
                (((widget.initData as dynamic)[4][q]['Longitude']))),
            child: const Icon(
              Icons.favorite_sharp,
              color: Colors.red,
              size: 25.0,
            ),
          ),
        );
      }
      setState(() {});
    });
  }

  void _onScroll(final PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      final delta = pointerSignal.scrollDelta.dy > 0 ? -1 : 1;
      final currentPosition = mapController.camera;
      final currentZoom = currentPosition.zoom;
      final currentCenter = currentPosition.center;
      final zoom = currentZoom + delta;
      if (zoom >= 1 && zoom <= 19) {
        mapController.move(currentCenter, zoom);
      }
    }
  }

  /*late MapboxMapController controller;
  void _onMapCreated(MapboxMapController controller) {
    this.controller = controller;
    controller.setTelemetryEnabled(false);
  }

  void _onStyleLoadedCallback() {
    var r = ((widget.initData as dynamic)[5].length - 1);
    print(r);
    for (var x = 0; x < r; x++) {
      int q = (widget.initData as dynamic)[5][(x + 1)];
      controller.addCircle(
        CircleOptions(
            geometry: LatLng((widget.initData as dynamic)[4][q]['Latitude'],
                (widget.initData as dynamic)[4][q]['Longitude']),
            circleColor: "#FF0000",
            circleRadius: 6),
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Stack(children: [
      Listener(
          onPointerSignal: this._onScroll,
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: LatLng((widget.initData as dynamic)[1].latitude,
                  (widget.initData as dynamic)[1].longitude),
              initialZoom: 13.0,
              maxZoom: 18.0,
              minZoom: 7.0,
            ),
            children: [
              TileLayer(
                    urlTemplate: "https://api.maptiler.com/maps/" +
                        (Theme.of(context).brightness == Brightness.dark
                            ? "uk-openzoomstack-night"
                            : "uk-openzoomstack-light") +
                        "/256/{z}/{x}/{y}.png?key=" +
                        dotenv.env['MAPTILER_KEY'].toString(),
                    subdomains: ['a', 'b', 'c'],
                    tileProvider: CancellableNetworkTileProvider()),
              /*PopupMarkerLayerWidget(
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
        ),*/
              MarkerLayer(markers: allMarkers),
            ],
            /*MapboxMap(
                onMapCreated: _onMapCreated,
                onStyleLoadedCallback: _onStyleLoadedCallback,
                accessToken: dotenv.env['MAPBOX_PUBLIC_PUBLIC'].toString(),
                styleString: Theme.of(context).brightness == Brightness.dark
                    ? "mapbox://styles/mapbox/dark-v10"
                    : "mapbox://styles/mapbox/streets-v11",
                initialCameraPosition: CameraPosition(
                    zoom: 11,
                    target: mapBox.LatLng(
                        (widget.initData as dynamic)[1].latitude,
                        (widget.initData as dynamic)[1].longitude)))*/
          )),
      Align(
          alignment: Alignment.bottomRight,
          child: Container(
              margin: EdgeInsets.fromLTRB(0, 0, 10, 5),
              child: HtmlWidget(
                  '<a class="attribution href="https://www.maptiler.com/copyright/" target="_blank">&copy; MapTiler</a> <a class="attribution href="https://www.openstreetmap.org/copyright" target="_blank">&copy; OpenStreetMap contributors</a>',
                  customStylesBuilder: (element) {
                if (element.classes.contains('attribution')) {
                  return {'text-decoration': 'none'};
                }
                return null;
              })))
    ]));
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
                child: MediaQuery.of(context).size.height >= 550
                    ? Container(
                        height: MediaQuery.of(context).size.height <= 637
                            ? MediaQuery.of(context).size.height * 0.2
                            : MediaQuery.of(context).size.height * 0.35,
                        width: MediaQuery.of(context).size.width,
                        child: Stack(children: [
                          Container(
                            width: double.infinity,
                            child:
                                LayoutBuilder(builder: (context, constraints) {
                              return // create function here to adapt to the parent widget's constraints
                                  CachedNetworkImage(
                                imageUrl:
                                    'https://api.mapbox.com/styles/v1/mapbox/' +
                                        ((Theme.of(context).brightness ==
                                                Brightness.dark)
                                            ? "dark-v10"
                                            : "streets-v11") +
                                        '/static/pin-s+f74e4e(' +
                                        (widget.initData as dynamic)[0][
                                                'Longitude']
                                            .toString() +
                                        ',' +
                                        ((widget
                                                    .initData as dynamic)[0]
                                                ['Latitude']
                                            .toString()) +
                                        '),pin-s-home+555555(' +
                                        (widget.initData
                                                as dynamic)[1]
                                            .longitude
                                            .toString() +
                                        ',' +
                                        ((widget.initData
                                                as dynamic)[1]
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
                          /*Container(
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
                                        Color.fromARGB(155, 157, 75, 239)
                                            .withOpacity(0.9),
                                        Color.fromARGB(158, 38, 146, 192)
                                            .withOpacity(0.93),
                                      ],
                                      tileMode: TileMode.clamp)),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.done_outlined,
                                        color: Colors.black),
                                    Text(
                                      "hi",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ]),
                            ),
                          ),*/
                        ]))
                    : SizedBox.shrink())),
        Container(
            padding: EdgeInsets.only(left: 20),
            child: Row(
              children: [
                Icon(
                  Icons.health_and_safety_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 35,
                ),
                Text(" Nearest AED",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Raleway',
                      fontSize: 35,
                    )),
              ],
            )),
        Card(
          elevation: 20,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.fromLTRB(22, 20, 22, 10),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
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
                          "${((widget.initData as dynamic)[0] as dynamic)['Name']}",
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 30,
                            color: Colors.black,
                          )),
                      subtitle: Row(children: [
                        Icon(
                          Icons.directions_walk_outlined,
                          size: 17,
                          color: Colors.black,
                        ),
                        Text(
                            ' ${(widget.initData as dynamic)[3]} minutes away.',
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ))
                      ]),
                    ),
                  ),
                  Stack(children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35, 20, 35, 20),
                      child: HtmlWidget(
                        ((widget.initData as dynamic)[0]
                                as dynamic)['Description']
                            .replaceAll(RegExp('<br />\\s+'), "<br />"),
                        textStyle: TextStyle(
                            fontFamily: 'KrubLight',
                            color: Colors.black,
                            fontSize: 20.0),
                      ),
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
          margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
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
                  onPressed: () {
                    MapsLauncher.launchCoordinates(
                        (widget.initData as dynamic)[0]['Latitude'],
                        (widget.initData as dynamic)[0]['Longitude']);
                  },
                  style: ButtonStyle(
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    elevation: WidgetStateProperty.all(0),
                    foregroundColor: WidgetStateProperty.all(Colors.black),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.all(27),
                    ),
                  ),
                  child: Text(
                    'Get Directions',
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

/*class Yellow extends StatefulWidget {
  @override
  _YellowState createState() => _YellowState();
}

class _YellowState extends State<Yellow> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
*/
