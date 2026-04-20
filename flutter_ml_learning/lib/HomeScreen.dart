import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ml_learning/RecognizerScreen.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImagePicker imagePicker;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker=ImagePicker();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 50,bottom:15,left:5,right:5),
      child: Column(
        children: [
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.scanner,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: () async {
                          XFile? xFile = await imagePicker.pickImage(source: ImageSource.gallery);
                          if(xFile!=null){
                            File image = File(xFile.path);
                            Navigator.push(context,MaterialPageRoute(builder: (ctx){
                              return RecognizerScreen(image: image);
                            }));
                          }
                        },
                      ),
                      Text("Scan", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.document_scanner,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                      Text("Recognize", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Icon(
                          Icons.image_outlined,
                          size: 25,
                          color: Colors.white,
                        ),
                        onTap: () {},
                      ),
                      Text("Enhance", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: Colors.black,
            child: Container(height: MediaQuery.of(context).size.height-250),
          ),
          Card(
            color: Colors.blueAccent,
            child: Container(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    child: Icon(Icons.scanner, size: 35, color: Colors.white),
                    onTap: () {},
                  ),
                  InkWell(
                    child: Icon(
                      Icons.document_scanner,
                      size: 50,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                  InkWell(
                    child: Icon(
                      Icons.image_outlined,
                      size: 35,
                      color: Colors.white,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
