import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:toast/toast.dart';
import 'package:image_picker/image_picker.dart';
class CloudStorageResult {
  final String imageUrl;
  final String imageFileName;
  CloudStorageResult({this.imageUrl, this.imageFileName});
}
class Forms extends StatefulWidget{
  _Form createState() => _Form();
}
List<String> categories = ["All","Traditional Clothes","Jewellery","Pickles","Spices","Hand Craft","Food Items","Daily Needs"];
List<bool> selected = [true,false,false,false,false,false,false,false];
List<int> index = [0,1,2,3,4,5,6,7];
bool loading = false;
class _Form extends State<Forms>{
  final databaseReference = Firestore.instance;
  TextEditingController title = new TextEditingController();
  TextEditingController subtitle = new TextEditingController();
  TextEditingController price = new TextEditingController();
  TextEditingController description = new TextEditingController();
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
        url=null;
        Toast.show("Please select an image", context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM,textColor: Colors.white,backgroundColor: Colors.red,);
      }
    });
  }
  void uploadImage({
    @required File imageToUpload,
    @required String title,
  }) async {
    var imageFileName = title + DateTime.now().millisecondsSinceEpoch.toString();
    final StorageReference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child(imageFileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(imageToUpload);
    StorageTaskSnapshot storageSnapshot = await uploadTask.onComplete;
    var downloadUrl = await storageSnapshot.ref.getDownloadURL();
    if (uploadTask.isComplete) {
      setState(() {
        url = downloadUrl.toString();
      });

    }
  }
  void createRecord() async {
    List<String> selectedcategory = new List();
    for(int i=0;i<selected.length;i++)
      {
        if(selected[i])
          selectedcategory.add(categories[i]);
      }
    DocumentReference ref = await databaseReference.collection("products").add({'title': title.text,'subtitle': subtitle.text,'price': price.text,'description': description.text,'categories': selectedcategory,'url': url,'id': DateTime.now().toString()}).then((value){
        Toast.show("Product Added Succssfully", context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM,textColor: Colors.white,backgroundColor: Colors.green,);
        setState(() {
          title.clear();
          subtitle.clear();
          description.clear();
          price.clear();
          url = null;
          for(int i=0;i<selected.length;i++)
            {
              selected[i]=false;
            }
          selected[0]=true;
          loading = false;
        });
        return null;
      },onError: (error){
      loading = false;
      Toast.show(error.toString(), context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM,textColor: Colors.white,backgroundColor: Colors.red,);
    });
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: (loading)?Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Container(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(),
            ),
          ),
        ):SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Text("Get Started with Creating a Product",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: title,
                      validator: (text){
                        if(text == null || text.isEmpty)
                          return "Field cannot be empty";
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: "Product Name",
                          hintText: "Provide product name",
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.blueAccent)
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          )
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: subtitle,
                      validator: (text){
                        if(text == null || text.isEmpty)
                          return "Field cannot be empty";
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: "Short Description",
                          hintText: "Provide short description",
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.blueAccent)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          )
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: price,
                      validator: (text){
                        if(text == null || text.isEmpty)
                          return "Field cannot be empty";
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: "Price",
                          hintText: "Provide price of product",
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.blueAccent)
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          )
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: TextFormField(
                      controller: description,
                      maxLines: 7,
                      validator: (text){
                        if(text == null || text.isEmpty)
                          return "Field cannot be empty";
                        return null;
                      },
                      decoration: InputDecoration(
                          labelText: "Description",
                          hintText: "Provide description for the post",
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.blueAccent)
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.redAccent)
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: BorderSide(color: Colors.grey.shade400)
                          )
                      ),
                    ),
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    children: index.map((e) => MyChip(e)).toList(),
                  ),
                  RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: getImage,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Upload Image",style: TextStyle(color: Colors.white),),
                    ),
                  ),
                  (url!=null)?Center(
                    child: Container(
                      height: 50,
                      width: 50,
                      child: Image.network(url??"",fit: BoxFit.fill,),
                    ),
                  ):Container(),
                  RaisedButton(
                    color: Colors.blueAccent,
                    onPressed: (){
                      if(_formkey.currentState.validate()&&url!=null)
                        {
                          setState(() {
                            loading = true;
                          });
                          createRecord();
                        }
                      else if(url==null)
                        {
                          Toast.show("Please select an image", context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM,textColor: Colors.white,backgroundColor: Colors.red,);
                        }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Text("Submit",style: TextStyle(color: Colors.white),),
                    ),
                  )
                ],
              ),
            )
        ),
      ),
    );
  }
  Widget MyChip(int index){
    return Padding(
      padding: EdgeInsets.all(10),
      child: GestureDetector(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.lightBlueAccent),
            color: (selected[index])?Colors.lightBlueAccent:Colors.transparent,
          ),
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(categories[index],style: TextStyle(fontSize: 16,fontWeight: FontWeight.w300,color: (selected[index])?Colors.white:Colors.lightBlueAccent),),
          ),
        ),
        onTap: (){
          setState(() {
            selected[index] = !selected[index];
          });
        },
      )
    );
  }
}
