import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class Orders extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Orders();
  }

}
class _Orders extends State<Orders>{
  final databaseReference = Firestore.instance;
  List<List<String>> products = new List();
  List<List<String>> quantities = new List();
  List<QueryDocumentSnapshot> data = new List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: databaseReference.collection('orders').get(),
        builder: (BuildContext context,AsyncSnapshot<QuerySnapshot> snapshot){
          if(snapshot.connectionState==ConnectionState.done)
            {
              data = snapshot.data.docs;
              products.clear();
              quantities.clear();
              for(int i=0;i<data.length;i++)
                {
                  products.add(new List());
                  quantities.add(new List());
                  for(int j=0;j<data[i]['products'].length;j++)
                    {
                      products[i].add(data[i]['products'][j]['title'].toString());
                      quantities[i].add(data[i]['quantities'][j].toString());
                    }
                }
              return SingleChildScrollView(
                child: Column(
                    children: data.map((e) => MyTile(e)).toList()
                ),
              );
            }
          else
            {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
        },
      )
    );
  }
  Widget MyTile(QueryDocumentSnapshot d){
    return Container(
      width: MediaQuery.of(context).size.width-60,
      padding: EdgeInsets.all(30),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              child: Icon(Icons.delete),
              onTap: (){
                databaseReference.collection('orders').doc(d.id).delete();
                setState(() {
                });
              },
            ),
          ),
          Padding(padding: EdgeInsets.all(0),
             child: Text(d['user']['name'],style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
          Padding(padding: EdgeInsets.all(0),
              child: Text(d['user']['email']+"\t"+d['user']['phone'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),)),
          Padding(padding: EdgeInsets.all(0),
              child: Text(d['address'],style: TextStyle(fontSize: 13,fontWeight: FontWeight.w300),)),
          Padding(padding: EdgeInsets.all(0),
              child: Text(d['coupon'],style: TextStyle(fontSize: 15,fontWeight: FontWeight.w300),)),
          Column(
            children: products[data.indexOf(d)].map((e)=>DataTile(e,quantities[data.indexOf(d)][products[data.indexOf(d)].indexOf(e)])).toList(),
          )
        ],
      ),
    );
  }
  Widget DataTile(String a,String b){
    return ListTile(
      title: Text(a),
      trailing: Text(b),
    );
  }
}