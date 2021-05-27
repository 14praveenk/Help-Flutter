import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Help',
        home: SafeArea(
          child: Scaffold(
            body: Column(
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
                            child: Container(
                              child: Image(
                                fit: BoxFit.fitWidth,
                                image: AssetImage('assets/placeholder_map.png'),
                              ),
                            )))),
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
                          begin: Alignment(
                              0.0010858093046581807, -1.0000000648203722),
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
                            child: const ListTile(
                              title: Text('Bossman Chicken',
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
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          EdgeInsets.all(5)),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  shape:
                                      MaterialStateProperty.all<CircleBorder>(
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
                  margin: EdgeInsets.fromLTRB(35, 30, 35, 0),
                  child: ElevatedButton(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment(
                                0.0009855687786108902, -4.543046378961659),
                            end: Alignment(
                                0.0009854648765976748, 3.470198684990992),
                            stops: [0, 1],
                            colors: [
                              Color.fromARGB(255, 67, 255, 2),
                              Color.fromARGB(173, 43, 166, 219)
                            ],
                            tileMode: TileMode.clamp),
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
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.all(0),
                      ),
                    ),
                    onPressed: () => {print("clicked")},
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
