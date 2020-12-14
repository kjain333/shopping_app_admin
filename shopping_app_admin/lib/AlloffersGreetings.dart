import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app_admin/EditOffers.dart';
import 'package:shopping_app_admin/Offers.dart';
import 'package:shopping_app_admin/themes.dart';

class AllOffers extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AllOffers();
  }
}

int selectedIndex = 0;

ScrollController scrollController = new ScrollController();
bool expanded = false;
bool Loading = true;
List<QueryDocumentSnapshot> data = new List();

class _AllOffers extends State<AllOffers> {
  final databaseReference = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    if (selectedIndex > 3)
      scrollController = ScrollController(
          initialScrollOffset: MediaQuery.of(context).size.width);
    else
      scrollController = ScrollController(initialScrollOffset: 0);
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Offers()))
                .whenComplete(() {
              setState(() {});
            });
          },
        ),
        body: FutureBuilder(
          future: databaseReference.collection("offer_greeting").get(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              data = snapshot.data.docs;
              return Stack(
                children: <Widget>[
                  Positioned(
                      top: (expanded) ? 70 : 0,
                      child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height -
                              ((expanded) ? 160 : 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  height: MediaQuery.of(context).size.height -
                                      ((expanded) ? 210 : 150),
                                  width: MediaQuery.of(context).size.width,
                                  child: SingleChildScrollView(
                                    child: Wrap(
                                      children:
                                          data.map((e) => MyData(e)).toList(),
                                    ),
                                  )),
                            ],
                          )))
                ],
              );
            }
          },
        ));
  }

  Widget MyData(QueryDocumentSnapshot querydata) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(color: Colors.white),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(20),
              child: Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: NetworkImage(querydata['url']),
                  fit: BoxFit.fill,
                )),
              ),
            ),
            ListTile(
              title: Text(
                querydata['title'],
                style: style2,
              ),
              subtitle: Text(
                "Coupon:" + querydata['coupon'] + "/-",
                style: subStyle,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditOffer(querydata, querydata.id)))
            .then((value) {
          setState(() {});
        });
      },
    );
  }
}
