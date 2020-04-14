import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:findagig/models/user.dart';
import 'package:findagig/screens/home/CameraScreen.dart';
import 'package:findagig/services/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class SettingsPage extends StatefulWidget {
  String user;
  SettingsPage(this.user);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _name = "";
  var _email = "";
  var _password = "";
  var _imageSource = "";
  File _image;

  File _imageFile;

  Future uploadPic(BuildContext context) async{
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child("/avatars/" + _name);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;

    setState(() {
      print("Profile Picture uploaded");
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Profile Picture Uploaded')));
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);

    setState(() {
      _imageFile = selected;
      print('Image Path $_imageFile');
    });

  }

  Future<Stream<QuerySnapshot>> getUserInfo() async {
    var firestore = Firestore.instance;
    Stream<QuerySnapshot> qn;
    qn = await firestore.collection("users")
        .where('uid', isEqualTo: widget.user)
        .snapshots();

    qn.forEach((element) {
      element.documents.forEach((aux) {
        _name = (aux.data['name']);
        _email = (aux.data['email']);
        _password = (aux.data['password']);
        _imageSource = (aux.data['image']);
      });
    });

    setState(() {
      print("-------- Setting state");
      _name = _name;
      _email = _email;
      _password = _password;
      _imageSource = _imageSource;
    });

    return qn;
  }

  @override
  void initState(){
    super.initState();
    getUserInfo();
  }


  @override
  Widget build(BuildContext context) {
    var user = Provider.of<User>(context);


    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        color: Color(0xFFEFEEF5),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(40),
                  constraints: BoxConstraints.expand(height: 170),
                  decoration: BoxDecoration(
                      color: Color(0xFF404040),
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight:  Radius.circular(30))
                  ),
                  child: Container(
                    padding: EdgeInsets.only(top: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('Settings',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 55
                          ),
                        ),
                        Text('.',
                          style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: Color(0xFFFFEA00),
                              fontWeight: FontWeight.bold,
                              fontSize: 55
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SingleChildScrollView(
                  child: Container(
                    height: 700,
                    margin: EdgeInsets.only(top: 180),
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Center(
                          child: InkWell(
                            onTap: () => _pickImage(ImageSource.camera),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Color(0xff476cfb),
                              child: ClipOval(
                                child: new SizedBox(
                                  width: 120.0,
                                  height: 120.0,
                                child: () {
                                    setState(() {
                                      var ref = FirebaseStorage.instance.ref().child("/avatars/"+_name);
                                      ref.getDownloadURL().then((loc) => setState(() => _imageSource = loc));
                                    });
                                    if(_imageFile != null) {
                                      return Image.file(_imageFile,
                                      fit: BoxFit.fill);
                                    }
                                    return Image.network(
                                        _imageSource,
                                        fit: BoxFit.fill);
                                } (),
                              ),
                            ),
                        ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top:15, left: 20.0, right: 20.0),
                          child: Column(
                            children: <Widget>[
                              TextField(
                                onChanged: (val) {
                                  _name = val;
                                  print("NAME CHANGE: " + _name);

                                },
                                controller: TextEditingController(text: _name), // substituir aqui pela variavel
                                decoration: InputDecoration(
                                    labelText: 'NICK NAME',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.yellow))),
                              ),
                              SizedBox(height: 5.0),
                              TextField(
                                onChanged: (val) {
                                  _email = val;
                                  print("MAIL CHANGE: " + _email);

                                },
                                controller: TextEditingController(text: _email), // substituir pela variavel
                                decoration: InputDecoration(
                                    labelText: 'EMAIL',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.yellow))),
                              ),
                              SizedBox(height: 5.0),
                              TextField(
                                controller: TextEditingController(text: _password), // substituir pela variavel
                                decoration: InputDecoration(
                                    labelText: 'PASSWORD ',
                                    labelStyle: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.yellow))),
                                obscureText: true,
                                onChanged: (val) {
                                  _password = val;
                                  print("PASS CHANGE: " + _password);
                                },
                              ),
                              SizedBox(height: 30,),
                              InkWell(
                                onTap: () async {
                                  uploadPic(context);

                                  final CollectionReference coll_users = Firestore.instance.collection('users');

                                  return await coll_users.document(user.uid.toString()).updateData({
                                    'name' : _name,
                                    'password' : _password,
                                    'email' : _email,
                                  });
                                },
                                child: Container(
                                  height: 40.0,
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black,
                                            style: BorderStyle.solid,
                                            width: 1.0
                                        ),
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20.0)
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Center(
                                          child: Text('Submit',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Montserrat'
                                              )
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}