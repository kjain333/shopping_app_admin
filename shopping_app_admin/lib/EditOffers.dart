import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class EditOffer extends StatefulWidget {
  QueryDocumentSnapshot snapshot;
  String id;
  EditOffer(this.snapshot, this.id);
  @override
  State<StatefulWidget> createState() {
    return _EditOffer(snapshot, id);
  }
}

bool loading = false;

class _EditOffer extends State<EditOffer> {
  QueryDocumentSnapshot snapshot;
  String id;
  _EditOffer(this.snapshot, this.id);
  final databaseReference = Firestore.instance;
  TextEditingController title = new TextEditingController();
  TextEditingController price = new TextEditingController();
  TextEditingController description = new TextEditingController();
  TextEditingController coupon = new TextEditingController();
  String url;
  final _formkey = GlobalKey<FormState>();
  File _image;
  final picker = ImagePicker();
  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        uploadImage(imageToUpload: _image, title: title.text);
      } else {
        url = null;
        Toast.show(
          "Please select an image",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    });
  }

  void uploadImage({
    @required File imageToUpload,
    @required String title,
  }) async {
    var imageFileName =
        title + DateTime.now().millisecondsSinceEpoch.toString();
    print((url.split('/').last.split('?').first).replaceAll("%20", " "));
    final StorageReference firebaseStorage = FirebaseStorage.instance
        .ref()
        .child(url.split('/').last.split('?').first.replaceAll("%20", " "));
    firebaseStorage.delete();
    setState(() {
      url = null;
    });
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    var downloadUrl = await storageSnapshot.ref.getDownloadURL();
    if (uploadTask.isComplete) {
      setState(() {
        url = downloadUrl.toString();
      });
    }
  }

  void createRecord(String id) async {
    DocumentReference ref =
        await databaseReference.collection("offer_greeting").doc(id).set({
      'title': title.text,
      'price': price.text,
      'description': description.text,
      'coupon': coupon.text,
      'url': url,
      'id': id
    }).then((value) {
      Toast.show(
        "Offer Updated Succssfully",
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.green,
      );
      setState(() {
        title.clear();
        description.clear();
        price.clear();
        coupon.clear();
        url = null;
        loading = false;
      });
      return null;
    }, onError: (error) {
      loading = false;
      Toast.show(
        error.toString(),
        context,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    });
  }

  @override
  void initState() {
    title.text = snapshot.get('title');
    description.text = snapshot.get('description');
    url = snapshot.get('url');
    price.text = snapshot.get('price');
    coupon.text = snapshot.get('coupon');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: (loading)
            ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Container(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Edit or Delete offer",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: title,
                        validator: (text) {
                          if (text == null || text.isEmpty)
                            return "Field cannot be empty";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: "Product Name",
                            hintText: "Provide product name",
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.blueAccent)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: coupon,
                        validator: (text) {
                          if (text == null || text.isEmpty)
                            return "Field cannot be empty";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: "Coupon code",
                            hintText: "Provide a coupon code",
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.blueAccent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: price,
                        keyboardType: TextInputType.number,
                        validator: (text) {
                          if (text == null || text.isEmpty)
                            return "Field cannot be empty";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: "Price",
                            hintText: "Provide price of product",
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.blueAccent)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: description,
                        maxLines: 7,
                        validator: (text) {
                          if (text == null || text.isEmpty)
                            return "Field cannot be empty";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: "Description",
                            hintText: "Provide description for the post",
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.blueAccent)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.redAccent)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade400))),
                      ),
                    ),
                    RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: getImage,
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Upload Image",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    (url != null)
                        ? Center(
                            child: Container(
                              height: 50,
                              width: 50,
                              child: Image.network(
                                url ?? "",
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        : Container(),
                    RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        if (_formkey.currentState.validate() && url != null) {
                          setState(() {
                            loading = true;
                          });
                          createRecord(id);
                        } else if (url == null) {
                          Toast.show(
                            "Please select an image",
                            context,
                            duration: Toast.LENGTH_LONG,
                            gravity: Toast.BOTTOM,
                            textColor: Colors.white,
                            backgroundColor: Colors.red,
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Edit",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    RaisedButton(
                      color: Colors.blueAccent,
                      onPressed: () {
                        final StorageReference firebaseStorage =
                            FirebaseStorage.instance.ref().child(url
                                .split('/')
                                .last
                                .split('?')
                                .first
                                .replaceAll("%20", " "));
                        firebaseStorage.delete();
                        setState(() {
                          url = null;
                        });
                        databaseReference
                            .collection("offer_greeting")
                            .doc(id)
                            .delete();
                        Toast.show("Delete successful", context,
                            backgroundColor: Colors.green,
                            duration: Toast.LENGTH_LONG,
                            gravity: Toast.BOTTOM);
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "Delete",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              )),
      ),
    );
  }
}
