import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ume_talk/domain/entity/UmeTalkUser.dart';
import 'package:ume_talk/testing/testprofile2.dart';

import 'messageListScreen.dart';

class NavigationMenu extends StatefulWidget {
  late UmeTalkUser umeTalkUser;
  late bool darkMode;
  NavigationMenu({Key? key, required this.umeTalkUser, required this.darkMode}) : super(key: key);
  @override
  _NavigationMenuState createState() => _NavigationMenuState(umeTalkUser: umeTalkUser, darkMode: darkMode);
}

class _NavigationMenuState extends State<NavigationMenu> {
  _NavigationMenuState({Key? key, required this.umeTalkUser, required this.darkMode});
  final UmeTalkUser umeTalkUser;
  final bool darkMode;
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          MessageListScreen(),
          UserProfileScreen(),
          Container(color: Colors.blue),
          Container(color: Colors.yellow),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.jumpToPage(
              index,
            );
          });
        },
        type: BottomNavigationBarType.fixed, // Ensures all icons are visible
        selectedItemColor: Colors.black, // Selected icon color
        unselectedItemColor: Colors.black.withOpacity(0.6), // Unselected icon color
        iconSize: 30, // Icon size
        showSelectedLabels: false, // Hide selected labels
        showUnselectedLabels: false, // Hide unselected labels
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: '', // Empty label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '', // Empty label
          ),
        ],
      ),
    );
  }
}