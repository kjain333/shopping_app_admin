import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shopping_app_admin/EditProduct.dart';
import 'package:shopping_app_admin/Forms.dart';
import 'package:shopping_app_admin/themes.dart';

class AllProducts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AllProducts();
  }
}

int selectedIndex = 0;
List<String> categories = [
  "All",
  "Traditional Clothes",
  "Jewellery",
  "Pickles",
  "Spices",
  "Hand Craft",
  "Food Items",
  "Daily Needs"
];
ScrollController scrollController = new ScrollController();
bool expanded = false;
bool Loading = true;
List<QueryDocumentSnapshot> data = new List();

class _AllProducts extends State<AllProducts> {
  final databaseReference = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    if (selectedIndex > 3)
      scrollController = ScrollController(
          initialScrollOffset: MediaQuery.of(context).size.width);
    else
      scrollController = ScrollController(initialScrollOffset: 0);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Khati Khuwa',
            style: headStyle,
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () {
                  setState(() {
                    expanded = !expanded;
                  });
                })
          ],
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Forms()))
                .whenComplete(() {
              setState(() {});
            });
          },
        ),
        body: FutureBuilder(
          future: databaseReference.collection("products").get(),
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
                  Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: kPrimaryColor,
                      child: Column(
                        children: [
                          Container(
                            height: 70,
                            width: MediaQuery.of(context).size.width,
                            child: SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children:
                                    categories.map((e) => MyChip(e)).toList(),
                              ),
                            ),
                          ),
                        ],
                      )),
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
    int flag = 0;
    for (int i = 0; i < querydata['categories'].length; i++) {
      if (querydata['categories'][i] == categories[selectedIndex]) {
        flag = 1;
        break;
      }
    }
    return (flag == 0)
        ? Container(
            height: 0,
            width: 0,
          )
        : GestureDetector(
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
                      "Price: Rs. " + querydata['price'] + "/-",
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
                      builder: (context) =>
                          EditProduct(querydata, querydata.id))).then((value) {
                setState(() {});
              });
            },
          );
  }

  Widget MyChip(String data) {
    int index = categories.indexOf(data);
    return Padding(
        padding: EdgeInsets.all(10),
        child: GestureDetector(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color:
                  (selectedIndex == index) ? kPrimaryLightColor : kPrimaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                data,
                style: (selectedIndex != index) ? style1 : subStyle1,
              ),
            ),
          ),
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
          },
        ));
  }
}
