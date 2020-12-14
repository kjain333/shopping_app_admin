import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';

class CloudStorageResult {
  final String offerimageUrl;
  final String offerimageFileName;
  CloudStorageResult({this.offerimageUrl, this.offerimageFileName});
}

class Offers extends StatefulWidget {
  @override
  _offersState createState() => _offersState();
}

class _offersState extends State<Offers> {
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

  bool loading = false;
  void createRecord() async {
    DocumentReference ref =
        await databaseReference.collection("offer_greeting").add({
      'title': title.text,
      'coupon': coupon.text,
      'price': price.text,
      'description': description.text,
      'url': url,
      'id': DateTime.now().toString()
    }).then((value) {
      Toast.show(
        "Offer Added Succssfully",
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
                      "Add offers/ Greetings",
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
                            labelText: "Offer/Greeting Name",
                            hintText: "Name",
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
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: TextFormField(
                        controller: price,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: "discount",
                            hintText: "Enter amount of discount if discount",
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
                          if (text.isEmpty || text == null)
                            return "Coupon Code is required";
                          return null;
                        },
                        decoration: InputDecoration(
                            labelText: "Coupon code",
                            hintText:
                                "Enter couppon code of discount if discount",
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
                          createRecord();
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
                          "Submit",
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
