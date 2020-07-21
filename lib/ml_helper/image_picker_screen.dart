import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:fluttertododemo/language_support/localization_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {
  LocalizationManager obj;
  File imageFile;
  bool isImageSelected = false;

  openImagePicker(BuildContext context) async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      setState(() {
        isImageSelected = true;
      });
    }
  }

  getTextFromImage() async {
      var text = "";
      FirebaseVisionImage image = FirebaseVisionImage.fromFile(imageFile);
      TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();
      VisionText recognizedText = await textRecognizer.processImage(image);
      for (TextBlock block in recognizedText.blocks) {
        for(TextLine line in block.lines) {
          text = line.text;
        }
      }
      Navigator.pop(context, text);
  }

  @override
  Widget build(BuildContext context) {
    var obj = LocalizationManager.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(obj.getTranslatedValue("desc_text"), style: Theme.of(context).textTheme.headline6,),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColorLight, Theme.of(context).primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
        ),
        leading: IconButton(
          tooltip: obj.getTranslatedValue("back_btn_talkback"),
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              width: 200,
              child: Card(
                child: Center(
                  child: FlatButton(
                    child: isImageSelected ? Image.file(imageFile, fit: BoxFit.cover,) : Icon(Icons.add, color: Theme.of(context).primaryColor,),
                    onPressed: () {
                        openImagePicker(context);
                    },
                  ),
                ),
              ),
            ),
            FlatButton(
              child: Text(obj.getTranslatedValue("save_text"), style: isImageSelected ? Theme.of(context).textTheme.bodyText1 : TextStyle(fontSize: 20)),
              onPressed: isImageSelected ? () {
                getTextFromImage();
              } : null,
            ),
          ],
        ),
      ),
    );
  }
}
