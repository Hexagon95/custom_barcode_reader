import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Screen extends StatefulWidget{
  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- <LogInMenuFrame>
  const Screen({Key? key}) : super(key: key);

  @override
  State<Screen> createState() => ScreenState();
}

class ScreenState extends State<Screen>{
  // ---------- < Variables [Static] > --- ---------- ---------- ---------- ---------- ---------- ----------
  static const EventChannel scanChannel =     EventChannel('com.darryncampbell.datawedgeflutter/scan');
  static const MethodChannel methodChannel =  MethodChannel('com.darryncampbell.datawedgeflutter/command');
  static const TextStyle styleOfName =        TextStyle(fontSize: 20, color: Color.fromARGB(255, 80, 80, 80));
  static const TextStyle styleOfData =        TextStyle(fontSize: 18, color: Colors.black);

  // ---------- < Variables [1] > -------- ---------- ---------- ---------- ---------- ---------- ----------
  String barcodeSymbology =  "Symbology will be shown here";
  String barcodeString =     "Barcode will be shown here";
  String scanTime =          "Scan Time will be shown here";

  // ---------- < Constructor > ---------- ---------- ---------- ---------- ---------- ---------- ----------

  // ---------- < WidgetBuild [0] > ------ ---------- ---------- ---------- ---------- ---------- ----------
  @override
  Widget build(BuildContext context){        
    return WillPopScope(
      onWillPop:  () async => false,
      child:      Scaffold(
        backgroundColor:      Colors.white,
        floatingActionButton: _buttonScan,
        body:                 LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) => mainScreen()
        )
      )
    );
  }

  // ---------- < WidgetBuild [1] > ------ ---------- ---------- ---------- ---------- ---------- ----------
  Widget mainScreen() => Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
    const Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('Vonalkód fajtája:', style: styleOfName),
      Text('Vonalkód:',         style: styleOfName),
      Text('Leolvasás ideje:',  style: styleOfName)
    ]),
    Column(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(barcodeSymbology,  style: styleOfData),
      Text(barcodeString,     style: styleOfData),
      Text(scanTime,          style: styleOfData),
    ])
  ]);

  Widget get _buttonScan => FloatingActionButton(
    onPressed:  _buttonScanPressed,
    child:      const Icon(Icons.barcode_reader, color: Colors.white),
  );

  // ---------- < Methods [1] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  @override
  void initState() {
    super.initState();
    scanChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    _createProfile("DataWedgeFlutterDemo");
  }

  Future _buttonScanPressed() async{
    await _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
    setState((){});
  }

  // ---------- < Methods [2] > ---------- ---------- ---------- ---------- ---------- ---------- ----------
  Future<void> _createProfile(String profileName) async {
    try {
      await methodChannel.invokeMethod('createDataWedgeProfile', profileName);
    } on PlatformException {
      //  Error invoking Android method
    }
  }

  Future<void> _sendDataWedgeCommand(String command, String parameter) async {
    try {
      String argumentAsJson = jsonEncode({"command": command, "parameter": parameter});
      await methodChannel.invokeMethod('sendDataWedgeCommandStringParameter', argumentAsJson);
    }
    catch(e) {if(kDebugMode)print(e);}
  }
  Future startScan() async{
    await _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "START_SCANNING");
    setState((){});
  }

  Future stopScan() async{
    await _sendDataWedgeCommand("com.symbol.datawedge.api.SOFT_SCAN_TRIGGER", "STOP_SCANNING");
    setState((){});
  }

  void _onEvent(event) => setState(() {
    Map barcodeScan =   jsonDecode(event);
    barcodeString =     barcodeScan['scanData'].toString();
    barcodeSymbology =  barcodeScan['symbology'].toString();
    scanTime =          barcodeScan['dateTime'].toString();
    if(kDebugMode)print(barcodeScan.toString());
  });

  void _onError(Object error) => setState(() {
    barcodeString =     "hiba";
    barcodeSymbology =  "hiba";
    scanTime =          "hiba";
  });
}