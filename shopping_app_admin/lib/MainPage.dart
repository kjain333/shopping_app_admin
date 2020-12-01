import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:titled_navigation_bar/titled_navigation_bar.dart';

import 'Forms.dart';
import 'Orders.dart';
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
  //For bottom nav
  int _selectedPage = 0;
  var _pageOptions = [
      Forms(),
      Orders()
  ];
  var _pageController = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Khati Khuwa',
            style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold,color: Colors.white),
          ),
        ),
        body: PageView(
          children: _pageOptions,
          onPageChanged: (index) {
            setState(() {
              _selectedPage = index;
            });
          },
          controller: _pageController,
        ),
        bottomNavigationBar: TitledBottomNavigationBar(
            reverse: true,
            currentIndex:
            _selectedPage, // Use this to update the Bar giving a position
            onTap: (index) {
              setState(() {
                _selectedPage = index;
                _pageController.animateToPage(index,
                    duration: Duration(milliseconds: 300), curve: Curves.ease);
              });
            },
            items: [
              TitledNavigationBarItem(title: Text('Form',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300)), icon: Icons.receipt),
              TitledNavigationBarItem(title: Text('Orders',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300)), icon: Icons.shopping_cart),
            ])
    );
  }
}