import 'package:custom_barcode_reader/routes/screen.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();  
  runApp(
    MaterialApp(      
      initialRoute:   '/',
      routes: {
        '/':                  (context) => const Screen(),
      },
    )
  );
}