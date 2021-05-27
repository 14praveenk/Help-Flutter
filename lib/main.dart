import 'package:flutter/material.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help',
      home: SafeArea(child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          Red(),
          Blue(),
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
}

class Red extends StatefulWidget {
  @override
  _RedState createState() => _RedState();
}

class _RedState extends State<Red> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class Blue extends StatefulWidget {
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
                        child: Image(
                          fit: BoxFit.fitWidth,
                          image: AssetImage('assets/placeholder_map.png'),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topRight,
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 125),
                          margin: EdgeInsets.only(top: 10, right: 5),
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
                                  tileMode: TileMode.mirror)),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.done_outlined),
                                Text(" Location")
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
                Text(" Nearest AEDs",
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
          margin: EdgeInsets.fromLTRB(40, 30, 40, 10),
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
                  tileMode: TileMode.mirror),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                    child: const ListTile(
                      title: Text('National HQs',
                          style: TextStyle(
                            fontFamily: 'Raleway',
                            fontSize: 30,
                          )),
                      subtitle: Text('2 minutes away.'),
                    ),
                  ),
                  Stack(children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(35, 30, 0, 20),
                      child: Text("36 Pretty Good Street,\nPR33 1CO",
                          style: TextStyle(
                            fontFamily: 'KrubLight',
                            fontSize: 20,
                          )),
                    ),
                    Container(
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
                        onPressed: () => {print("hi")},
                      ),
                    ),
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
                      tileMode: TileMode.mirror)),
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
