import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:location/location.dart';
import 'customLocation.dart';
/*ElevatedButton(
            onPressed: () {
              var box = Hive.box('settings');
              box.put("welcome_shown", true);
            },*/

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textEditingController = TextEditingController();
  final introKey = GlobalKey<IntroductionScreenState>();
  Location location = new Location();
  bool _canShowLocButton = true;
  bool _canShowCustLocButton = true;
  bool locServiceEnabled = false;
  bool allDone = false;
  PermissionStatus locPermissionEnabled = PermissionStatus.denied;
  void initState() {
    super.initState();
    Future.microtask(() async {
      await determineLocCompatibility();
      if (locServiceEnabled == false) {
        await hideLocButton();
      }
      if (locPermissionEnabled == PermissionStatus.deniedForever) {
        await hideLocButton();
      }
    });
  }

  Future<void> determineLocCompatibility() async {
    locServiceEnabled = await location.serviceEnabled();
    locPermissionEnabled = await location.hasPermission();
  }

  Future<void> hideLocButton() async {
    setState(() {
      _canShowLocButton = false;
    });
  }

  void hideAllButton() {
    setState(() {
      _canShowLocButton = false;
      _canShowCustLocButton = false;
      allDone = true;
      var box = Hive.box('settings');
      box.put("welcome_shown", true);
    });
  }

  void _navToCustomLocationScreen(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => customLocationScreen()),
    ).then((value) {
      if (value == true) {
        hideAllButton();
      }
    });
  }

  Widget _buildFullscrenImage() {
    return Image.asset(
      'assets/fullscreen.jpg',
      fit: BoxFit.cover,
      height: double.infinity,
      width: double.infinity,
      alignment: Alignment.center,
    );
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    var bodyStyle = TextStyle(
      fontSize: 19.0,
      fontFamily: 'KrubLight',
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    );
    var titleStyle = TextStyle(
      fontSize: 28.0,
      fontFamily: 'Raleway',
      fontWeight: FontWeight.w700,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    );
    var pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
          fontSize: 28.0, fontFamily: 'Raleway', fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      descriptionPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black87,
      titlePadding: EdgeInsets.zero,
      imagePadding: EdgeInsets.zero,
      imageAlignment: Alignment.center,
      bodyAlignment: Alignment.center,
    );

    return Material(
        child: IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : Colors.black87,
      globalHeader: Align(
        alignment: Alignment.topLeft,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 16, left: 16),
            child: Text("Help - Alpha Release"),
          ),
        ),
      ),
      pages: [
        PageViewModel(
          title: "",
          bodyWidget: Column(children: [
            Icon(Icons.health_and_safety_outlined,
                size: 0.23 * MediaQuery.of(context).size.height),
            Text("Welcome to Help", style: titleStyle),
            Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Text(
                    "Let's get started and help you find your nearest AED.",
                    style: bodyStyle,
                    textAlign: TextAlign.center))
          ]),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "",
          bodyWidget: Column(children: [
            MediaQuery.of(context).orientation == Orientation.portrait
                ? Icon(Icons.location_on_outlined,
                    size: 0.23 * MediaQuery.of(context).size.height)
                : Container(),
            Text("Location Access", style: titleStyle),
            Container(
              child: Center(
                  child: Text(
                "Help needs a location to gather the nearest AEDs.\n\nYou can choose to give Help access to your current location or enter a location of your choice.",
                style: bodyStyle,
                textAlign: TextAlign.center,
              )),
              margin:
                  const EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
            ),
            _canShowLocButton
                ? ElevatedButton(
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.fromLTRB(40, 20, 40, 20)),
                        backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFF28a745))),
                    child: const Text(
                      'Allow Location Access',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () async {
                      bool _serviceEnabled;
                      PermissionStatus _permissionGranted;
                      LocationData _locationData;
                      _serviceEnabled = await location.serviceEnabled();
                      if (!_serviceEnabled) {
                        _serviceEnabled = await location.requestService();
                        if (!_serviceEnabled) {}
                      }

                      _permissionGranted = await location.hasPermission();
                      if (_permissionGranted == PermissionStatus.denied) {
                        _permissionGranted = await location.requestPermission();
                        if (_permissionGranted != PermissionStatus.granted) {
                          hideLocButton();
                        }
                        if (_permissionGranted == PermissionStatus.granted) {
                          hideAllButton();
                          introKey.currentState?.skipToEnd();
                        }
                      }
                      if (_permissionGranted ==
                          PermissionStatus.deniedForever) {
                        hideLocButton();
                      }
                      if (_permissionGranted == PermissionStatus.granted) {
                        hideAllButton();
                      }
                    })
                : Container(),
            _canShowCustLocButton
                ? Container(
                    margin: const EdgeInsets.only(top: 10.0),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 14),
                      ),
                      onPressed: () {
                        _navToCustomLocationScreen(context);
                      },
                      child: const Text('OR enter a custom location'),
                    ),
                  )
                : Container(child: Icon(Icons.done)),
          ]),
          decoration: pageDecoration,
        ),
      ],

      //onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: false,
      skipFlex: 0,
      showDoneButton: false,
      nextFlex: 0,
      //rtl: true, // Display as right-to-left
      next: Row(children: [Text("Next "), Icon(Icons.arrow_forward)]),
      done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: ShapeDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? Colors.black87
            : Colors.white30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    ));
  }
}
