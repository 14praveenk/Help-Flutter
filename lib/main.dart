// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

void main() => runApp(MaterialApp(
      home: Home(),
    ));

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('my first app'),
        centerTitle: true,
        backgroundColor: Colors.red[600],
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          print('youclickedme');
        },
        child: Text('hello'),
      )),
      bottomNavigationBar: FloatingNavbar(
        onTap: (int val) {
          print(val);
        },
        currentIndex: 1,
        items: [
          FloatingNavbarItem(icon: Icons.map_rounded, title: 'Map'),
          FloatingNavbarItem(
              icon: Icons.health_and_safety_rounded, title: 'Home'),
          FloatingNavbarItem(icon: Icons.favorite_rounded, title: 'CPR'),
        ],
      ),
    );
  }
}
