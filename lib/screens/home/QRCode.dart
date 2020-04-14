import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'detailGig.dart';

class QrCodePage extends StatefulWidget {

  @override
  _QrCodePageState createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  String message = 'QR CODE SCANNER';
  String barcode = "";
  DocumentSnapshot post;

  Future getGigs(String id) {
    var firestore = Firestore.instance;
    print("------------------ VALOR DO ID "+ id +" ------------------");
    firestore.collection("gigs").document(id).snapshots().listen((doc) => post = doc);

    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailGig(post: post)));
    });

    print("------------------ VALOR DO post "+ post.toString() +" ------------------");
  }

  Future scan() async {
    try
    {
      String barcode = await BarcodeScanner.scan();
      setState(() async {
        this.barcode = barcode;
        getGigs(this.barcode);

        new Container(
            color: Colors.white,
            child: Center(
              child: SpinKitChasingDots(
                color: Colors.yellow,
                size: 50.0,
              ),
            )
        );

      });

    }
    on PlatformException catch (e)
    {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() => this.barcode = 'Unknown error: $e');
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar (
        title: Text('QRCode Reader'),
        backgroundColor: Colors.yellow[700],
      ),
      body: Center (
        child:
          Text (
            message,
          )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: scan,
        label: Text('Scan'),
        icon: Icon(Icons.camera_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
