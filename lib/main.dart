// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _index = 1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Help',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Help'),
          backgroundColor: Colors.red[300],
          centerTitle: true,
        ),
        //If you want to show body behind the navbar, it should be true
        extendBody: true,
        body: Center(
          child: Text(
            "This is Tab $_index.",
            style: TextStyle(
              fontSize: 52,
            ),
          ),
        ),
        bottomNavigationBar: FloatingNavbar(
          onTap: (int val) => setState(() => _index = val),
          currentIndex: _index,
          items: [
            FloatingNavbarItem(icon: Icons.map_rounded, title: 'Map'),
            FloatingNavbarItem(
                icon: Icons.health_and_safety_rounded, title: 'Home'),
            FloatingNavbarItem(icon: Icons.favorite_rounded, title: 'CPR'),
          ],
        ),
      ),
    );
  }
}
