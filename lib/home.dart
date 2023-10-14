// ignore_for_file: non_constant_identifier_names, sized_box_for_whitespace

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late bool _loading = true;
  late File _image;
  final imagepicker = ImagePicker();
  final List _predictions = [];

  loadmodel() async {
    try {
      await Tflite.loadModel(
          model: 'assets/vww_96_grayscale_quantized.tflite',
          labels: 'assets/labels.txt');
    } catch (e) {
      debugPrint("erreur de chargement du model: $e");
    }
  }

  _loadimmage_gallary() async {
    try {
      var image = await imagepicker.pickImage(source: ImageSource.gallery);
      if (image == null) {
        return null;
      } else {
        _image = File(image.path);
      }
      detect_image(_image);
    } catch (e) {
      // Gérer l'exception ici, afficher un message d'erreur, etc.
      debugPrint(
          "Erreur lors de la sélection d'une image depuis la galerie : $e");
    }
  }

  _loadimmage_camera() async {
    try {
      var image = await imagepicker.pickImage(source: ImageSource.camera);
      if (image == null) {
        return null;
      } else {
        _image = File(image.path);
      }
      detect_image(_image);
    } catch (e) {
      // Gérer l'exception ici, afficher un message d'erreur, etc.
      debugPrint(
          "Erreur lors de la sélection d'une image depuis le camera : $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    loadmodel();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  detect_image(File image) async {
    try {
      var prediction = await Tflite.runModelOnImage(
          path: image.path,
          numResults: 5,
          threshold: 0.6,
          imageMean: 127.5,
          imageStd: 127.5);

      setState(() {
        _loading = false;
        _predictions.add(prediction);
      });
    } catch (e) {
      debugPrint("Erreur lors de l'exécution du modèle TFLite : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mango'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: Colors.blue,
        height: h,
        width: w,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              //color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/images/group-7.png'),
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () {
                    _loadimmage_gallary();
                  },
                  child: Text(
                    'Gallery',
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                  onPressed: () {
                    _loadimmage_camera();
                  },
                  child: Text(
                    'Camera',
                    style: GoogleFonts.roboto(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
            ),
            /* _loading == false
                ? Column(children: [
                    Container(
                      height: 200,
                      width: 200,
                      child: Image.file(_image),
                    ),
                  ])
                : Container(),
            if (_predictions.isNotEmpty) Text(_predictions[0].toString())
*/
            _loading == false
                ? Column(
                    children: [
                      Container(
                        height: 200,
                        width: 200,
                        child: Image.file(_image),
                      ),
                      //  Text(_predictions[0].toString().substring(2))
                      Text(_predictions[0]
                          .map((prediction) =>
                              prediction['label'].toString().substring(2))
                          .join(", ")),
                    ],
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
