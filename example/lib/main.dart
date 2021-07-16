import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrscan/qrscan.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .whenComplete(() => runApp(new MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: APage()),
    );
  }
}

class APage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
            child: Text("扫码"),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => ScanViewWidget()));
            }),
      ),
    );
  }
}

class ScanViewWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ScanViewWidgetState();
}

class ScanViewWidgetState extends State<ScanViewWidget> {
  final GlobalKey<ScanViewState> key = GlobalKey();
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    //Future.delayed(Duration(milliseconds: 3), () => setState(() {}));
    return Scaffold(
      body: SafeArea(
        top: false,
        bottom: false,
        child: Stack(children: [
          ScanView(
            key: key,
            onCaptureResult: (s) {
              key.currentState?.pause();
              _alertDialog(code: s);
            },
            onErrCodeResult: (s) {
              print(s);
              _alertDialog(code: s.toString());
            },
          ),
          Column(
            children: [
              TextButton(
                  onPressed: () {
                    getImageByGallery(ImageSource.gallery, context);
                  },
                  child: Text('图片')),
              TextButton(
                  onPressed: () {
                    key.currentState?.switchFlashlight(true);
                  },
                  child: Text('闪光灯开')),
              TextButton(
                  onPressed: () {
                    key.currentState?.switchFlashlight(false);
                  },
                  child: Text('闪关灯关')),
            ],
          ),
        ]),
      ),
    );
  }

  _alertDialog({String? code}) async {
    var alertDialogs = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Warning'),
            content:
                Text(code == null ? 'Camera permission not granted' : code),
            actions: <Widget>[
              FlatButton(
                  child: Text('cancel'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        }).whenComplete(() {
      key.currentState?.resume();
    });
    return alertDialogs;
  }

  getImageByGallery(ImageSource source, BuildContext context) async {
    _picker.getImage(source: source).then((value) async {
      if (value != null) {
        print('scanImagePath${value.path}');
        key.currentState?.scanImagePath(value.path);
      }
    });
  }
}
