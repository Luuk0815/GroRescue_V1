import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart'; //Internetlink: https://pub.dev/packages/flutter_qr_bar_scanner (MIT)
import 'package:http/http.dart' as http; //Internetlink: https://pub.dev/packages/http (Lizenz? - unbekannt)
//Dieses Skript besteht zu großen Teilen aus Examples. Einiges ist dennoch selbstständig erarbeitet worden.

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GroRescue_V1',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'GroRescue_V1'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _qrInfo = 'Scan a QR/Bar code';
  bool _camState = false;

  Future<http.Response> product() async {
    final response = await http.get(Uri.https("world.openfoodfacts.org" ,  "/api/v0/product/$_qrInfo"));
    return response;
  }

  Widget buildProduct0 (){
    return FutureBuilder<http.Response>(
      future: product(),
      builder: (context,snapshot) {
        if (snapshot.hasData){
          int statusCode = snapshot.data!.statusCode;
          if (statusCode == 200){
            if (info.fromJson(jsonDecode(snapshot.data!.body)).keyword0 != null){
              return Text("Die Marke: ${info.fromJson(jsonDecode(snapshot.data!.body)).keyword0}\n");
            }
            else {
              return Text("Kein Ergebnis\n");
            }
          }
          return Text('$statusCode');
        }
        else if (snapshot.hasError){
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  Widget buildProduct1 (){
    return FutureBuilder<http.Response>(
      future: product(),
      builder: (context,snapshot) {
        if (snapshot.hasData){
          int statusCode = snapshot.data!.statusCode;
          if (statusCode == 200){
            if (info.fromJson(jsonDecode(snapshot.data!.body)).keyword1 != null){
              return Text("Stichwort: ${info.fromJson(jsonDecode(snapshot.data!.body)).keyword1}\n");
            }
            else {
              return Text("Kein Ergebnis\n");
            }
          }
          return Text('$statusCode');
        }
        else if (snapshot.hasError){
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  _qrCallback(String? code) {
    setState(() {
      _camState = false;
      _qrInfo = code;
    });
  }

  get barcode => _qrInfo;

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _scanCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: _camState
          ? Center(
        child: SizedBox(
          height: 1000,
          width: 500,
          child: QRBarScannerCamera(
            onError: (context, error) =>
                Text(
                  error.toString(),
                  style: TextStyle(color: Colors.green),
                ),
            qrCodeCallback: (code) {
              _qrCallback(code);
            },
          ),
        ),
      )
          : Center(
          child: Container(
              child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        child: Text('Dein Code: $_qrInfo\n'),
                      ),
                      Container(
                        child: buildProduct0(),
                        ),
                      Container(
                        child: buildProduct1(),
                      )
                    ],
                  )
              )
          )
      ),
    );
  }
}

class info {
  final String? keyword0;
  final String? keyword1;
  info({required this.keyword0, required this.keyword1});
  factory info.fromJson (Map<String, dynamic> json) {
    return info(
      keyword0: json['product']['brands'],
      keyword1: json['product']['_keywords'][0],
    );
  }
}