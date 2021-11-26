

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:image_reader/sector.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';


double alt = 0;
Location location = new Location();
final picker = ImagePicker();
void main() async{
WidgetsFlutterBinding.ensureInitialized();

bool _serviceEnabled;
PermissionStatus _permissionGranted;
LocationData _locationData;
_serviceEnabled = await location.serviceEnabled();
if (!_serviceEnabled) {
  _serviceEnabled = await location.requestService();
  if (!_serviceEnabled) {
    return;
  }
}

_permissionGranted = await location.hasPermission();
if (_permissionGranted == PermissionStatus.denied) {
  _permissionGranted = await location.requestPermission();
  if (_permissionGranted != PermissionStatus.granted) {
    return;
  }
}


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: alt.toString(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'ImagePixels Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    location.onLocationChanged.listen((event) { 
      setState(() {
        alt = event.altitude!;
      });
});
    super.initState();
  }
  final AssetImage angular = const AssetImage("assets/test.jpg");
  int max = 0, maxIdx = 0, curr = 0;
  List<Sector> sects = List.empty(growable: true);
  Color color = Colors.transparent;
  File? _image;
  String labelObj = "", labelText = "", labelTextLan = "";
  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(alt.toString()),
        actions: [
          ElevatedButton.icon(onPressed: () async {
            await getImage();
            setState(() {
              labelText = "*";
              labelTextLan = "*";
              labelObj = "*";
            });
            final textLabeler = GoogleMlKit.vision.textDetector();
            final imageLabeler = GoogleMlKit.vision.imageLabeler();
            final languageLabeler = GoogleMlKit.nlp.languageIdentifier();
            final inputImage = InputImage.fromFile(_image!);
            final RecognisedText rt = await textLabeler.processImage(inputImage);
            String rtLan = '';
            if(rt.text != '') {
              try{
                rtLan = await languageLabeler.identifyLanguage(rt.text);
              }catch(e){
                print(e.toString());
              }
            }
            final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
            for(ImageLabel il in labels) print(il.label+" " + il.confidence.toString());
            setState(() {
              labelObj = labels[0].label;
              labelText =  rt.text;
              labelTextLan = rtLan;
            });
          }, icon: const Icon(Icons.filter), label: const Text('Pick an Image'),
        ), 
        ],
      ),
      body: SizedBox.expand(
        child: Center(
          child: Scrollbar(
            isAlwaysShown: true,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(_image!=null)
                    Image.file(_image!),
                if(labelObj != "")
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.find_in_page),
                        if(labelObj == "*")
                          const CircularProgressIndicator()
                        else
                          SelectableText(labelObj)
                      ],
                    ),
                  ),
                  if(labelTextLan != "")
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.language),
                          if(labelTextLan == "*")
                            const CircularProgressIndicator()
                          else
                            SelectableText(labelTextLan)
                        ],
                      ),
                    ),
                  if(labelText != "")
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.text_fields),
                            if(labelText == "*")
                              const CircularProgressIndicator()
                            else
                              SelectableText(labelText)
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        )
      ),
    );
  }
}
class OpenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()
      ..color = Color(0xff000000)
      ..style = PaintingStyle.stroke;
    //a rectangle
    canvas.drawRect(Offset(50/50, 20/50) & Size(50, 40), paint1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}